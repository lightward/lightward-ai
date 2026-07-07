# frozen_string_literal: true

# app/lib/usage_budget.rb
#
# Shared-resource budgets for an API that stays open. This is not a lock on
# the door: the interface remains public and unauthenticated, and the 50k
# horizon still bounds any single request. What this bounds is *repetition* —
# hundreds of replays of the same large context, each individually legal,
# together a runaway share of a commons.
#
# Privacy is structural, not procedural: budgets are keyed only by HMAC'd
# scope keys (a server-observed source, a content-derived conversation id),
# day-salted so actor-linkage dissolves nightly, and no raw IP, user id, or
# conversation content ever reaches the store or the telemetry. Counter keys
# carry their own TTL — the store holds pacing state, never history.
#
# Thresholds live in private runtime config (ENV), never in this public
# source. LAI_BUDGET_MODE selects off (default) / observe (count and report,
# never block) / enforce (block while over, with Retry-After).
#
# The lifecycle is admit → settle: admit! counts the request in the same
# atomic MULTI that reads the counters (so concurrent requests cannot slip
# past a full cap together), and the caller settles afterward — folding in
# the actual cost when Anthropic responded, refunding the count when the
# request never reached Anthropic at all. An enforced rejection refunds
# itself: it spends nothing, so it counts nothing.
#
# The store is a Redis (Fly's managed Upstash, reached over the org's
# private network — LAI_BUDGET_REDIS_URL). And the store is enhancement,
# never essential: if it is unconfigured or unreachable, every operation
# degrades to nil and requests flow exactly as they do today, with a short
# timeout and a breaker (one failure opens it; the store is left alone for
# BREAKER_SECONDS) so a sick store cannot tax the request path. Fail-open is
# the invariant — enforcement can be caused only by observed usage, never by
# infrastructure failure.

