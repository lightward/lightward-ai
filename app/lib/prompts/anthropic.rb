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
    BETAS = "context-1m-2025-08-07"

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
          system: system,
          messages: messages,
        }

        api_request("/v1/messages", payload, &block)
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
