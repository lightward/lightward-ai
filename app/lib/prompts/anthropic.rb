# frozen_string_literal: true

# app/lib/prompts/anthropic.rb
require "net/http"
require "fileutils"
require "json"
require "time"

module Prompts
  module Anthropic
    ORIGIN = "https://api.anthropic.com"
    MODEL = "claude-sonnet-4-6"
    BETAS = nil
    # Our cache lifetime for the system prompt, applied here at the transport
    # layer — NOT in the published prompt itself, which /api/system.json
    # serves verbatim to third parties whose traffic economics are their own.
    # The 1-hour tier (GA, no beta header) costs 2x base per write vs 1.25x
    # for the 5-minute default, and reads (which dominate for us) cost the
    # same either way; it pays for itself whenever it saves rewrites across
    # the gaps in traffic. Cached entries refresh on every read at no cost.
    # Client-submitted markers in the chat_log stay on the 5-minute default
    # (the controller strips any client-sent ttl), which also satisfies the
    # API's longer-TTL-first ordering rule, since system renders first.
    CACHE_TTL = "1h"
    # Claude Sonnet 4.6 API pricing, checked against Anthropic docs on
    # 2026-07-09. Cache writes bill by TTL tier: 1.25x base for the 5-minute
    # default, 2x for the 1-hour tier used on the system prompt. The API
    # reports the split under usage.cache_creation.ephemeral_{5m,1h}_input_tokens.
    PRICING_USD_PER_MILLION = {
      "input_tokens" => 3.0,
      "cache_creation_5m_input_tokens" => 3.75,
      "cache_creation_1h_input_tokens" => 6.0,
      "cache_read_input_tokens" => 0.30,
      "output_tokens" => 15.0,
    }.freeze

    class << self
      def count_tokens(model: MODEL, system:, messages:)
        payload = {
          model: model,
          system: system,
          messages: messages,
        }

        response = api_request("/v1/messages/count_tokens", payload)

        case response
        when Net::HTTPSuccess
          parsed = JSON.parse(response.body)
          parsed["input_tokens"]
        else
          raise "Failed to count tokens: HTTP #{response.code}\n\n#{response.body}"
        end
      end

      def messages(
        model:,
        system:,
        messages:,
        stream: false,
        &block
      )
        payload = {
          model: model,
          max_tokens: 4000,
          stream: stream,
          temperature: 1.0,
          system: apply_cache_ttl(system),
          messages: messages,
        }

        api_request("/v1/messages", payload, &block)
      end

      # Merge CACHE_TTL into any cache_control markers in the system blocks.
      # Applied only on this billable path — count_tokens writes no cache,
      # and the published /api/system.json stays TTL-neutral.
      def apply_cache_ttl(system)
        return system unless system.respond_to?(:map)

        system.map do |block|
          key = if block.key?(:cache_control)
            :cache_control
          elsif block.key?("cache_control")
            "cache_control"
          end
          next block unless key

          block.merge(key => block[key].merge(ttl: CACHE_TTL))
        end
      end

      def api_request(path, payload)
        uri = URI.join(ORIGIN, path)

        http = Net::HTTP.new(uri.host, uri.port).tap do |http|
          http.use_ssl = true
          http.open_timeout = 60 # seconds
          http.read_timeout = 300 # seconds
        end

        request = build_anthropic_request(uri, payload)

        Rails.logger.debug do
          "Anthropic API request: #{path}\n> #{request.body.first(1000)} [...] #{request.body.last(1000)}"
        end

        if block_given?
          result = nil

          http.request(request) do |response|
            result = yield request, response
          end

          result
        else
          http.request(request)
        end
      end

      private

      def build_anthropic_request(uri, payload)
        headers = {
          "content-type" => "application/json",
          "anthropic-version" => "2023-06-01",
          "x-api-key" => ENV.fetch("ANTHROPIC_API_KEY", nil),
        }

        if BETAS.present?
          headers["anthropic-beta"] = BETAS
        end

        request = Net::HTTP::Post.new(uri.path, headers)
        request.body = payload.to_json
        request
      end
    end
  end
end
