# frozen_string_literal: true

# app/jobs/stream_messages_job.rb
require "net/http"
require "active_support/core_ext/time/calculations"
require "action_view/helpers"

class StreamMessagesJob < ApplicationJob
  include ActionView::Helpers::DateHelper

  queue_as :default

  def perform(stream_id, chat_log)
    wait_for_ready(stream_id)

    payload = {
      model: Anthropic.model,
      max_tokens: 4000,
      stream: true,
      temperature: 0.7,
      system: Anthropic.system_prompt,
      messages: Anthropic.conversation_starters + chat_log,
    }

    begin
      Anthropic.api_request(payload) do |response|
        if response.code.to_i == 429
          handle_rate_limit_error(response, stream_id)
        elsif response.code.to_i >= 400
          broadcast(stream_id, "error", { error: { message: response.body } })
        else
          buffer = +""
          response.read_body do |chunk|
            buffer << chunk
            until (line = buffer.slice!(/.+\n/)).nil?
              process_line(line.strip, stream_id)
            end
          end
          process_line(buffer.strip, stream_id) unless buffer.empty?
        end
      end
    rescue IOError
      Rails.logger.info("Stream closed")
    ensure
      broadcast(stream_id, "end", nil)
    end
  end

  private

  def wait_for_ready(stream_id)
    timeout = 10.seconds.from_now
    Kernel.sleep(0.1) until Rails.cache.read("stream_ready_#{stream_id}") || Time.current > timeout

    unless Rails.cache.read("stream_ready_#{stream_id}")
      broadcast(stream_id, "error", { error: { message: "Stream not ready in time" } })
      raise "Stream not ready in time"
    end
  end

  def process_line(line, stream_id)
    return if line.empty?

    if line.start_with?("event:")
      @current_event = line[6..-1].strip
    elsif line.start_with?("data:")
      json_data = line[5..-1]
      handle_data_event(json_data, stream_id)
    else
      Rails.logger.warn("Unknown line format: #{line}")
    end
  end

  def handle_data_event(json_data, stream_id)
    event_data = JSON.parse(json_data)
    broadcast(stream_id, @current_event || "message", event_data)
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing JSON: #{e.message} -- #{json_data}")
  end

  def broadcast(stream_id, event, data)
    @sequence_number ||= 0

    message = { event: event, data: data, sequence_number: @sequence_number }
    ActionCable.server.broadcast("stream_channel_#{stream_id}", message)
    @sequence_number += 1
  end

  def handle_rate_limit_error(response, stream_id)
    requests_limit = response["anthropic-ratelimit-requests-limit"]
    requests_remaining = response["anthropic-ratelimit-requests-remaining"]
    requests_reset = Time.zone.parse(response["anthropic-ratelimit-requests-reset"])

    tokens_limit = response["anthropic-ratelimit-tokens-limit"]
    tokens_remaining = response["anthropic-ratelimit-tokens-remaining"]
    tokens_reset = Time.zone.parse(response["anthropic-ratelimit-tokens-reset"])

    Rails.logger.warn("Rate limit exceeded: " \
      "requests_limit=#{requests_limit}, " \
      "requests_remaining=#{requests_remaining}, " \
      "requests_reset=#{requests_reset}, " \
      "tokens_limit=#{tokens_limit}, " \
      "tokens_remaining=#{tokens_remaining}, " \
      "tokens_reset=#{tokens_reset}")

    applicable_reset = [requests_reset, tokens_reset].max
    reset_type = applicable_reset == requests_reset ? "request" : "token"

    human_readable_reset = distance_of_time_in_words(Time.zone.now, applicable_reset).sub("about ", "~")
    error_message = "Rate limit exceeded for #{reset_type}s. The limit will clear in #{human_readable_reset}. :)"

    broadcast(stream_id, "error", { error: { message: error_message } })
  end
end
