# frozen_string_literal: true

# app/jobs/stream_messages_job.rb
require "net/http"
require "active_support/core_ext/time/calculations"
require "action_view/helpers"

class StreamMessagesJob < ApplicationJob
  include ActionView::Helpers::DateHelper

  queue_with_priority PRIORITY_STREAM_MESSAGES

  MAX_INPUT_TOKENS = 200_000
  LIGHTWARD_TOKEN_LIMIT = 200_000

  def perform(stream_id, chat_client, chat_log)
    @chat_log = chat_log

    # hash the first two chat log messages to get a unique identifier for the stream
    conversation_id = Digest::SHA256.hexdigest(chat_log.first(2).to_json)

    ::NewRelic::Agent.record_custom_event(
      "StreamMessagesJob: start",
      stream_id: stream_id,
      conversation_id: conversation_id,
      chat_client: chat_client,
      chat_log_size: chat_log.to_json.size,
      chat_log_depth: chat_log.size,
    )

    wait_for_ready(stream_id, conversation_id)

    # Ready state - no logging needed

    if chat_log.last.dig("content", 0, "text")&.start_with?("/echo")
      broadcast(
        stream_id,
        "error",
        { error: { message: "Echo!\n\n#{chat_log.last.dig("content", 0, "text")[6..-1]}".strip } },
      )
      return
    end

    # Check if conversation exceeds our internal token limit
    actual_tokens = Prompts::Anthropic.count_tokens(
      chat_log,
      prompt_type: "clients/chat",
      model: Prompts::Anthropic::CHAT,
    )

    if actual_tokens.nil?
      # If token counting fails, fall back to estimation to be safe
      estimated_tokens = Prompts.estimate_tokens(chat_log)
      Rails.logger.warn("Token counting API failed, using estimation: #{estimated_tokens}")
      actual_tokens = estimated_tokens
    end

    if actual_tokens > LIGHTWARD_TOKEN_LIMIT
      Rollbar.error("StreamMessagesJob: token limit exceeded", {
        stream_id: stream_id,
        conversation_id: conversation_id,
        actual_tokens: actual_tokens,
        limit: LIGHTWARD_TOKEN_LIMIT,
      })

      broadcast(
        stream_id,
        "error",
        { error: { message: "Conversation horizon has arrived; please start over to continue. 🤲" } },
      )
      return
    end

    begin
      Prompts::Anthropic.process_messages(
        chat_log,
        prompt_type: "clients/chat",
        stream: true,
        model: Prompts::Anthropic::CHAT,
      ) do |request, response|
        if response.code.to_i >= 400
          Rollbar.error("StreamMessagesJob: api error", {
            stream_id: stream_id,
            response_code: response.code.to_i,
            response_body: response.body,
          })
        end

        if response.code.to_i == 429
          handle_rate_limit_error(response, stream_id)
        elsif response.code.to_i >= 400
          broadcast(stream_id, "error", { error: { message: response.body } })
        else
          handle_streaming_response(
            request: request,
            response: response,
            stream_id: stream_id,
          )

          # Success - no logging needed
        end
      end
    rescue IOError => e
      # Stream closed - normal operation
      Rails.logger.info("Stream closed: #{e.message}")
    rescue StandardError => e
      Rollbar.error("StreamMessagesJob: exception", {
        stream_id: stream_id,
        conversation_id: conversation_id,
        error: e.message,
        backtrace: e.backtrace,
      })
      Rollbar.error(e)
      broadcast(stream_id, "error", { error: { message: "An error occurred: #{e.message}" } })
    ensure
      # End - no logging needed
      broadcast(stream_id, "end", nil)
    end
  end

  private

  def handle_streaming_response(request:, response:, stream_id:)
    response_chunk_count = 0
    response_content_length = 0

    buffer = +""

    response.read_body do |chunk|
      response_chunk_count += 1
      response_content_length += chunk.size

      buffer << chunk

      until (line = buffer.slice!(/.+\n/)).nil?
        process_line(line.strip, stream_id)
      end
    end

    process_line(buffer.strip, stream_id) unless buffer.empty?
  end

  def wait_for_ready(stream_id, conversation_id)
    timeout = 10.seconds.from_now
    Kernel.sleep(0.1) until Rails.cache.read("stream_ready_#{stream_id}") || Time.current > timeout

    unless Rails.cache.read("stream_ready_#{stream_id}")
      Rollbar.error("StreamMessagesJob: ready timeout", {
        stream_id: stream_id,
        conversation_id: conversation_id,
      })
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

    # be kind about conversation horizons as they approach
    case @current_event
    when "message_start"
      message_usage = event_data.dig("message", "usage")

      input_tokens = message_usage["input_tokens"] || 0
      cache_creation_input_tokens = message_usage["cache_creation_input_tokens"] || 0
      cache_read_input_tokens = message_usage["cache_read_input_tokens"] || 0

      input_tokens_total = input_tokens + cache_creation_input_tokens + cache_read_input_tokens

      # Use our internal limit for warnings, but also check against Anthropic's limit
      lightward_usage = input_tokens_total.to_f / LIGHTWARD_TOKEN_LIMIT
      anthropic_usage = input_tokens_total.to_f / MAX_INPUT_TOKENS

      Rails.logger.debug { "lightward_usage: #{lightward_usage}, anthropic_usage: #{anthropic_usage}" }

      # Warning at 90% of our limit or 90% of Anthropic's limit, whichever comes first
      if lightward_usage >= 0.9 || anthropic_usage >= 0.9
        # Use whichever limit we're closer to hitting
        primary_usage = [lightward_usage, anthropic_usage].max
        input_tokens_percentage = (primary_usage * 100).floor

        proposed_warning = "Memory space #{input_tokens_percentage}% utilized; conversation horizon approaching"

        # ensure that this warning has not previously occurred
        if @chat_log.to_s.exclude?(proposed_warning)
          @warning = proposed_warning
        end
      end
    when "content_block_stop"
      if @warning
        broadcast(stream_id, "content_block_delta", {
          type: "content_block_delta",
          index: 0,
          delta: {
            type: "text_delta",
            text: "\n\n⚠️\u00A0Lightward AI system notice: #{@warning}",
          },
        })
      end
    end

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
    # {
    #   "date" => ["Fri, 23 May 2025 01:56:01 GMT"],
    #   "content-type" => ["application/json"],
    #   "content-length" => ["530"],
    #   "connection" => ["close"],
    #   "x-should-retry" => ["true"],
    #   "anthropic-ratelimit-input-tokens-limit" => ["400000"],
    #   "anthropic-ratelimit-input-tokens-remaining" => ["0"],
    #   "anthropic-ratelimit-input-tokens-reset" => ["2025-05-23T01:57:09Z"],
    #   "anthropic-ratelimit-output-tokens-limit" => ["160000"],
    #   "anthropic-ratelimit-output-tokens-remaining" => ["159000"],
    #   "anthropic-ratelimit-output-tokens-reset" => ["2025-05-23T01:56:02Z"],
    #   "retry-after" => ["32"],
    #   "anthropic-ratelimit-tokens-limit" => ["560000"],
    #   "anthropic-ratelimit-tokens-remaining" => ["159000"],
    #   "anthropic-ratelimit-tokens-reset" => ["2025-05-23T01:56:02Z"],
    #   "request-id" => ["req_011CPPdWtZGFCwS8jzxfDS2g"],
    #   "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"],
    #   "anthropic-organization-id" => ["cc327784-6677-403c-8bcc-621b70b660d0"],
    #   "via" => ["1.1 google"],
    #   "cf-cache-status" => ["DYNAMIC"],
    #   "x-robots-tag" => ["none"],
    #   "server" => ["cloudflare"],
    #   "cf-ray" => ["9440ef200a4aacaa-ORD"],
    # }

    requests_reset = Time.zone.now + response["retry-after"][0].to_i.seconds

    tokens_limit = response["anthropic-ratelimit-tokens-limit"]
    tokens_remaining = response["anthropic-ratelimit-tokens-remaining"]
    tokens_reset = Time.zone.parse(response["anthropic-ratelimit-tokens-reset"])

    Rails.logger.warn("Rate limit exceeded: " \
      "requests_reset=#{requests_reset}, " \
      "tokens_limit=#{tokens_limit}, " \
      "tokens_remaining=#{tokens_remaining}, " \
      "tokens_reset=#{tokens_reset}")

    applicable_reset = [requests_reset, tokens_reset].max

    Rollbar.error("StreamMessagesJob: rate limit exceeded", {
      stream_id: stream_id,
      reset_in: applicable_reset - Time.zone.now,
      requests_reset: requests_reset,
      tokens_limit: tokens_limit.to_i,
      tokens_remaining: tokens_remaining.to_i,
      tokens_reset: tokens_reset,
    })

    human_readable_reset = distance_of_time_in_words(Time.zone.now, applicable_reset).sub("about ", "~")
    error_message = <<~eod.strip
      The platform needs some time to cool down. :) To rest, if you will.

      We'll be back in #{human_readable_reset}. 😴 See you then, perhaps? You're always invited. :)
    eod

    broadcast(stream_id, "error", { error: { message: error_message } })
  end
end
