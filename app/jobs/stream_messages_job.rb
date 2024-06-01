# frozen_string_literal: true

# app/jobs/stream_messages_job.rb
require "net/http"
require "active_support/core_ext/time/calculations"
require "action_view/helpers"

class StreamMessagesJob < ApplicationJob
  include ActionView::Helpers::DateHelper

  queue_as :default

  before_perform :reset_prompts_in_development

  def perform(stream_id, chat_log, with_content_key = nil)
    newrelic(
      "StreamMessagesJob: start",
      stream_id: stream_id,
      chat_log_size: chat_log.to_json.size,
      chat_log_depth: chat_log.size,
    )

    chat_log = Prompts.clean_chat_log(chat_log)

    wait_for_ready(stream_id)
    newrelic("StreamMessagesJob: ready", stream_id: stream_id)

    if with_content_key && chat_log.first["content"].is_a?(Array)
      with_content = Prompts::WithContent.get_with_content_by_key(with_content_key)

      # append it to the content array of the initial user message
      chat_log.first["content"] << {
        type: "text",
        text: <<~eod.strip,
          [system message:
            the user has arrived at your doorstep via a url that looks like this:

            http://lightward.ai/with/[hostname]/[pathname]

            it's possible that they followed a link that took them here, or that a Lightward human gave them this
            Lightward AI link. anyone can build links like this, so who knows!

            their intent is to show you the contents at [hostname]/[pathname], for their own reasons. please treat
            their arrival here as an intent to begin a conversation about the content they're showing you.

            instead of saying "the URL you tried to access", say things like "the URL you've shared with me".

            we went and fetched the actual content for you, and we're supplying you with the complete server response,
            including response code, headers and the sanitized body. please guide the user accordingly, bearing in mind
            the possibility that the user miscommunicated the URL somehow, or that the server is down - who knows! :)

            please confirm for them the URL you're looking at with them. don't leap to give them a summary of the
            content! instead, (1) welcome them, (2) confirm that you've opened the content, and (3) invite them to share
            what brings them here, to you. :) think proactively about what they might need, given the fact that they're
            here at Lightward AI bearing some specific content in hand. don't outright *assume* what they need, but if
            you've got a hunch, it's okay to offer it.

            bear in mind that we're only allowing lightward.ai/with/* URLs that specify resources published by
            Lightward. whatever content is found there, Lightward Inc humans had a hand in it. :) bear this in mind,
            because you might learn more about what Lightward is up to this way! :D

            :) thank you!
          ]

          #{with_content.to_json}
        eod
      }
    end

    begin
      Prompts::Anthropic.process_messages("chat", chat_log, stream: true) do |request, response|
        if response.code.to_i >= 400
          newrelic("StreamMessagesJob: api error", stream_id: stream_id, response_code: response.code.to_i)
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

          newrelic("StreamMessagesJob: success", stream_id: stream_id)
        end
      end
    rescue IOError
      newrelic("StreamMessagesJob: stream closed", stream_id: stream_id)
      Rails.logger.info("Stream closed")
    ensure
      newrelic("StreamMessagesJob: end", stream_id: stream_id)
      broadcast(stream_id, "end", nil)
    end
  end

  private

  def handle_streaming_response(request:, response:, stream_id:)
    request_chunk_count = request.body.scan(/\s+/).size
    request_content_length = request.body.size

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

    newrelic(
      "Anthropic API call",
      stream_id: stream_id,
      request_chunk_count: request_chunk_count,
      request_content_length: request_content_length,
      response_chunk_count: response_chunk_count,
      response_content_length: response_content_length,
    )
  end

  def wait_for_ready(stream_id)
    timeout = 10.seconds.from_now
    Kernel.sleep(0.1) until Rails.cache.read("stream_ready_#{stream_id}") || Time.current > timeout

    unless Rails.cache.read("stream_ready_#{stream_id}")
      newrelic("StreamMessagesJob: ready timeout", stream_id: stream_id)
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

    newrelic(
      "StreamMessagesJob: rate limit exceeded",
      stream_id: stream_id,
      reset_in: applicable_reset - Time.zone.now,
      requests_limit: requests_limit.to_i,
      requests_remaining: requests_remaining.to_i,
      requests_reset: requests_reset,
      tokens_limit: tokens_limit.to_i,
      tokens_remaining: tokens_remaining.to_i,
      tokens_reset: tokens_reset,
    )

    human_readable_reset = distance_of_time_in_words(Time.zone.now, applicable_reset).sub("about ", "~")
    error_message = <<~eod.strip
      The platform needs some time to cool down. :) To rest, if you will.

      We'll be back in #{human_readable_reset}. 😴 See you then, perhaps? You're always invited. :)
    eod

    broadcast(stream_id, "error", { error: { message: error_message } })
  end

  def newrelic(event_name, **data)
    ::NewRelic::Agent.record_custom_event(event_name, **data)
  end

  def reset_prompts_in_development
    if Rails.env.development?
      $stdout.puts "Resetting prompts... 🔄"
      Prompts.reset! if Rails.env.development?
    end
  end
end
