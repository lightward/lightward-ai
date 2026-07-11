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
  ANTHROPIC_USAGE_TOKEN_KEYS = [
    "input_tokens",
    "output_tokens",
    "cache_creation_input_tokens",
    "cache_read_input_tokens",
  ].freeze
  # Cache writes bill by TTL tier (5m at 1.25x base, 1h at 2x); the API
  # reports the split under usage.cache_creation. Captured flattened, so
  # cost accounting can price each tier at its own rate.
  ANTHROPIC_CACHE_CREATION_KEYS = {
    "ephemeral_5m_input_tokens" => "cache_creation_5m_input_tokens",
    "ephemeral_1h_input_tokens" => "cache_creation_1h_input_tokens",
  }.freeze
  TELEMETRY_HMAC_NAMESPACE = "lai-usage-telemetry-v1"
  BUDGET_EXCEEDED_MESSAGE = "Shared-capacity budget reached for now. The door stays open — just paced. Please try again later. 🤲"
  class << self
    # The pacing message is a speech act taken involuntarily by Lightward
    # AI's seat during its turn (see the horizon warning for prior art), so
    # it is composed here — in one place, in the server's care — never in a
    # client. It carries the two things a paced person needs: when the door
    # reopens, in human time, and a way to reach a human if the pacing
    # caught something it shouldn't have.
    def budget_exceeded_message(retry_after_seconds)
      parts = [BUDGET_EXCEEDED_MESSAGE]
      if retry_after_seconds.to_i.positive?
        parts << "You can pick this back up in about #{humanize_seconds(retry_after_seconds)}."
      end
      parts << "And if this pacing seems out of step with what you were doing, " \
        "email team@lightward.com — a human reads these."
      parts.join(" ")
    end

    def humanize_seconds(seconds)
      minutes = (seconds / 60.0).ceil
      return "#{minutes} #{"minute".pluralize(minutes)}" if minutes < 90

      hours = (minutes / 60.0).round
      "#{hours} #{"hour".pluralize(hours)}"
    end
  end

  skip_before_action :verify_host!

  def stream
    chat_log = permitted_chat_log_params.as_json

    # Validate request before starting stream
    validate_cache_markers!(chat_log)
    conversation_frame_id, conversation_id = compute_conversation_ids(chat_log)
    # Observation (the ids above) and intervention part ways here: the
    # budget scope uses its own collision-resistant key, nil until the
    # conversation has words of its own.
    check_usage_budget!(budget_conversation_value(chat_log, conversation_frame_id))
    count_chat_log_tokens!(chat_log) unless token_limit_disabled?

    # Validation passed, begin streaming
    perform_stream(chat_log, conversation_frame_id, conversation_id)
  rescue InvalidCacheMarkerCount => error
    render(json: { error: { message: error.message } }, status: :bad_request)
  rescue ChatLogTokenLimitExceeded
    render(json: { error: { message: "Conversation horizon has arrived. 🤲" } }, status: :unprocessable_content)
  rescue UsageBudget::Exceeded => error
    @budget_verdict = error.verdict
    @budget_enforced = true
    record_newrelic_event(chat_log, conversation_frame_id: conversation_frame_id, conversation_id: conversation_id)
    retry_after = UsageBudget.retry_after_seconds(error.verdict)
    response.headers["Retry-After"] = retry_after.to_s
    # retry_after rides in the body too — minimal clients parse JSON but
    # never look at headers, and the pacing signal should be hard to miss.
    render(
      json: { error: { message: self.class.budget_exceeded_message(retry_after), retry_after: retry_after } },
      status: :too_many_requests,
    )
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

    # Check shared-resource budgets, then the conversation horizon
    check_usage_budget!
    count_chat_log_tokens!(chat_log) unless token_limit_disabled?

    anthropic_responded = false
    anthropic_usage = nil
    response_text = nil
    begin
      # Make non-streaming request to Anthropic
      response = Prompts.messages(
        messages: chat_log,
        stream: false,
      )
      anthropic_responded = true

      if response.code.to_i >= 400
        record_newrelic_event(chat_log, conversation_frame_id: "plain")
        newrelic_event_recorded = true
        render(plain: "An error occurred.", status: :bad_gateway)
        return
      end

      # Parse response and extract text
      parsed = JSON.parse(response.body)
      anthropic_usage = parsed["usage"]
      response_text = parsed.dig("content", 0, "text") || ""
      record_newrelic_event(chat_log, conversation_frame_id: "plain", anthropic_usage: anthropic_usage)
      newrelic_event_recorded = true
    ensure
      # Settles on every exit — success, early return, or a raise on its way
      # to the rescues below — so spend can't escape the budget.
      settle_usage_budget(anthropic_responded, anthropic_usage)
    end

    # Append horizon warning if approaching limit
    unless token_limit_disabled?
      warning = check_horizon_threshold(chat_log)
      response_text += "\n\n⚠️\u00A0Lightward AI system notice: #{warning}" if warning
    end

    render(plain: response_text)
  rescue ChatLogTokenLimitExceeded
    render(plain: "Conversation horizon has arrived. 🤲", status: :unprocessable_content)
  rescue UsageBudget::Exceeded => error
    @budget_verdict = error.verdict
    @budget_enforced = true
    record_newrelic_event(chat_log, conversation_frame_id: "plain")
    retry_after = UsageBudget.retry_after_seconds(error.verdict)
    # self.response: the local `response` above shadows the controller's
    self.response.headers["Retry-After"] = retry_after.to_s
    # The retry window rides in the body too — the pacing signal should be
    # hard to miss, whether a client reads headers or bodies.
    render(
      plain: "#{self.class.budget_exceeded_message(retry_after)}\n\nRetry-After: #{retry_after} seconds",
      status: :too_many_requests,
    )
  rescue StandardError => error
    Rollbar.error(error)
    Rails.logger.error("API plain error: #{error.message}\n#{error.backtrace.join("\n")}")
    record_newrelic_event(chat_log, conversation_frame_id: "plain") if chat_log.present? && !newrelic_event_recorded
    render(plain: "An error occurred.", status: :bad_gateway)
  end

  def perform_stream(chat_log, conversation_frame_id, conversation_id)
    anthropic_usage = {}
    anthropic_responded = false

    response.headers["Content-Type"] = "text/event-stream"
    response.headers["Cache-Control"] = "no-cache"
    response.headers["X-Accel-Buffering"] = "no" # Disable nginx buffering

    # Stream directly using SSE format
    Prompts.messages(
      messages: chat_log,
      stream: true,
    ) do |request, response|
      anthropic_responded = true
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
    settle_usage_budget(anthropic_responded, anthropic_usage)
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

  # Shared-resource budgets: open with limits, not closed. Skipped entirely
  # for trusted bypass traffic and for configured external clients (the
  # operator's explicit allowlist — first-party and unknown traffic is what
  # budgets protect right now; note the client header is an unauthenticated
  # claim, a courtesy exemption rather than a security boundary). Inert
  # unless LAI_BUDGET_MODE is set. In observe mode an over-budget verdict is
  # recorded but never blocks; in enforce mode it raises
  # UsageBudget::Exceeded before any Anthropic spend.
  def check_usage_budget!(conversation_id = nil)
    return if token_limit_bypassed?
    return if budget_exempt_client?
    return unless UsageBudget.active?

    # One instant drives the key salt and the counter buckets, at admission
    # and settlement both — a request spanning a window boundary stays
    # attributed to its admission time.
    @budget_at = Time.now.utc
    @budget_scopes = {
      "source" => UsageBudget.scope_key("source", budget_source_value, at: @budget_at),
      "conversation" => UsageBudget.scope_key("conversation", conversation_id, at: @budget_at),
    }.compact

    # Counts the request atomically with the read; raises UsageBudget::Exceeded
    # (carrying the verdict, admission refunded) in enforce mode when over.
    @budget_verdict = UsageBudget.admit!(@budget_scopes, at: @budget_at)
  end

  def budget_exempt_client?
    client = reported_usage_client
    client.present? && configured_external_usage_clients.value?(client)
  end

  # Fly's proxy sets Fly-Client-IP authoritatively on every proxied request.
  # Behind it, remote_ip resolves to a shared edge address — which would fold
  # every visitor into one source budget. Fall back to remote_ip off-Fly
  # (development, test).
  def budget_source_value
    request.headers["Fly-Client-IP"].presence || request.remote_ip
  end

  # Settle the admission made in check_usage_budget!: fold in the actual
  # cost when Anthropic responded; refund the request count when it never
  # did (an infrastructure failure spends nothing, so it counts nothing).
  # No-op when nothing was admitted (budgets off/skipped, or store down).
  def settle_usage_budget(anthropic_responded, anthropic_usage = nil)
    return if @budget_scopes.blank? || @budget_verdict.nil?

    if anthropic_responded
      cost = estimated_cost_usd(normalize_anthropic_usage(anthropic_usage))
      UsageBudget.settle!(@budget_scopes, cost_usd: cost || 0, at: @budget_at)
    else
      UsageBudget.refund!(@budget_scopes, at: @budget_at)
    end
  end

  def budget_state
    return if @budget_scopes.blank?
    return "untracked" if @budget_verdict.nil?

    @budget_verdict.over? ? "over" : "ok"
  end

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

    header_client = normalize_usage_client(request.headers["X-LAI-Usage-Client"])
    param_client = normalize_usage_client(params[:usage_client])
    @reported_usage_client = if header_client.present?
      reported_usage_clients[header_client]
    else
      FIRST_PARTY_USAGE_CLIENTS[param_client]
    end
  end

  def reported_usage_clients
    configured_external_usage_clients.merge(FIRST_PARTY_USAGE_CLIENTS)
  end

  def configured_external_usage_clients
    ENV["LAI_REPORTED_USAGE_CLIENTS"].to_s.split(",").filter_map { |client|
      normalized_client = normalize_usage_client(client)
      [normalized_client, normalized_client] if normalized_client.present?
    }.to_h
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
    reported_usage_client || "#{action_name}_unknown"
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

  # The budget layer's conversation key — deliberately its own derivation,
  # separate from compute_conversation_ids. Those ids were built for
  # observation, where a rare collision is harmless dashboard noise; a
  # budget key is intervention, where a collision paces an innocent
  # stranger (this happened). Enforcement needs collision resistance that
  # observation never promised.
  #
  # The key anchors on three messages: the guest's words just before the
  # first genuine assistant reply, that reply, and the guest's words just
  # after it. Suggested prompts make first user messages identical across
  # strangers, and the staged opening asks for a single-line reply — short
  # enough that two strangers can receive the same line — so no one of
  # these is unique alone; together they are. System speech (the replayed
  # notices and errors, canned and identical for everyone who hit the same
  # wall) is excluded throughout. The anchors are fixed points of an
  # append-only log, so the key is stable at every later depth.
  #
  # Until all three anchors exist there is nothing unique to key on, and
  # this returns nil: the request rides on the source scope alone, which
  # already bounds rapid-fire from one place. (Known, accepted: a log shaped
  # to never seed — reply-less, all-notice, or marker-at-tail — is bounded
  # by source caps only. That traffic could always rotate conversation keys
  # by varying bytes anyway; the source scope was and remains the backstop.)
  def budget_conversation_value(chat_log, conversation_frame_id)
    post = post_marker_messages(chat_log).reject { |msg| system_speech?(msg) }

    reply_index = post.find_index { |msg| msg["role"] == "assistant" }
    return unless reply_index

    guest_after = post[(reply_index + 1)..-1].find { |msg| msg["role"] == "user" }
    return unless guest_after

    opening = [post[0...reply_index].last, post[reply_index], guest_after].compact
    "#{conversation_frame_id}:#{Digest::SHA256.hexdigest(opening.to_json)}"
  end

  # Everything after the cache marker BLOCK — including any content blocks
  # that share the marker's message but follow the marker, which belong to
  # the conversation, not the frame.
  def post_marker_messages(chat_log)
    chat_log.each_with_index do |msg, msg_idx|
      blocks = Array(msg["content"])
      block_idx = blocks.find_index { |block| block["cache_control"].present? }
      next unless block_idx

      rest = chat_log[(msg_idx + 1)..-1] || []
      trailing = blocks[(block_idx + 1)..-1] || []
      return rest if trailing.empty?

      return [msg.merge("content" => trailing)] + rest
    end
    []
  end

  # Words placed in the assistant's seat by the system rather than spoken
  # by it. Two recognizable forms: the first-party client's replay prefix
  # (⚠️, with or without the emoji variation selector), and the server's
  # own canned bodies saved verbatim by simpler clients.
  SYSTEM_SPEECH_RE = %r{
    \A[[:space:]]*
    (?:
      ⚠️?[[:space:]]*Lightward\ AI\ system\ (?:notice|error):
      | Shared-capacity\ budget\ reached\ for\ now\.
      | Conversation\ horizon\ has\ arrived\.
    )
  }x
  def system_speech?(msg)
    return false unless msg["role"] == "assistant"

    text = Array(msg["content"]).filter_map { |block| block["text"] if block.is_a?(Hash) }.join
    SYSTEM_SPEECH_RE.match?(text)
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
      cache_creation_5m_input_tokens: normalized_usage["cache_creation_5m_input_tokens"],
      cache_creation_1h_input_tokens: normalized_usage["cache_creation_1h_input_tokens"],
      cache_read_input_tokens: normalized_usage["cache_read_input_tokens"],
      estimated_cost_usd: estimated_cost_usd(normalized_usage),
      budget_state: budget_state,
      budget_over_dimensions: @budget_verdict&.over_dimensions&.join(",").presence,
      budget_enforced: @budget_enforced || false,
      budget_source_id: @budget_scopes&.[]("source"),
      # The enforcement key's telemetry shadow, sibling to budget_source_id:
      # day-salted like everything budget-scoped, and collision-resistant
      # where the observation conversation_id (deliberately untouched, per
      # #2123) can pool same-opener conversations. Cost dashboards facet on
      # this for a per-conversation view that can't merge strangers.
      budget_conversation_id: @budget_scopes&.[]("conversation"),
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

    # Non-streaming responses carry the nested cache_creation object; the
    # streaming path has already flattened it in capture_anthropic_usage!.
    breakdown = anthropic_usage["cache_creation"]
    ANTHROPIC_CACHE_CREATION_KEYS.each do |api_key, flat_key|
      if anthropic_usage.key?(flat_key)
        usage[flat_key] = anthropic_usage[flat_key]
      elsif breakdown.is_a?(Hash) && breakdown.key?(api_key)
        usage[flat_key] = breakdown[api_key]
      end
    end

    usage
  end

  def estimated_cost_usd(anthropic_usage)
    return if anthropic_usage.values.all?(&:nil?)

    usage = anthropic_usage.dup
    if usage["cache_creation_5m_input_tokens"] || usage["cache_creation_1h_input_tokens"]
      # The per-TTL breakdown is authoritative; drop the aggregate so the
      # same tokens aren't priced twice.
      usage.delete("cache_creation_input_tokens")
    else
      # No breakdown reported: price the aggregate at the 1-hour rate — the
      # system prompt (the overwhelming share of any write) uses that tier,
      # and overcounting is the safe direction for budget enforcement.
      usage["cache_creation_1h_input_tokens"] = usage.delete("cache_creation_input_tokens")
    end

    cost = Prompts::Anthropic::PRICING_USD_PER_MILLION.sum { |key, usd_per_million|
      usage[key].to_i * usd_per_million / 1_000_000.0
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

    breakdown = usage["cache_creation"]
    if breakdown.is_a?(Hash)
      ANTHROPIC_CACHE_CREATION_KEYS.each do |api_key, flat_key|
        anthropic_usage[flat_key] = breakdown[api_key] if breakdown.key?(api_key)
      end
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
