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
# so no raw IP, user id, or conversation content ever reaches the store or
# the telemetry. Counter keys carry their own TTL — the store holds pacing
# state, never history.
#
# Thresholds live in private runtime config (ENV), never in this public
# source. LAI_BUDGET_MODE selects off (default) / observe (count and report,
# never block) / enforce (block while over, with Retry-After).
#
# The store is a Redis (Fly's managed Upstash, reached over the org's
# private network — LAI_BUDGET_REDIS_URL). And the store is enhancement,
# never essential: if it is unconfigured or unreachable, every operation
# degrades to nil and requests flow exactly as they do today. Fail-open is
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

  class Exceeded < StandardError; end

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

    # An HMAC'd budget key: stable within a scope kind, meaningless outside
    # the server (keyed on the app secret), and never reversible to the raw
    # identifier. This is the only form in which a source or conversation is
    # ever stored or reported.
    def scope_key(kind, value)
      value = value.to_s
      return if value.blank?

      scoped_value = [HMAC_NAMESPACE, kind, value].join(":")
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, scoped_value)
    end

    # Compare the current hour/day windows for each scope against configured
    # thresholds, BEFORE this request spends anything. Returns a Verdict
    # (over_dimensions empty when within budget), or nil when the store is
    # unconfigured or unreachable — the caller treats nil as untracked and
    # lets the request through. A dimension with no configured threshold is
    # unbounded.
    def assess(scopes)
      return if scopes.blank?

      counters = fetch_counters(scopes.values)
      return unless counters

      index = 0
      over = scopes.flat_map { |scope_kind, _key|
        WINDOW_KINDS.flat_map { |window_kind|
          requests, cost = Array(counters[index])
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

    # Fold one request into the current hour/day windows of every scope —
    # request count always, cost as reported (0 when Anthropic returned no
    # usage). Returns true, or nil when the store is unconfigured or
    # unreachable (the request simply goes unbudgeted; fail-open).
    def record!(scopes, cost_usd: 0)
      return if scopes.blank?

      with_redis { |redis|
        redis.pipelined do |pipeline|
          scopes.values.each do |key|
            WINDOW_KINDS.each do |window_kind|
              counter = counter_key(key, window_kind)
              pipeline.hincrby(counter, "requests", 1)
              pipeline.hincrbyfloat(counter, "cost", cost_usd.to_f)
              pipeline.expire(counter, TTL_SECONDS[window_kind])
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

    # Drop the memoized client (e.g. between spec examples that reconfigure
    # the store). Connections re-establish lazily on next use.
    def disconnect!
      @redis&.close
    rescue StandardError
      nil
    ensure
      @redis = nil
    end

    private

    # One pipelined round trip: [requests, cost] for the current hour and
    # day bucket of each scope, in scope-major order. nil on any failure.
    def fetch_counters(scope_keys)
      keys = scope_keys.flat_map { |key|
        WINDOW_KINDS.map { |window_kind| counter_key(key, window_kind) }
      }

      with_redis { |redis|
        redis.pipelined { |pipeline|
          keys.each { |key| pipeline.hmget(key, "requests", "cost") }
        }
      }
    end

    # The bucket rides in the key, so a fixed TTL per write is enough: the
    # key goes cold when its window passes and expires on its own.
    def counter_key(scope_key, window_kind)
      bucket = Time.now.utc.strftime(window_kind == "hour" ? "%Y%m%d%H" : "%Y%m%d")
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
    # — is swallowed to nil. No store ⇒ nil ⇒ the request flows unbudgeted.
    def with_redis
      client = redis_client
      return unless client

      yield client
    rescue StandardError => e
      Rails.logger.debug { "[budget] store unavailable (#{e.class}: #{e.message}) — failing open" }
      nil
    end

    # Created lazily, so it is never built in a preloading master — each
    # worker gets its own client on first use, after fork. The budget store
    # must never add meaningful latency to a conversation: a sick store
    # costs at most the timeout, once, and then fails open (no reconnect
    # retries — the next request simply tries fresh).
    def redis_client
      url = ENV["LAI_BUDGET_REDIS_URL"].to_s.strip
      return if url.blank?

      @redis ||= Redis.new(url: url, timeout: timeout_seconds, reconnect_attempts: 0)
    end

    def timeout_seconds
      Float(ENV.fetch("LAI_BUDGET_TIMEOUT_SECONDS", "1"))
    end
  end
end
