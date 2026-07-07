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
# the telemetry. Windows age out after two days; the store holds pacing
# state, never history.
#
# Thresholds live in private runtime config (ENV), never in this public
# source. LAI_BUDGET_MODE selects off (default) / observe (count and report,
# never block) / enforce (block while over, with Retry-After).
#
# Like the foam field, the store is enhancement, never essential: if the
# database is unreachable, every operation degrades to nil and requests flow
# exactly as they do today. Fail-open is the invariant — enforcement can be
# caused only by observed usage, never by infrastructure failure.

require "pg"
require "connection_pool"

module UsageBudget
  SCHEMA_PATH = "app/lib/usage_budget/schema.sql"
  HMAC_NAMESPACE = "lai-usage-budget-v1"
  WINDOW_KINDS = ["hour", "day"].freeze
  METRICS = ["requests", "cost"].freeze
  RETENTION_WINDOW = 2.days
  PURGE_SAMPLE = 1_000 # ~1 purge sweep per thousand recordings

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
    # unreachable — the caller treats nil as untracked and lets the request
    # through. A dimension with no configured threshold is unbounded.
    def assess(scopes)
      return if scopes.blank?

      rows = fetch_windows(scopes.values)
      return unless rows

      counters = rows.index_by { |row| [row["scope_key"], row["window_kind"]] }

      over = scopes.flat_map { |scope_kind, key|
        WINDOW_KINDS.flat_map { |window_kind|
          row = counters[[key, window_kind]] || {}
          METRICS.filter_map { |metric|
            limit = limit_for(scope_kind, metric, window_kind)
            next unless limit

            spent = metric == "requests" ? row["request_count"].to_i : row["cost_usd"].to_f
            dimension_label(scope_kind, metric, window_kind) if spent >= limit
          }
        }
      }

      Verdict.new(over_dimensions: over)
    end

    # Fold one request into the current hour/day windows of every scope —
    # request count always, cost as reported (0 when Anthropic returned no
    # usage). Returns true, or nil when the store is unreachable (the request
    # simply goes unbudgeted; fail-open).
    def record!(scopes, cost_usd: 0)
      return if scopes.blank?

      hour, day = window_starts
      params = []
      values = scopes.values.flat_map { |key|
        [["hour", hour], ["day", day]].map { |window_kind, window_start|
          base = params.size
          params.push(key, window_kind, window_start.iso8601, cost_usd.to_f)
          "($#{base + 1}, $#{base + 2}, $#{base + 3}::timestamptz, 1, $#{base + 4}::numeric)"
        }
      }

      recorded = with_connection { |conn|
        conn.exec_params(<<~SQL, params)
          INSERT INTO lai_budget.windows (scope_key, window_kind, window_start, request_count, cost_usd)
          VALUES #{values.join(", ")}
          ON CONFLICT (scope_key, window_kind, window_start)
          DO UPDATE SET request_count = windows.request_count + 1,
                        cost_usd = windows.cost_usd + EXCLUDED.cost_usd
        SQL
        true
      }

      purge! if recorded && rand(PURGE_SAMPLE).zero?
      recorded
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

    # Assert the substrate, idempotently — a fixed point, not a migration.
    # Boot-resilient: any failure is logged and swallowed; the app boots and
    # runs unbudgeted.
    def assert!
      conn = PG.connect(database_url)
      conn.exec(schema_sql)
      Rails.logger.info("[budget] store asserted")
      true
    rescue => e
      Rails.logger.warn("[budget] store assertion skipped (#{e.class}: #{e.message}) — running unbudgeted")
      false
    ensure
      conn&.finish
    end

    # Drop the connection pool (e.g. on worker boot after a fork).
    def disconnect!
      @pool&.shutdown(&:finish)
      @pool = nil
    end

    private

    def fetch_windows(scope_keys)
      hour, day = window_starts

      with_connection { |conn|
        conn.exec_params(<<~SQL, ["{#{scope_keys.join(",")}}", hour.iso8601, day.iso8601]).to_a
          SELECT scope_key, window_kind, request_count, cost_usd
          FROM lai_budget.windows
          WHERE scope_key = ANY($1::text[])
            AND ((window_kind = 'hour' AND window_start = $2::timestamptz)
              OR (window_kind = 'day' AND window_start = $3::timestamptz))
        SQL
      }
    end

    def window_starts
      now = Time.now.utc
      [now.beginning_of_hour, now.beginning_of_day]
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

    def purge!
      with_connection { |conn|
        conn.exec_params(
          "DELETE FROM lai_budget.windows WHERE window_start < $1::timestamptz",
          [(Time.now.utc - RETENTION_WINDOW).iso8601],
        )
      }
    end

    # Check out a pooled connection and run the block. Any failure —
    # connection, pool-timeout, query — is swallowed to nil; a broken
    # connection is best-effort reset so the pool heals. No store ⇒ nil ⇒
    # the request flows unbudgeted.
    def with_connection
      pool.with do |conn|
        conn.reset if conn.status != PG::CONNECTION_OK
        yield conn
      end
    rescue => e
      Rails.logger.debug { "[budget] store unavailable (#{e.class}: #{e.message}) — failing open" }
      nil
    end

    # Created lazily, so it is never built in a preloading master — each
    # worker gets its own pool on first use, after fork.
    def pool
      @pool ||= ConnectionPool.new(size: pool_size, timeout: checkout_timeout) do
        PG.connect(database_url)
      end
    end

    def database_url
      # In test the store is opt-in via its OWN variable (mirroring the foam
      # field): the suite must stay hermetic against the developer's .env. A
      # spec that wants a live store names one explicitly in
      # LAI_BUDGET_SPEC_DATABASE_URL; everything else gets an unreachable
      # default and degrades open, exactly as production does before
      # provisioning.
      if Rails.env.test?
        ENV.fetch("LAI_BUDGET_SPEC_DATABASE_URL", "postgres://127.0.0.1:1/lai_budget?connect_timeout=1")
      else
        ENV.fetch("LAI_BUDGET_DATABASE_URL", "postgres:///lai_budget?connect_timeout=2")
      end
    end

    def pool_size
      Integer(ENV.fetch("LAI_BUDGET_POOL_SIZE", "5"))
    end

    def checkout_timeout
      Float(ENV.fetch("LAI_BUDGET_CHECKOUT_TIMEOUT", "1"))
    end

    def schema_sql
      File.read(Rails.root.join(SCHEMA_PATH))
    end
  end
end
