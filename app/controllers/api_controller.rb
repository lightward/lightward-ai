# frozen_string_literal: true

class ApiController < ApplicationController
  include ActionController::Live

  class ChatLogTokenLimitExceeded < StandardError; end
  class InvalidCacheMarkerCount < StandardError; end

  CHAT_LOG_TOKEN_LIMIT = 50_000
  FIRST_PARTY_USAGE_CLIENTS = {
    "reader" => "lightward_reader",
    "writer" => "lightward_writer",
  }.freeze
  REPORTED_USAGE_CLIENTS = FIRST_PARTY_USAGE_CLIENTS.merge(
    "helpscout" => "helpscout",
    "yours" => "yours",
    "softer" => "softer",
  ).freeze
  ANTHROPIC_USAGE_TOKEN_KEYS = [
    "input_tokens",
    "output_tokens",
    "cache_creation_input_tokens",
    "cache_read_input_tokens",
  ].freeze
  TELEMETRY_HMAC_NAMESPACE = "lai-usage-telemetry-v1"

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

  def system
    messages = Prompts.build_system_prompt

    respond_to do |format|
      format.json { render(json: messages) }
      format.text { render(plain: messages.pluck(:text).join("\n\n")) }
      format.any  { render(plain: messages.pluck(:text).join("\n\n")) }
    end
  end

  def plain
    chat_log = nil
    newrelic_event_recorded = false

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

    # Check conversation horizon
    count_chat_log_tokens!(chat_log) unless token_limit_disabled?

    # Make non-streaming request to Anthropic
    response = Prompts.messages(
      messages: chat_log,
      stream: false,
    )

    if response.code.to_i >= 400
      record_newrelic_event(chat_log, conversation_frame_id: "plain")
      newrelic_event_recorded = true
      render(plain: "An error occurred.", status: :bad_gateway)
      return
    end

    # Parse response and extract text
    parsed = JSON.parse(response.body)
    response_text = parsed.dig("content", 0, "text") || ""
    record_newrelic_event(chat_log, conversation_frame_id: "plain", anthropic_usage: parsed["usage"])
    newrelic_event_recorded = true

    # Append horizon warning if approaching limit
    unless token_limit_disabled?
      warning = check_horizon_threshold(chat_log)
      response_text += "\n\n⚠️\u00A0Lightward AI system notice: #{warning}" if warning
    end

    render(plain: response_text)
  rescue ChatLogTokenLimitExceeded
    render(plain: "Conversation horizon has arrived. 🤲", status: :unprocessable_content)
  rescue StandardError => error
    Rollbar.error(error)
    Rails.logger.error("API plain error: #{error.message}\n#{error.backtrace.join("\n")}")
    record_newrelic_event(chat_log, conversation_frame_id: "plain") if chat_log.present? && !newrelic_event_recorded
    render(plain: "An error occurred.", status: :bad_gateway)
  end

  def perform_stream(chat_log)
    conversation_frame_id, conversation_id = compute_conversation_ids(chat_log)
    anthropic_usage = {}

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
        stream_anthropic_response(request, response, chat_log, anthropic_usage)
      end
    end
  rescue IOError
    send_sse_event("error", { error: { message: "Connection error" } })
  rescue StandardError => error
    Rollbar.error(error)
    Rails.logger.error("API stream error: #{error.message}\n#{error.backtrace.join("\n")}")
    send_sse_event("error", { error: { message: "An unexpected error occurred" } })
  ensure
    record_newrelic_event(
      chat_log,
      conversation_frame_id: conversation_frame_id,
      conversation_id: conversation_id,
      anthropic_usage: anthropic_usage,
    ) if conversation_frame_id
    send_sse_event("end", nil)
    response.stream.close
  end

  private

  def token_limit_disabled?
    token_limit_bypassed?
  end

  def token_limit_bypassed?
    return @token_limit_bypassed if defined?(@token_limit_bypassed)

    @token_limit_bypassed = bypass_key_valid?
  end

  def bypass_key
    request.headers["Token-Limit-Bypass-Key"].to_s.strip.presence
  end

  def reported_usage_client
    return @reported_usage_client if defined?(@reported_usage_client)

    requested_client = request.headers["X-LAI-Usage-Client"].presence || params[:usage_client]
    @reported_usage_client = REPORTED_USAGE_CLIENTS[normalize_usage_client(requested_client)]
  end

  def bypass_key_valid?
    key = bypass_key
    return false if key.blank?
    return false if ENV["TOKEN_LIMIT_BYPASS_KEYS"].blank?

    ENV["TOKEN_LIMIT_BYPASS_KEYS"].split(",").map(&:strip).any? { |valid_key|
      secure_token_match?(key, valid_key)
    }
  end

  def secure_token_match?(candidate, expected)
    return false if candidate.blank? || expected.blank?
    return false unless candidate.bytesize == expected.bytesize

    ActiveSupport::SecurityUtils.secure_compare(candidate, expected)
  end

  def usage_client
    if reported_usage_client.present?
      reported_usage_client
    elsif bypass_key_valid?
      "external_bypass"
    else
      "#{action_name}_unknown"
    end
  end

  def normalize_usage_client(client)
    client.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, "")
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

  def compute_conversation_ids(chat_log)
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
      frame_messages = chat_log[0...cache_marker_message_index].dup
      marker_message = chat_log[cache_marker_message_index].dup
      marker_message["content"] = Array(marker_message["content"])[0..cache_marker_block_index]
      frame_messages << marker_message
      frame_messages
    else
      chat_log.first(1)
    end

    conversation_frame_id = Digest::SHA256.hexdigest(frame.to_json)

    # Hash includes: warmup (up to and including cache marker) + first 2 unique messages after
    messages_to_hash = if cache_marker_message_index
      warmup = chat_log[0..cache_marker_message_index]
      unique = chat_log[(cache_marker_message_index + 1)..-1]&.first(2) || []
      warmup + unique
    else
      chat_log.first(2)
    end

    conversation_id = Digest::SHA256.hexdigest(messages_to_hash.to_json)

    [conversation_frame_id, conversation_id]
  end

  def record_newrelic_event(chat_log, conversation_frame_id:, conversation_id: nil, anthropic_usage: nil)
    normalized_usage = normalize_anthropic_usage(anthropic_usage)

    ::NewRelic::Agent.record_custom_event(
      "ApiController: request",
      conversation_frame_id: conversation_frame_id,
      conversation_id: conversation_id,
      usage_client: usage_client,
      usage_conversation_id: usage_conversation_id(conversation_id),
      usage_subject_id: usage_subject_id,
      token_limit_bypassed: token_limit_bypassed?,
      anthropic_model: Prompts::Anthropic::MODEL,
      chat_log_depth: chat_log.size,
      chat_log_token_count: @chat_log_token_count,
      input_tokens: normalized_usage["input_tokens"],
      output_tokens: normalized_usage["output_tokens"],
      cache_creation_input_tokens: normalized_usage["cache_creation_input_tokens"],
      cache_read_input_tokens: normalized_usage["cache_read_input_tokens"],
      estimated_cost_usd: estimated_cost_usd(normalized_usage),
    )
  end

  def usage_conversation_id(conversation_id)
    hmac_header(request.headers["X-LAI-Conversation-Key"], "conversation") || conversation_id
  end

  def usage_subject_id
    hmac_header(request.headers["X-LAI-Subject-Key"], "subject")
  end

  def hmac_header(value, field)
    client = reported_usage_client
    return if client.blank?

    value = value.to_s
    return if value.blank?

    scoped_value = [TELEMETRY_HMAC_NAMESPACE, client, field, value].join(":")
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, scoped_value)
  end

  def normalize_anthropic_usage(anthropic_usage)
    usage = {}
    anthropic_usage ||= {}

    ANTHROPIC_USAGE_TOKEN_KEYS.each do |key|
      usage[key] = anthropic_usage[key] if anthropic_usage.key?(key)
    end

    usage
  end

  def estimated_cost_usd(anthropic_usage)
    return if anthropic_usage.values.all?(&:nil?)

    cost = Prompts::Anthropic::PRICING_USD_PER_MILLION.sum { |key, usd_per_million|
      anthropic_usage[key].to_i * usd_per_million / 1_000_000.0
    }

    cost.round(8)
  end

  def stream_anthropic_response(request, response, chat_log, anthropic_usage)
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
          capture_anthropic_usage!(anthropic_usage, current_event, event_data)

          # Handle horizon warnings (unless token limit disabled)
          warning = handle_horizon_warning(current_event, warning, chat_log) unless token_limit_disabled?

          send_sse_event(current_event || "message", event_data)
        end
      end
    end

    # Process any remaining buffer
    process_remaining_buffer(buffer, current_event, anthropic_usage)
  end

  def capture_anthropic_usage!(anthropic_usage, current_event, event_data)
    usage = case current_event
    when "message_start"
      event_data.dig("message", "usage")
    when "message_delta"
      event_data["usage"]
    end

    return unless usage.is_a?(Hash)

    ANTHROPIC_USAGE_TOKEN_KEYS.each do |key|
      anthropic_usage[key] = usage[key] if usage.key?(key)
    end
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

  def process_remaining_buffer(buffer, current_event, anthropic_usage)
    return if buffer.strip.empty?

    line = buffer.strip
    return unless line.start_with?("data:")

    json_data = line[5..-1]
    event_data = JSON.parse(json_data)
    capture_anthropic_usage!(anthropic_usage, current_event, event_data)
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
