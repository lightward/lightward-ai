# frozen_string_literal: true

class PublicUsageThrottle
  class InvalidRules < StandardError; end
  class StoreUnavailable < StandardError; end

  Result = Data.define(
    :limited,
    :would_limit,
    :mode,
    :policy,
    :scope,
    :key_id,
    :retry_after_seconds,
    :window,
    :reason,
    :value,
    :limit,
    :error,
  ) {
    def limited?
      limited
    end

    def enabled?
      mode.in?(["observe", "enforce"])
    end

    def metadata
      {
        public_throttle_limited: limited,
        public_throttle_would_limit: would_limit,
        public_throttle_mode: mode,
        public_throttle_policy: policy,
        public_throttle_scope: scope,
        public_throttle_window: window,
        public_throttle_reason: reason,
        public_throttle_key_id: key_id,
        public_throttle_value: value,
        public_throttle_limit: limit,
        public_throttle_retry_after_seconds: retry_after_seconds,
      }
    end
  }

  Rule = Data.define(
    :name,
    :frame_hour_requests,
    :frame_day_requests,
    :source_hour_requests,
    :source_day_requests,
    :frame_hour_cost_micro_usd,
    :frame_day_cost_micro_usd,
    :source_hour_cost_micro_usd,
    :source_day_cost_micro_usd,
  )

  DEFAULT_RULES = "dev:2:10:5:20:0.10:0.50:0.25:1.00"
  EVENT_NAME = "ApiController: public throttle"
  NAMESPACE = "public-usage-throttle-v1"
  MICRO_USD_PER_USD = 1_000_000
  REDIS_TIMEOUT = 0.2
  RETRY_AFTER_SECONDS = 3600
  WINDOWS = {
    hour: 1.hour.to_i,
    day: 24.hours.to_i,
  }.freeze

  class << self
    def evaluate(**kwargs)
      new(**kwargs).evaluate
    end

    def record_cost(**kwargs)
      new(**kwargs).record_cost
    end

    def reset!
      @redis = nil
      @rules_cache = nil
    end
  end

  def initialize(request:, route:, conversation_frame_id:, bypassed:, token_count: nil, cost_usd: nil)
    @request = request
    @route = route
    @conversation_frame_id = conversation_frame_id
    @token_count = token_count.to_i
    @cost_micro_usd = usd_to_micro_usd(cost_usd)
    @bypassed = bypassed
  end

  def evaluate
    return result(limited: false) unless enabled?
    return result(limited: false) if @bypassed

    checks = request_checks + cost_checks
    exceeded = evaluate_checks(checks)

    result(
      limited: exceeded.present? && mode == "enforce",
      would_limit: exceeded.present?,
      policy: exceeded&.fetch(:policy, nil),
      scope: exceeded&.fetch(:scope, nil),
      window: exceeded&.fetch(:window, nil),
      reason: exceeded&.fetch(:reason, nil),
      value: exceeded&.fetch(:value, nil),
      limit: exceeded&.fetch(:limit, nil),
      key_id: exceeded&.fetch(:key_id, nil) || checks.first&.fetch(:key_id, nil),
      retry_after_seconds: exceeded.present? ? RETRY_AFTER_SECONDS : nil,
    ).tap { |evaluation| record_event(evaluation) if exceeded.present? || mode == "observe" }
  rescue StandardError => error
    Rollbar.error(error)
    record_store_error(error)
    result(limited: false, error: error.class.name)
  end

  def record_cost
    return unless enabled?
    return if @bypassed
    return if @cost_micro_usd <= 0

    exceeded = increment_cost_and_find_exceeded(cost_checks)
    return if exceeded.blank?

    record_event(
      result(
        limited: false,
        would_limit: true,
        policy: exceeded.fetch(:policy),
        scope: exceeded.fetch(:scope),
        window: exceeded.fetch(:window),
        reason: exceeded.fetch(:reason),
        value: exceeded.fetch(:value),
        limit: exceeded.fetch(:limit),
        key_id: exceeded.fetch(:key_id),
        retry_after_seconds: RETRY_AFTER_SECONDS,
      ),
    )
  rescue StandardError => error
    Rollbar.error(error)
    record_store_error(error)
  end

  private

  def enabled?
    mode.in?(["observe", "enforce"])
  end

  def mode
    ENV["PUBLIC_USAGE_THROTTLE_MODE"].to_s.strip.downcase.presence || "off"
  end

  def rules
    cache = self.class.instance_variable_get(:@rules_cache)
    return cache[rules_config] if cache&.key?(rules_config)

    parsed = parse_rules(rules_config)
    self.class.instance_variable_set(:@rules_cache, { rules_config => parsed })
    parsed
  end

  def rules_config
    configured_rules = ENV["PUBLIC_USAGE_THROTTLE_RULES"].to_s.strip
    return configured_rules if configured_rules.present?
    return DEFAULT_RULES unless Rails.env.production?

    raise InvalidRules, "PUBLIC_USAGE_THROTTLE_RULES is not configured"
  end

  def parse_rules(config)
    config.to_s.split(",").map { |raw_rule|
      parts = raw_rule.split(":")
      raise InvalidRules, "Invalid public usage throttle rule" unless parts.size == 9

      name = parts[0]
      frame_hour_requests = parts[1]
      frame_day_requests = parts[2]
      source_hour_requests = parts[3]
      source_day_requests = parts[4]
      frame_hour_cost_usd = parts[5]
      frame_day_cost_usd = parts[6]
      source_hour_cost_usd = parts[7]
      source_day_cost_usd = parts[8]

      Rule.new(
        name: normalize_policy_name(name),
        frame_hour_requests: positive_integer(frame_hour_requests),
        frame_day_requests: positive_integer(frame_day_requests),
        source_hour_requests: positive_integer(source_hour_requests),
        source_day_requests: positive_integer(source_day_requests),
        frame_hour_cost_micro_usd: positive_usd_micro(frame_hour_cost_usd),
        frame_day_cost_micro_usd: positive_usd_micro(frame_day_cost_usd),
        source_hour_cost_micro_usd: positive_usd_micro(source_hour_cost_usd),
        source_day_cost_micro_usd: positive_usd_micro(source_day_cost_usd),
      )
    }
  end

  def positive_integer(value)
    Integer(value, 10).tap { |integer| raise InvalidRules, "Invalid public usage throttle limit" if integer <= 0 }
  end

  def positive_usd_micro(value)
    amount = Float(value)
    raise InvalidRules, "Invalid public usage throttle cost limit" unless amount.finite? && amount.positive?

    (amount * MICRO_USD_PER_USD).round
  rescue ArgumentError, TypeError
    raise InvalidRules, "Invalid public usage throttle cost limit"
  end

  def normalize_policy_name(name)
    normalized = name.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, "")
    raise InvalidRules, "Invalid public usage throttle policy name" if normalized.blank?

    normalized
  end

  def request_checks
    rules.flat_map { |rule|
      [
        check(rule, :frame, :hour, :request_count, rule.frame_hour_requests),
        check(rule, :frame, :day, :request_count, rule.frame_day_requests),
        check(rule, :source, :hour, :request_count, rule.source_hour_requests),
        check(rule, :source, :day, :request_count, rule.source_day_requests),
      ]
    }
  end

  def cost_checks
    rules.flat_map { |rule|
      [
        check(rule, :frame, :hour, :estimated_cost_usd, rule.frame_hour_cost_micro_usd),
        check(rule, :frame, :day, :estimated_cost_usd, rule.frame_day_cost_micro_usd),
        check(rule, :source, :hour, :estimated_cost_usd, rule.source_hour_cost_micro_usd),
        check(rule, :source, :day, :estimated_cost_usd, rule.source_day_cost_micro_usd),
      ]
    }
  end

  def check(rule, scope, window, reason, limit)
    key_id = throttle_key_id(scope)

    {
      policy: rule.name,
      scope: scope.to_s,
      window: window.to_s,
      reason: reason.to_s,
      limit: limit,
      key_id: key_id,
      redis_key: [NAMESPACE, rule.name, reason, scope, window, key_id].join(":"),
    }
  end

  def throttle_key_id(scope)
    raw_scope = case scope
    when :frame
      [client_ip, @route, @conversation_frame_id].join(":")
    when :source
      [client_ip, @route].join(":")
    end

    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, [NAMESPACE, scope, raw_scope].join(":"))
  end

  def client_ip
    @request.remote_ip.to_s
  end

  def evaluate_checks(checks)
    exceeded = nil

    with_redis do |redis|
      checks.each do |throttle_check|
        value = if throttle_check[:reason] == "request_count"
          redis.call("INCR", throttle_check[:redis_key]).to_i.tap {
            redis.call("EXPIRE", throttle_check[:redis_key], WINDOWS.fetch(throttle_check[:window].to_sym))
          }
        else
          redis.call("GET", throttle_check[:redis_key]).to_i
        end

        if exceeded?(value, throttle_check)
          exceeded ||= throttle_check.merge(value: display_value(value, throttle_check))
        end
      end
    end

    exceeded
  end

  def increment_cost_and_find_exceeded(checks)
    exceeded = nil

    with_redis do |redis|
      checks.each do |throttle_check|
        value = redis.call("INCRBY", throttle_check[:redis_key], @cost_micro_usd).to_i
        redis.call("EXPIRE", throttle_check[:redis_key], WINDOWS.fetch(throttle_check[:window].to_sym))
        if exceeded?(value, throttle_check)
          exceeded ||= throttle_check.merge(value: display_value(value, throttle_check))
        end
      end
    end

    exceeded
  end

  def exceeded?(value, throttle_check)
    if throttle_check[:reason] == "request_count"
      value > throttle_check[:limit]
    else
      value >= throttle_check[:limit]
    end
  end

  def display_value(value, throttle_check)
    return value unless throttle_check[:reason] == "estimated_cost_usd"

    micro_usd_to_usd(value)
  end

  def with_redis
    raise StoreUnavailable, "PUBLIC_USAGE_THROTTLE_REDIS_URL is not configured" if redis_url.blank?

    yield redis
  end

  def redis
    self.class.instance_variable_get(:@redis) || begin
      redis = RedisClient.config(
        url: redis_url,
        connect_timeout: REDIS_TIMEOUT,
        read_timeout: REDIS_TIMEOUT,
        write_timeout: REDIS_TIMEOUT,
      ).new_client
      self.class.instance_variable_set(:@redis, redis)
    end
  end

  def redis_url
    ENV["PUBLIC_USAGE_THROTTLE_REDIS_URL"].to_s.strip.presence
  end

  def usd_to_micro_usd(cost_usd)
    (cost_usd.to_f * MICRO_USD_PER_USD).round
  end

  def micro_usd_to_usd(micro_usd)
    (micro_usd.to_f / MICRO_USD_PER_USD).round(8)
  end

  def result(
    limited:,
    would_limit: false,
    policy: nil,
    scope: nil,
    window: nil,
    reason: nil,
    value: nil,
    limit: nil,
    key_id: nil,
    retry_after_seconds: nil,
    error: nil
  )
    Result.new(
      limited: limited,
      would_limit: would_limit,
      mode: mode,
      policy: policy,
      scope: scope,
      window: window,
      reason: reason,
      value: value,
      limit: display_limit(limit, reason),
      key_id: key_id&.first(12),
      retry_after_seconds: retry_after_seconds,
      error: error,
    )
  end

  def record_event(evaluation)
    ::NewRelic::Agent.record_custom_event(
      EVENT_NAME,
      evaluation.metadata.merge(
        chat_log_token_count: @token_count,
        conversation_frame_id: @conversation_frame_id,
        token_limit_bypassed: @bypassed,
      ),
    )
  end

  def display_limit(limit, reason)
    return if limit.nil?
    return micro_usd_to_usd(limit) if reason == "estimated_cost_usd"

    limit
  end

  def record_store_error(error)
    ::NewRelic::Agent.record_custom_event(
      EVENT_NAME,
      {
        public_throttle_limited: false,
        public_throttle_mode: mode,
        public_throttle_error: error.class.name,
        chat_log_token_count: @token_count,
        conversation_frame_id: @conversation_frame_id,
        estimated_cost_usd: micro_usd_to_usd(@cost_micro_usd),
        token_limit_bypassed: @bypassed,
      },
    )
  end
end
