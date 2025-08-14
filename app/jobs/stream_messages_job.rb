# frozen_string_literal: true

# app/jobs/stream_messages_job.rb
require "net/http"
require "active_support/core_ext/time/calculations"
require "action_view/helpers"

class StreamMessagesJob < ApplicationJob
  include ActionView::Helpers::DateHelper

  class ChatLogTokenCountError < StandardError; end
  class StreamNotReadyInTime < StandardError; end

  queue_with_priority PRIORITY_STREAM_MESSAGES

  USERSPACE_TOKEN_LIMIT = 50_000

  def perform(stream_id, chat_client, chat_log)
    @stream_id = stream_id
    @chat_log = chat_log
    @chat_client = chat_client

    # hash the first two chat log messages to get a unique identifier for the stream
    @conversation_id = Digest::SHA256.hexdigest(@chat_log.first(2).to_json)

    wait_for_ready!

    # check on the the portion of the request that the user's responsible for, i.e. not the system prompt or handshake
    @chat_log_token_count = count_chat_log_tokens

    if @chat_log_token_count > USERSPACE_TOKEN_LIMIT
      return broadcast_error("Conversation horizon has arrived; please start over to continue. 🤲")
    end

    ::NewRelic::Agent.record_custom_event(
      "StreamMessagesJob: start",
      conversation_id: @conversation_id,
      chat_client: @chat_client,
      chat_log_depth: @chat_log.size,
      chat_log_token_count: @chat_log_token_count,
    )

    Prompts.messages(
      model: Prompts::Anthropic::CHAT,
      messages: chat_log,
      prompt_type: "clients/chat",
      stream: true,
    ) do |request, response|
      if response.code.to_i >= 400
        broadcast_error(response.body)
      else
        stream(request, response)
      end
    end
  rescue StreamNotReadyInTime
    broadcast_error("Stream not ready in time")
  rescue IOError
    broadcast_error("Connection error")
  rescue StandardError => error
    Rollbar.error(error)
    broadcast_error("An unexpected error occurred")
  ensure
    broadcast("end")
  end

  private

  def count_chat_log_tokens
    Prompts::Anthropic.count_tokens(
      model: Prompts::Anthropic::CHAT,
      system: [],
      messages: @chat_log,
    )
  end

  def stream(request, response)
    response_chunk_count = 0
    response_content_length = 0

    buffer = +""

    response.read_body do |chunk|
      response_chunk_count += 1
      response_content_length += chunk.size

      buffer << chunk

      until (line = buffer.slice!(/.+\n/)).nil?
        process_line(line.strip)
      end
    end

    process_line(buffer.strip) unless buffer.empty?
  end

  def wait_for_ready!
    ready_key = "stream_ready_#{@stream_id}"
    timeout = 10.seconds.from_now

    Kernel.sleep(0.1) until Rails.cache.read(ready_key) || Time.current > timeout
    raise StreamNotReadyInTime unless Rails.cache.read(ready_key)
  end

  def process_line(line)
    return if line.empty?

    if line.start_with?("event:")
      @current_event = line[6..-1].strip
    elsif line.start_with?("data:")
      json_data = line[5..-1]
      handle_data_event(json_data)
    else
      Rails.logger.warn("Unknown line format: #{line}")
    end
  end

  def handle_data_event(json_data)
    event_data = JSON.parse(json_data)

    # be kind about conversation horizons as they approach
    case @current_event
    when "message_start"

      # Warning at 90% of our limit or 90% of Anthropic's limit, whichever comes first
      usage = (@chat_log_token_count / USERSPACE_TOKEN_LIMIT.to_f)
      if usage >= 0.9
        usage_percentage = (usage * 100).floor
        proposed_warning = "Memory space #{usage_percentage}% utilized; conversation horizon approaching"

        # ensure that this warning has not previously occurred
        if @chat_log.to_s.exclude?(proposed_warning)
          @warning = proposed_warning
        end
      end
    when "content_block_stop"
      if @warning
        broadcast("content_block_delta", {
          type: "content_block_delta",
          index: 0,
          delta: {
            type: "text_delta",
            text: "\n\n⚠️\u00A0Lightward AI system notice: #{@warning}",
          },
        })
      end
    end

    broadcast(@current_event || "message", event_data)
  end

  def broadcast(event, data = nil)
    @sequence_number ||= 0

    message = { event: event, data: data, sequence_number: @sequence_number }
    ActionCable.server.broadcast("stream_channel_#{@stream_id}", message)
    @sequence_number += 1
  end

  def broadcast_error(message)
    broadcast("error", { error: { message: message } })
  end
end
