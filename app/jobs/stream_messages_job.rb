# frozen_string_literal: true

# app/jobs/stream_messages_job.rb
require "net/http"
require "active_support/core_ext/time/calculations"
require "action_view/helpers"

class StreamMessagesJob < ApplicationJob
  include ActionView::Helpers::DateHelper

  queue_as :default

  def perform(message_id)
    wait_for_ready(message_id)

    message = ChatMessage.find(message_id)
    chat_messages = ChatMessage.by_chat(message.chat_id).map(&:to_anthropic_user_message)

    payload = {
      model: Anthropic.model,
      max_tokens: 2000,
      stream: true,
      temperature: 0.7,
      system: Anthropic.system_prompt,
      messages: Anthropic.conversation_starters + chat_messages,
    }

    begin
      Anthropic.api_request(payload) do |response|
        if response.code.to_i == 429
          handle_rate_limit_error(response, message_id)
        elsif response.code.to_i >= 400
          broadcast(message_id, "error", { error: { message: response.body } })
        else
          text = +""
          buffer = +""
          response.read_body do |chunk|
            buffer << chunk
            until (line = buffer.slice!(/.+\n/)).nil?
              text << process_line(line.strip, message_id)
            end
          end
          text << process_line(buffer.strip, message_id) unless buffer.empty?

          ChatMessage.create!(
            chat_id: message.chat_id,
            role: "assistant",
            text: text,
          )
        end
      end
    rescue IOError
      Rails.logger.info("Stream closed")
    ensure
      broadcast(message_id, "end", nil)
    end
  end

  private

  def wait_for_ready(message_id)
    timeout = 10.seconds.from_now
    ready = false

    loop do
      Kernel.sleep(0.1)
      ready = ChatMessage.client_is_ready?(message_id)

      break if ready
      break if Time.current > timeout
    end

    unless ready
      broadcast(message_id, "error", { error: { message: "Stream not ready in time" } })
      raise "Stream not ready in time"
    end
  end

  def process_line(line, message_id)
    return "" if line.empty?

    if line.start_with?("event:")
      @current_event = line[6..-1].strip
      ""
    elsif line.start_with?("data:")
      json_data = line[5..-1]
      handle_data_event(json_data, message_id)
    else
      Rails.logger.warn("Unknown line format: #{line}")
      "Error"
    end
  end

  def handle_data_event(json_data, message_id)
    event_data = JSON.parse(json_data)
    broadcast(message_id, @current_event || "message", event_data)

    case event_data["type"]
    when "content_block_start"
      event_data.dig("content_block", "text")
    when "content_block_delta"
      event_data.dig("delta", "text")
    else
      ""
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing JSON: #{e.message} -- #{json_data}")
    "Error"
  end

  def broadcast(message_id, event, data)
    @sequence_number ||= 0

    message = { event: event, data: data, sequence_number: @sequence_number }
    ActionCable.server.broadcast("stream_channel_#{message_id}", message)
    @sequence_number += 1
  end

  def handle_rate_limit_error(response, message_id)
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

    broadcast(message_id, "error", { error: { message: error_message } })
  end
end
