# frozen_string_literal: true

class ApiController < ApplicationController
  include ActionController::Live

  class ChatLogTokenLimitExceeded < StandardError; end
  class InvalidCacheMarkerCount < StandardError; end

  CHAT_LOG_TOKEN_LIMIT = 50_000

  skip_before_action :verify_host!

  def stream
    chat_log = permitted_chat_log_params.as_json

    # Validate request before starting stream
    validate_cache_markers!(chat_log)
    count_chat_log_tokens!(chat_log) unless token_limit_disabled?

    # Validation passed, begin streaming
    perform_stream(chat_log)
  rescue InvalidCacheMarkerCount => error
    render(json: { error: { message: error.message } }, status: :bad_request)
  rescue ChatLogTokenLimitExceeded
    render(json: { error: { message: "Conversation horizon has arrived. 🤲" } }, status: :unprocessable_content)
  end

  def plain
    # Read plaintext body
    message_text = request.body.read.to_s.strip

    if message_text.blank?
      render(plain: "No message provided.", status: :bad_request)
      return
    end

    # Convert to chat_log format
    chat_log = [
      {
        "role" => "user",
        "content" => [
          {
            "type" => "text",
            "text" => message_text,
          },
        ],
      },
    ]

    # Make non-streaming request to Anthropic
    response = Prompts.messages(
      messages: chat_log,
      stream: false,
    )

    if response.code.to_i >= 400
      render(plain: "An error occurred.", status: :bad_gateway)
      return
    end

    # Parse response and extract text
    parsed = JSON.parse(response.body)
    response_text = parsed.dig("content", 0, "text") || ""

    render(plain: response_text)
  end

  def perform_stream(chat_log)
    # Track analytics
    track_stream_start(chat_log)

    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no" # Disable nginx buffering

    # Stream directly using SSE format
    Prompts.messages(
      messages: chat_log,
      stream: true,
    ) do |request, response|
      if response.code.to_i >= 400
        send_sse_event("error", { error: { message: response.body } })
      else
        stream_anthropic_response(request, response, chat_log)
      end
    end
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

  def token_limit_disabled?
    return false if request.headers["Token-Limit-Bypass-Key"].blank?
    return false if ENV["TOKEN_LIMIT_BYPASS_KEYS"].blank?

    valid_keys = ENV["TOKEN_LIMIT_BYPASS_KEYS"].split(",").map(&:strip)
    valid_keys.include?(request.headers["Token-Limit-Bypass-Key"])
  end

  def validate_cache_markers!(chat_log)
    cache_marker_count = chat_log.sum { |msg|
      Array(msg["content"]).count { |block| block["cache_control"].present? }
    }

    if cache_marker_count == 0
      raise InvalidCacheMarkerCount, "Cache marker required but not found"
    elsif cache_marker_count > 1
      raise InvalidCacheMarkerCount, "Multiple cache markers found (expected exactly one)"
    end
  end

  def count_chat_log_tokens!(chat_log)
    # Count just the userspace chat log, not the entire system prompt
    @chat_log_token_count = Prompts::Anthropic.count_tokens(
      system: [],
      messages: chat_log,
    )

    raise ChatLogTokenLimitExceeded if @chat_log_token_count > CHAT_LOG_TOKEN_LIMIT
  end

  def track_stream_start(chat_log)
    # Find the message and content block containing the cache marker
    cache_marker_message_index = nil
    cache_marker_block_index = nil

    chat_log.each_with_index do |msg, msg_idx|
      Array(msg["content"]).each_with_index do |block, block_idx|
        next if block["cache_control"].blank?

        cache_marker_message_index = msg_idx
        cache_marker_block_index = block_idx
        break
      end
      break if cache_marker_message_index
    end

    # Extract the frame (everything up to and including the cache marker content block)
    frame = if cache_marker_message_index && cache_marker_block_index
      # All messages before the marker message
      frame_messages = chat_log[0...cache_marker_message_index].dup

      # Plus the marker message with content sliced up to and including the marker block
      marker_message = chat_log[cache_marker_message_index].dup
      marker_message["content"] = Array(marker_message["content"])[0..cache_marker_block_index]
      frame_messages << marker_message

      frame_messages
    else
      # Fallback (shouldn't happen due to validation, but be safe)
      chat_log.first(1)
    end

    conversation_frame_id = Digest::SHA256.hexdigest(frame.to_json)

    # Hash includes: warmup (up to and including cache marker) + first 2 unique messages after
    messages_to_hash = if cache_marker_message_index
      warmup = chat_log[0..cache_marker_message_index]
      unique = chat_log[(cache_marker_message_index + 1)..-1]&.first(2) || []
      warmup + unique
    else
      # Fallback (shouldn't happen due to validation, but be safe)
      chat_log.first(2)
    end

    conversation_id = Digest::SHA256.hexdigest(messages_to_hash.to_json)

    ::NewRelic::Agent.record_custom_event(
      "ApiController: stream start",
      conversation_frame_id: conversation_frame_id,
      conversation_id: conversation_id,
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

          # Handle horizon warnings (unless token limit disabled)
          warning = handle_horizon_warning(current_event, warning, chat_log) unless token_limit_disabled?

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
      log_entry.permit(:role, content: [:type, :text, cache_control: [:type]])
    end
  end
end