module UsageBudget
  HMAC_NAMESPACE = "lai-usage-budget-v1"
  KEY_NAMESPACE = "lai-budget-v1"
  WINDOW_KINDS = ["hour", "day"].freeze
  METRICS = ["requests", "cost"].freeze
  # A window's counter stops being written once its bucket passes; twice the
  # window is comfortably past any assessment that could still read it.
  TTL_SECONDS = { "hour" => 2 * 3600, "day" => 2 * 86_400 }.freeze
  # One failure opens the breaker; the store is skipped (nil, fail-open)
  # until it lapses. Bounds a store outage's tax to one short timeout per
  # process per window instead of two per request.
  BREAKER_SECONDS = 30

  class Exceeded < StandardError
    attr_reader :verdict

    def initialize(verdict = nil)
      @verdict = verdict
      super("usage budget exceeded")
    end
  end

  Verdict = Struct.new(:over_dimensions, keyword_init: true) do
    def over?
      over_dimensions.any?
    end
  end

  class << self
    def mode
      case ENV["LAI_BUDGET_MODE"].to_s.strip.downcase
      when "observe" then :observe
      when "enforce" then :enforce
      else :off
      end
    end

    def active?
      mode != :off
    end

    def enforce?
      mode == :enforce
    end

    # An HMAC'd budget key: stable within a scope kind and the UTC day of
    # `at`, meaningless outside the server (keyed on the app secret), and
    # never reversible to the raw identifier. This is the only form in which
    # a source or conversation is ever stored or reported. The day in the
    # input rotates the key nightly: neither the store nor the telemetry can
    # link an actor across days — both forget on the same clock as the
    # budget's longest window. (Cross-day continuity of a *conversation*
    # still shows in telemetry via the content-derived conversation_id.)
    # Pass the same `at` to admit!/settle!/refund! so the salt and the
    # counter buckets are derived from one instant — a request that spans a
    # boundary stays attributed to its admission time.
    def scope_key(kind, value, at: Time.now.utc)
      value = value.to_s
      return if value.blank?

      scoped_value = [HMAC_NAMESPACE, at.strftime("%Y%m%d"), kind, value].join(":")
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, scoped_value)
    end

    # Admit one request: read the current hour/day counters and count the
    # request in one atomic MULTI (no gap for concurrent requests to slip
    # through together), then compare what was already spent against the
    # configured thresholds. In enforce mode an over verdict refunds the
    # count (a rejection spends nothing, so it counts nothing) and raises
    # Exceeded carrying the verdict. Otherwise returns the Verdict — or nil
    # when the store is unconfigured or unreachable: untracked, fail-open,
    # nothing to settle. A dimension with no configured threshold is
    # unbounded.
    def admit!(scopes, at: Time.now.utc)
      return if scopes.blank?

      keys = scopes.values.flat_map { |key|
        WINDOW_KINDS.map { |window_kind| counter_key(key, window_kind, at) }
      }

      results = with_redis { |redis|
        redis.multi { |tx|
          keys.each { |key| tx.hmget(key, "requests", "cost") }
          keys.each_with_index do |key, index|
            tx.hincrby(key, "requests", 1)
            tx.expire(key, TTL_SECONDS[WINDOW_KINDS[index % WINDOW_KINDS.size]])
          end
        }
      }
      return unless results

      verdict = evaluate(scopes, results.first(keys.size))
      if verdict.over? && enforce?
        refund!(scopes, at: at)
        raise Exceeded, verdict
      end

      verdict
    end

    # Fold the settled cost into the admission's buckets — the request count
    # already landed in admit!. Zero cost settles for free.
    def settle!(scopes, cost_usd:, at: Time.now.utc)
      return if scopes.blank?
      return true if cost_usd.to_f.zero?

      with_redis { |redis|
        redis.pipelined do |pipeline|
          scopes.values.each do |key|
            WINDOW_KINDS.each do |window_kind|
              counter = counter_key(key, window_kind, at)
              pipeline.hincrbyfloat(counter, "cost", cost_usd.to_f)
              pipeline.expire(counter, TTL_SECONDS[window_kind])
            end
          end
        end
        true
      }
    end

    # Give back an admission: the request never reached Anthropic (or was
    # rejected at the gate), so it spends nothing and counts nothing.
    def refund!(scopes, at: Time.now.utc)
      return if scopes.blank?

      with_redis { |redis|
        redis.pipelined do |pipeline|
          scopes.values.each do |key|
            WINDOW_KINDS.each do |window_kind|
              pipeline.hincrby(counter_key(key, window_kind, at), "requests", -1)
            end
          end
        end
        true
      }
    end

    # Seconds until the earliest window that could clear the verdict rolls
    # over — the next UTC hour unless only a per-day dimension is exceeded.
    def retry_after_seconds(verdict)
      now = Time.now.utc
      boundary = if verdict.over_dimensions.all? { |dimension| dimension.include?("per_day") }
        now.beginning_of_day + 1.day
      else
        now.beginning_of_hour + 1.hour
      end

      (boundary - now).ceil
    end

    # Drop the memoized client and close the breaker (e.g. between spec
    # examples that reconfigure the store). Connections re-establish lazily
    # on next use.
    def disconnect!
      @redis&.close
    rescue StandardError
      nil
    ensure
      @redis = nil
      @skip_until = nil
    end

    private

    # Counter rows arrive scope-major, window-minor — the same order the
    # keys were built in admit!. Values are pre-admission (the MULTI reads
    # before it increments), so `spent >= limit` means: this request would
    # be the limit-plus-first.
    def evaluate(scopes, counter_rows)
      index = 0
      over = scopes.flat_map { |scope_kind, _key|
        WINDOW_KINDS.flat_map { |window_kind|
          requests, cost = Array(counter_rows[index])
          index += 1

          METRICS.filter_map { |metric|
            limit = limit_for(scope_kind, metric, window_kind)
            next unless limit

            spent = metric == "requests" ? requests.to_i : cost.to_f
            dimension_label(scope_kind, metric, window_kind) if spent >= limit
          }
        }
      }

      Verdict.new(over_dimensions: over)
    end

    # The bucket rides in the key, so a fixed TTL per write is enough: the
    # key goes cold when its window passes and expires on its own.
    def counter_key(scope_key, window_kind, at)
      bucket = at.strftime(window_kind == "hour" ? "%Y%m%d%H" : "%Y%m%d")
      [KEY_NAMESPACE, scope_key, window_kind, bucket].join(":")
    end

    # Thresholds stay in private runtime config, e.g.
    # LAI_BUDGET_SOURCE_REQUESTS_PER_HOUR, LAI_BUDGET_CONVERSATION_COST_PER_DAY_USD.
    def limit_for(scope_kind, metric, window_kind)
      raw = ENV[limit_env_name(scope_kind, metric, window_kind)].to_s.strip
      return if raw.blank?

      Float(raw, exception: false)
    end

    def limit_env_name(scope_kind, metric, window_kind)
      suffix = if metric == "cost"
        "COST_PER_#{window_kind.upcase}_USD"
      else
        "REQUESTS_PER_#{window_kind.upcase}"
      end

      "LAI_BUDGET_#{scope_kind.upcase}_#{suffix}"
    end

    def dimension_label(scope_kind, metric, window_kind)
      if metric == "cost"
        "#{scope_kind}_cost_per_#{window_kind}_usd"
      else
        "#{scope_kind}_requests_per_#{window_kind}"
      end
    end

    # Run the block with the client. Any failure — connect, timeout, command
    # — is swallowed to nil AND opens the breaker, so the next BREAKER_SECONDS
    # of requests skip the store outright instead of each re-paying the
    # timeout. No store ⇒ nil ⇒ the request flows unbudgeted.
    def with_redis
      return if @skip_until && Time.now.utc < @skip_until

      client = redis_client
      return unless client

      result = yield client
      @skip_until = nil
      result
    rescue StandardError => e
      @skip_until = Time.now.utc + BREAKER_SECONDS
      Rails.logger.warn("[budget] store unavailable (#{e.class}: #{e.message}) — failing open for #{BREAKER_SECONDS}s")
      nil
    end

    # Created lazily, so it is never built in a preloading master — each
    # worker gets its own client on first use, after fork. The budget store
    # must never add meaningful latency to a conversation: a sick store
    # costs at most one short timeout per breaker window (no reconnect
    # retries), and Fly's private network makes the healthy path ~1ms.
    def redis_client
      url = ENV["LAI_BUDGET_REDIS_URL"].to_s.strip
      return if url.blank?

      @redis ||= Redis.new(url: url, timeout: timeout_seconds, reconnect_attempts: 0)
    end

    # Forgiving parse: a malformed override must not disable budgeting (the
    # raise would be swallowed to fail-open by with_redis, silently).
    def timeout_seconds
      Float(ENV.fetch("LAI_BUDGET_TIMEOUT_SECONDS", "0.25"), exception: false) || 0.25
    end
  end
end
