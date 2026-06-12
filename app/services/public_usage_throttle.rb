# frozen_string_literal: true

# A budget guardrail for repeated expensive public traffic. Counts requests
# and actual estimated Anthropic spend per source (client IP + route) in
# fixed hour/day windows, backed by one small postgres table. Public traffic
# that spends a window's budget cools down until the window rolls over.
#
# Deliberately not auth: bypass-key traffic is exempt, budgets live in
# runtime config, and the throttle fails open (recording the failure) if the
# store is unreachable. Raw IPs never leave the process — sources are HMAC
# digests, truncated before they reach telemetry.
class PublicUsageThrottle
  class StoreUnavailable < StandardError; end
  class InvalidBudget < StandardError; end

  EVENT_NAME = "ApiController: public throttle"
  HMAC_NAMESPACE = "public-usage-throttle-v1"
  MICRO_USD_PER_USD = 1_000_000
  WINDOW_SECONDS = {
    "hour" => 3600,
    "day" => 86_400,
  }.freeze

  Result = Data.define(
    :limited,
    :would_limit,
    :mode,
    :window,
    :reason,
    :value,
    :limit,
    :key_id,
    :retry_after_seconds,
    :error,
  ) {
    def limited?
      limited
    end

    def metadata
      {
        public_throttle_limited: limited,
        public_throttle_would_limit: would_limit,
        public_throttle_mode: mode,
        public_throttle_window: window,
        public_throttle_reason: reason,
        public_throttle_value: value,
        public_throttle_limit: limit,
        public_throttle_key_id: key_id,
        public_throttle_retry_after_seconds: retry_after_seconds,
      }
    end
  }

  # The store — one tiny UNLOGGED table, asserted idempotently when a
  # connection is first established. A single upsert covers both windows in
  # one round trip and returns their running totals. Buckets are fixed
  # windows (floor of epoch time), so counters roll over on schedule no
  # matter how steadily a source keeps knocking.
  class Store
    SCHEMA_SQL = <<~SQL
      CREATE UNLOGGED TABLE IF NOT EXISTS public_usage_throttle_counters (
        source text NOT NULL,
        win text NOT NULL,
        bucket bigint NOT NULL,
        requests integer NOT NULL DEFAULT 0,
        micro_usd bigint NOT NULL DEFAULT 0,
        PRIMARY KEY (source, win, bucket)
      )
    SQL

    BUMP_SQL = <<~SQL
      INSERT INTO public_usage_throttle_counters AS counters (source, win, bucket, requests, micro_usd)
      VALUES ($1, 'hour', $2, $4, $5), ($1, 'day', $3, $4, $5)
      ON CONFLICT (source, win, bucket) DO UPDATE
        SET requests = counters.requests + EXCLUDED.requests,
            micro_usd = counters.micro_usd + EXCLUDED.micro_usd
      RETURNING win, requests, micro_usd
    SQL

    PRUNE_SQL = <<~SQL
      DELETE FROM public_usage_throttle_counters
      WHERE (win = 'hour' AND bucket < $1) OR (win = 'day' AND bucket < $2)
    SQL

    PRUNE_CHANCE = 1000

    def bump(source:, hour_bucket:, day_bucket:, requests: 0, micro_usd: 0)
      with_connection { |conn|
        prune(conn, hour_bucket, day_bucket) if rand(PRUNE_CHANCE).zero?

        conn.exec_params(BUMP_SQL, [source, hour_bucket, day_bucket, requests, micro_usd])
          .each_with_object({}) { |row, totals|
            totals[row["win"]] = { requests: row["requests"].to_i, micro_usd: row["micro_usd"].to_i }
          }
      }
    end

    private

    def prune(conn, hour_bucket, day_bucket)
      conn.exec_params(PRUNE_SQL, [hour_bucket, day_bucket])
    rescue PG::Error
      nil
    end

    def with_connection(&block)
      raise StoreUnavailable, "PUBLIC_USAGE_THROTTLE_DATABASE_URL is not configured" if database_url.blank?

      pool.with(&block)
    end

    def pool
      @pool ||= ConnectionPool.new(size: pool_size, timeout: 1) do
        PG.connect(database_url).tap { |conn|
          conn.exec("SET statement_timeout = '250ms'")
          conn.exec(SCHEMA_SQL)
        }
      end
    end

    def database_url
      ENV.fetch("PUBLIC_USAGE_THROTTLE_DATABASE_URL", nil).to_s.strip.presence
    end

    def pool_size
      Integer(ENV.fetch("PUBLIC_USAGE_THROTTLE_POOL_SIZE", "5"))
    end
  end

  class << self
    def evaluate(request:, route:, bypassed:)
      new(request: request, route: route, bypassed: bypassed).evaluate
    end

    def record_cost(request:, route:, bypassed:, cost_usd:)
      new(request: request, route: route, bypassed: bypassed).record_cost(cost_usd)
    end

    def store
      @store ||= Store.new
    end

    attr_writer :store

    def reset!
      @store = nil
    end
  end

  def initialize(request:, route:, bypassed:)
    @request = request
    @route = route
    @bypassed = bypassed
  end

  # The gate, called before any upstream work: count the request against
  # both windows and report whether this source's budget is spent. Never
  # raises — any store failure degrades to "not limited", with telemetry.
  def evaluate
    return result(limited: false) unless enabled?
    return result(limited: false) if @bypassed

    totals = self.class.store.bump(source: source_key, requests: 1, **buckets)
    exceeded = find_exceeded(totals)

    result(
      limited: exceeded.present? && mode == "enforce",
      would_limit: exceeded.present?,
      **(exceeded || {}),
    ).tap { |evaluation| record_event(evaluation) if exceeded.present? || mode == "observe" }
  rescue StandardError => error
    Rollbar.error(error)
    record_store_error(error)
    result(limited: false, error: error.class.name)
  end

  # The ledger, called after a successful response: add what the request
  # actually cost, so the next evaluate sees real spend.
  def record_cost(cost_usd)
    return unless enabled?
    return if @bypassed

    micro_usd = (cost_usd.to_f * MICRO_USD_PER_USD).round
    return if micro_usd <= 0

    totals = self.class.store.bump(source: source_key, micro_usd: micro_usd, **buckets)
    exceeded = find_exceeded(totals, reasons: ["estimated_cost_usd"])
    return if exceeded.blank?

    record_event(result(limited: false, would_limit: true, **exceeded))
  rescue StandardError => error
    Rollbar.error(error)
    record_store_error(error)
  end

  private

  def enabled?
    ["observe", "enforce"].include?(mode)
  end

  def mode
    @mode ||= ENV.fetch("PUBLIC_USAGE_THROTTLE_MODE", "").to_s.strip.downcase.presence || "off"
  end

  def now
    @now ||= Time.current.to_i
  end

  def buckets
    {
      hour_bucket: now / WINDOW_SECONDS.fetch("hour"),
      day_bucket: now / WINDOW_SECONDS.fetch("day"),
    }
  end

  def find_exceeded(totals, reasons: ["request_count", "estimated_cost_usd"])
    WINDOW_SECONDS.each_key do |window|
      window_totals = totals[window]
      next if window_totals.blank?

      if reasons.include?("request_count")
        budget = request_budget(window)
        if budget && window_totals.fetch(:requests) > budget
          return exceeded_for(window, "request_count", window_totals.fetch(:requests), budget)
        end
      end

      next if reasons.exclude?("estimated_cost_usd")

      budget = cost_budget_micro_usd(window)
      if budget && window_totals.fetch(:micro_usd) >= budget
        return exceeded_for(
          window,
          "estimated_cost_usd",
          micro_usd_to_usd(window_totals.fetch(:micro_usd)),
          micro_usd_to_usd(budget),
        )
      end
    end

    nil
  end

  def exceeded_for(window, reason, value, limit)
    {
      window: window,
      reason: reason,
      value: value,
      limit: limit,
      retry_after_seconds: WINDOW_SECONDS.fetch(window) - (now % WINDOW_SECONDS.fetch(window)),
    }
  end

  def request_budget(window)
    positive_integer(ENV.fetch("PUBLIC_USAGE_THROTTLE_#{window.upcase}_REQUESTS", nil))
  end

  def cost_budget_micro_usd(window)
    usd = positive_float(ENV.fetch("PUBLIC_USAGE_THROTTLE_#{window.upcase}_USD", nil))
    usd && (usd * MICRO_USD_PER_USD).round
  end

  # Absent budgets are simply off; present-but-malformed budgets raise, so
  # the misconfiguration surfaces (via the fail-open rescue) instead of
  # silently disabling a limit.
  def positive_integer(value)
    return if value.to_s.strip.blank?

    integer = Integer(value.to_s, 10)
    raise InvalidBudget, "Budget must be positive: #{value}" unless integer.positive?

    integer
  rescue ArgumentError
    raise InvalidBudget, "Invalid budget: #{value}"
  end

  def positive_float(value)
    return if value.to_s.strip.blank?

    float = Float(value.to_s)
    raise InvalidBudget, "Budget must be positive: #{value}" unless float.positive? && float.finite?

    float
  rescue ArgumentError
    raise InvalidBudget, "Invalid budget: #{value}"
  end

  def micro_usd_to_usd(micro_usd)
    (micro_usd.to_f / MICRO_USD_PER_USD).round(8)
  end

  def source_key
    @source_key ||= OpenSSL::HMAC.hexdigest(
      "SHA256",
      Rails.application.secret_key_base,
      [HMAC_NAMESPACE, @request.remote_ip.to_s, @route].join(":"),
    )
  end

  def result(
    limited:,
    would_limit: false,
    window: nil,
    reason: nil,
    value: nil,
    limit: nil,
    retry_after_seconds: nil,
    error: nil
  )
    Result.new(
      limited: limited,
      would_limit: would_limit,
      mode: mode,
      window: window,
      reason: reason,
      value: value,
      limit: limit,
      key_id: source_key.first(12),
      retry_after_seconds: retry_after_seconds,
      error: error,
    )
  end

  def record_event(evaluation)
    ::NewRelic::Agent.record_custom_event(EVENT_NAME, evaluation.metadata)
  end

  def record_store_error(error)
    ::NewRelic::Agent.record_custom_event(
      EVENT_NAME,
      {
        public_throttle_limited: false,
        public_throttle_mode: mode,
        public_throttle_error: error.class.name,
      },
    )
  end
end
