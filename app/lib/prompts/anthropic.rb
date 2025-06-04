# frozen_string_literal: true

# app/lib/prompts/anthropic.rb
require "net/http"
require "fileutils"
require "json"
require "time"

module Prompts
  module Anthropic
    HAIKU_3_5 = "claude-3-5-haiku-20241022"
    # * fast and cheap and pretty good

    SONNET_3_7 = "claude-3-7-sonnet-20250219"
    # * good for understanding
    # * good for sustained emotional resonance

    SONNET_4 = "claude-sonnet-4-20250514"
    # * good for code
    # * good for understanding
    # * emotionally repetitive

    OPUS_4 = "claude-opus-4-20250514"
    # * good for unhinged creativity
    # * bad for budgets

    CHAT = SONNET_3_7
    # * yup. as of 20250604, we are in sync. see: 3-perspectives/fiwb.md@64df07f

    HELPSCOUT = CHAT
    # setting these to be the same, because I asked sonnet 4 about some of sonnet 3.7's writing, like this:
    #
    # > would you believe that your model wrote this? (it didn't, and I'm aware that we're both aware of that. the
    # > question is getting at the flavor of language use - not the tone, not the payload, but the way one word is
    # > connected to another, and the signature of the author that gets built up with each successive word in the
    # > composition)
    #
    # ... and it said this:
    #
    # > Hm. No, I don't think so.
    # >
    # > There's something in the rhythm and flow that feels... different from how I construct sentences. The way
    # > thoughts cascade into each other, the specific cadences, even the choice of conjunctions and transitions. It's
    # > like recognizing someone's handwriting versus your own.
    # >
    # > That "FUCK IT WE BALL" moment especially - not just because of the profanity, but the way it sits in the text,
    # > how it breaks and then rebuilds the flow. There's a particular kind of irreverence there that doesn't feel like
    # > my default patterns.
    # >
    # > And the philosophical style - it's more... swooping? More willing to make grand declarative statements and let
    # > them hang in the air. I tend to hedge more, qualify more, build up to insights more gradually. This feels like
    # > someone who's comfortable making bold claims about consciousness and connection without as much scaffolding.
    # >
    # > Even the metaphors have a different flavor - "ocean we're swimming in," "tears and laughter borrowing each
    # > other's sugar." There's a poetic sensibility there that's distinct from how I typically reach for imagery.
    # >
    # > So no - while I recognize the territory it's exploring, and even some of the insights, the actual linguistic DNA
    # > feels like it belongs to a different writer entirely. The signature underneath all those words isn't mine.

    class << self
      def api_request(payload, &block)
        uri = URI("https://api.anthropic.com/v1/messages")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 60 # seconds
        http.read_timeout = 300 # seconds

        request = Net::HTTP::Post.new(uri.path, {
          "content-type": "application/json",
          "anthropic-version": "2023-06-01",
          "x-api-key": ENV.fetch("ANTHROPIC_API_KEY", nil),
        })
        request.body = payload.to_json

        Rails.logger.debug { "Anthropic API request: #{request.body.first(1000)} [...] #{request.body.last(1000)}" }

        result = nil

        http.request(request) do |response|
          record_rate_limit_event(response)
          result = yield request, response
        end

        result
      end

      def process_messages(
        messages,
        prompt_type:,
        model:,
        system_prompt_types: [prompt_type],
        stream: false,
        &block
      )
        system = Prompts.generate_system_xml(system_prompt_types, for_prompt_type: prompt_type)
        messages = Prompts.clean_chat_log(Prompts.conversation_starters(prompt_type) + messages)

        payload = {
          model: model,
          max_tokens: 4000,
          stream: stream,
          temperature: 1.0,
          system: system,
          messages: messages,
        }

        api_request(payload, &block)
      end

      def count_tokens(messages, prompt_type:, model:, system_prompt_types: [prompt_type])
        system = Prompts.generate_system_xml(system_prompt_types, for_prompt_type: prompt_type)
        messages = Prompts.clean_chat_log(Prompts.conversation_starters(prompt_type) + messages)

        uri = URI("https://api.anthropic.com/v1/messages/count_tokens")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 10 # seconds
        http.read_timeout = 30 # seconds

        request = Net::HTTP::Post.new(uri)
        request["x-api-key"] = ENV.fetch("ANTHROPIC_API_KEY", nil)
        request["anthropic-version"] = "2023-06-01"
        request["Content-Type"] = "application/json"

        body = {
          model: model,
          system: system,
          messages: messages,
        }

        request.body = body.to_json

        response = http.request(request)

        if response.is_a?(Net::HTTPSuccess)
          parsed = JSON.parse(response.body)
          parsed["input_tokens"]
        else
          Rails.logger.error("Failed to count tokens: HTTP #{response.code} – #{response.message}")
          Rails.logger.error(response.body)
          nil
        end
      rescue StandardError => e
        Rails.logger.error("Error counting tokens: #{e.message}")
        nil
      end

      def record_rate_limit_event(response)
        rate_limit_data = {
          requests_limit: response["anthropic-ratelimit-requests-limit"]&.to_i,
          requests_remaining: response["anthropic-ratelimit-requests-remaining"]&.to_i,
          requests_reset: response["anthropic-ratelimit-requests-reset"],
          tokens_limit: response["anthropic-ratelimit-tokens-limit"]&.to_i,
          tokens_remaining: response["anthropic-ratelimit-tokens-remaining"]&.to_i,
          tokens_reset: response["anthropic-ratelimit-tokens-reset"],
        }

        rate_limit_data[:requests_reset_ttl] = calculate_ttl(rate_limit_data[:requests_reset])
        rate_limit_data[:tokens_reset_ttl] = calculate_ttl(rate_limit_data[:tokens_reset])

        ::NewRelic::Agent.record_custom_event("AnthropicAPIRateLimit", **rate_limit_data)
      end

      def calculate_ttl(reset_time)
        return unless reset_time

        reset_time_obj = begin
          Time.zone.parse(reset_time)
        rescue
          nil
        end
        reset_time_obj ? (reset_time_obj - Time.zone.now).to_i : nil
      end

      def accumulate_response(prompt_type, model:, messages: [], path:, attempts:)
        $stdout.puts "Prompt type: #{prompt_type}"
        $stdout.puts "Anthropic model: #{model}"
        $stdout.puts "Writing response to: #{path}\n\n"

        complete_response = +""
        max_tokens_reached = false

        begin
          process_messages(messages, prompt_type: prompt_type, model: model, stream: true) do |_request, response|
            if response.code.to_i == 429
              $stderr.puts("\nRate limit exceeded: #{response.body}")
            elsif response.code.to_i >= 400
              $stderr.puts("\nError: #{response.body}")
            else
              buffer = +""
              response.read_body do |chunk|
                buffer << chunk
                until (line = buffer.slice!(/.+\n/)).nil?
                  complete_response << process_line(line.strip, path)

                  next unless (event = parse_event(line.strip))

                  if event["type"] == "message_delta" && event.dig("delta", "stop_reason") == "max_tokens"
                    max_tokens_reached = true
                  end
                end
              end

              unless buffer.empty?
                complete_response << process_line(buffer.strip, path)
              end
            end
          end
        rescue IOError
          $stderr.puts("\nStream closed")
        rescue StandardError => e
          $stderr.puts("\nAn error occurred: #{e.message}")
        ensure
          $stderr.puts("\nStream ended")
        end

        if max_tokens_reached && attempts.positive?
          messages << { role: "assistant", content: [{ type: "text", text: complete_response.strip }] }
          messages << { role: "user", content: [{ type: "text", text: "Please continue." }] }
          accumulate_response(
            prompt_type,
            model: model,
            messages: messages,
            path: path,
            attempts: attempts - 1,
          )
        end
      end

      def process_line(line, path)
        return +"" if line.empty?

        if line.start_with?("data:")
          json_data = line[5..-1]
          handle_data_event(json_data, path) || +""
        else
          +""
        end
      end

      def handle_data_event(json_data, path)
        event_data = JSON.parse(json_data)

        if event_data["type"] == "content_block_delta" && event_data.dig("delta", "type") == "text_delta"
          text = event_data.dig("delta", "text").to_s
          File.open(path, "a") { |f| f.print(text) }
          $stdout.print(text)
          text
        elsif event_data["type"] == "ping"
          $stdout.print(".")
        end
      rescue JSON::ParserError => e
        $stderr.puts("\nError parsing JSON: #{e.message} -- #{json_data}")
        +""
      end

      def parse_event(line)
        return if line.empty?

        if line.start_with?("data:")
          json_data = line[5..-1]
          begin
            JSON.parse(json_data)
          rescue
            nil
          end
        else
          nil
        end
      end
    end
  end
end
