# frozen_string_literal: true

class ApiController < ApplicationController
  include ActionController::Live

  class ChatLogTokenLimitExceeded < StandardError; end

  CHAT_LOG_TOKEN_LIMIT = 50_000

  skip_before_action :verify_host!

  def stream
    chat_log = permitted_chat_log_params.as_json

    # Determine prompt type based on opening message
    opening_message = chat_log.dig(0, "content", 0, "text")
    prompt_type = determine_prompt_type(opening_message)

    # Count tokens and enforce limit
    count_chat_log_tokens!(chat_log)

    # Track analytics
    track_stream_start(chat_log, prompt_type)

    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no" # Disable nginx buffering

    # Stream directly using SSE format
    Prompts.messages(
      model: Prompts::Anthropic::CHAT,
      messages: chat_log,
      prompt_type: prompt_type,
      stream: true,
    ) do |request, response|
      if response.code.to_i >= 400
        send_sse_event("error", { error: { message: response.body } })
      else
        stream_anthropic_response(request, response, chat_log)
      end
    end
  rescue ChatLogTokenLimitExceeded
    send_sse_event("error", { error: { message: "Conversation horizon has arrived; please start over to continue. 🤲" } })
  rescue IOError
    send_sse_event("error", { error: { message: "Connection error" } })
  rescue StandardError => error
    Rollbar.error(error)
    Rails.logger.error("API stream error: #{error.message}\n#{error.backtrace.join("\n")}")
    send_sse_event("error", { error: { message: "An unexpected error occurred" } })
  ensure
    send_sse_event("end", nil)
    response.stream.close
  end

  private

  def determine_prompt_type(opening_message)
    if opening_message.to_s.match?(/\AI\'m a (slow|fast) (reader|writer)\z/)
      "clients/chat"
    else
      "clients/api"
    end
  end

  def count_chat_log_tokens!(chat_log)
    # Count just the userspace chat log, not the entire system prompt
    @chat_log_token_count = Prompts::Anthropic.count_tokens(
      model: Prompts::Anthropic::CHAT,
      system: [],
      messages: chat_log,
    )

    raise ChatLogTokenLimitExceeded if @chat_log_token_count > CHAT_LOG_TOKEN_LIMIT
  end

  def track_stream_start(chat_log, prompt_type)
    conversation_id = Digest::SHA256.hexdigest(chat_log.first(2).to_json)

    ::NewRelic::Agent.record_custom_event(
      "ApiController: stream start",
      conversation_id: conversation_id,
      prompt_type: prompt_type,
      chat_log_depth: chat_log.size,
      chat_log_token_count: @chat_log_token_count,
    )
  end

  def stream_anthropic_response(request, response, chat_log)
    buffer = +""
    current_event = nil
    warning = nil

    response.read_body do |chunk|
      buffer << chunk

      until (line = buffer.slice!(/.+\n/)).nil?
        line = line.strip
        next if line.empty?

        if line.start_with?("event:")
          current_event = line[6..-1].strip
        elsif line.start_with?("data:")
          json_data = line[5..-1]
          event_data = JSON.parse(json_data)

          # Handle horizon warnings
          warning = handle_horizon_warning(current_event, warning, chat_log)

          send_sse_event(current_event || "message", event_data)
        end
      end
    end

    # Process any remaining buffer
    process_remaining_buffer(buffer, current_event)
  end

  def handle_horizon_warning(current_event, warning, chat_log)
    case current_event
    when "message_start"
      check_horizon_threshold(chat_log)
    when "content_block_stop"
      send_horizon_warning_if_needed(warning)
      nil
    else
      warning
    end
  end

  def check_horizon_threshold(chat_log)
    usage = (@chat_log_token_count / CHAT_LOG_TOKEN_LIMIT.to_f)
    return if usage < 0.9

    usage_percentage = (usage * 100).floor
    proposed_warning = "Memory space #{usage_percentage}% utilized; conversation horizon approaching"

    # Only warn if this warning hasn't appeared before
    chat_log.to_s.exclude?(proposed_warning) ? proposed_warning : nil
  end

  def send_horizon_warning_if_needed(warning)
    return unless warning

    send_sse_event("content_block_delta", {
      type: "content_block_delta",
      index: 0,
      delta: {
        type: "text_delta",
        text: "\n\n⚠️\u00A0Lightward AI system notice: #{warning}",
      },
    })
  end

  def process_remaining_buffer(buffer, current_event)
    return if buffer.strip.empty?

    line = buffer.strip
    return unless line.start_with?("data:")

    json_data = line[5..-1]
    event_data = JSON.parse(json_data)
    send_sse_event(current_event || "message", event_data)
  end

  def send_sse_event(event, data)
    response.stream.write("event: #{event}\n")
    response.stream.write("data: #{data.to_json}\n\n") if data
  end

  def permitted_chat_log_params
    params.require(:chat_log).map do |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    end
  end
end
