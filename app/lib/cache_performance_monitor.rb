# frozen_string_literal: true

# Tracks Anthropic prompt cache performance for monitoring and optimization
class CachePerformanceMonitor
  class << self
    def record_api_call(response_headers, cache_ttl)
      # Check if this was a cache hit based on Anthropic headers
      # Anthropic returns cache information in response headers
      cache_creation_input_tokens = response_headers["x-anthropic-cache-creation-input-tokens"]&.to_i || 0
      cache_read_input_tokens = response_headers["x-anthropic-cache-read-input-tokens"]&.to_i || 0

      # Determine if this was a cache hit, miss, or partial hit
      cache_status = determine_cache_status(cache_creation_input_tokens, cache_read_input_tokens)

      # Record to NewRelic for monitoring
      if defined?(NewRelic::Agent)
        NewRelic::Agent.record_custom_event("AnthropicCachePerformance", {
          timestamp: Time.current.to_i,
          cache_status: cache_status,
          cache_ttl: cache_ttl,
          creation_tokens: cache_creation_input_tokens,
          read_tokens: cache_read_input_tokens,
          hour_of_day: Time.current.hour,
          day_of_week: Time.current.wday,
        })
      end

      # Log for immediate visibility
      Rails.logger.info("Anthropic Cache Performance: status=#{cache_status} ttl=#{cache_ttl} creation_tokens=#{cache_creation_input_tokens} read_tokens=#{cache_read_input_tokens}")

      {
        status: cache_status,
        creation_tokens: cache_creation_input_tokens,
        read_tokens: cache_read_input_tokens,
      }
    end

    private

    def determine_cache_status(creation_tokens, read_tokens)
      if creation_tokens > 0 && read_tokens == 0
        "miss" # Full cache miss, had to create new cache
      elsif creation_tokens == 0 && read_tokens > 0
        "hit" # Full cache hit, only read from cache
      elsif creation_tokens > 0 && read_tokens > 0
        "partial" # Partial hit, some content cached, some not
      else
        "unknown" # No cache information available
      end
    end
  end
end