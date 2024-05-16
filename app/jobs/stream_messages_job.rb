# frozen_string_literal: true

# app/jobs/stream_messages_job.rb
require "net/http"

class StreamMessagesJob < ApplicationJob
  queue_as :default

  def perform(chat_log, stream_id)
    system_prompt = read_prompt("system.md")
    conversation_starters = read_conversation_starters

    messages = conversation_starters + chat_log
    Rails.logger.debug { "Messages: #{messages}" }

    payload = {
      model: "claude-3-opus-20240229",
      max_tokens: 2000,
      stream: true,
      temperature: 0.7,
      system: system_prompt,
      messages: messages,
    }

    ActionCable.server.broadcast("stream_channel_#{stream_id}", { event: "start", data: nil })

    begin
      anthropic_api_request(payload) do |response|
        buffer = +""
        response.read_body do |chunk|
          buffer << chunk
          until (line = buffer.slice!(/.+\n/)).nil?
            process_line(line.strip, stream_id)
          end
        end
        # Process any remaining buffered content
        process_line(buffer.strip, stream_id) unless buffer.empty?
      end
    rescue IOError
      Rails.logger.info("Stream closed")
    ensure
      ActionCable.server.broadcast("stream_channel_#{stream_id}", { event: "end", data: nil })
    end
  end

  private

  def read_prompt(filename)
    Rails.root.join("app", "prompts", "chat", filename).read
  end

  def read_conversation_starters
    starters = []
    index = 1

    loop do
      user_file = Rails.root.join("app", "prompts", "chat", "#{index}-user.md")
      assistant_file = Rails.root.join("app", "prompts", "chat", "#{index + 1}-assistant.md")

      break unless File.exist?(user_file) && File.exist?(assistant_file)

      starters << { role: "user", content: [{ type: "text", text: File.read(user_file) }] }
      starters << { role: "assistant", content: [{ type: "text", text: File.read(assistant_file) }] }

      index += 2
    end

    starters
  end

  def process_line(line, stream_id)
    return if line.empty?

    if line.start_with?("event:")
      @current_event = line[6..-1].strip
    elsif line.start_with?("data:")
      json_data = line[5..-1] # Remove "data: " prefix
      handle_data_event(json_data, stream_id)
    else
      Rails.logger.warn("Unknown line format: #{line}")
    end
  end

  def handle_data_event(json_data, stream_id)
    event_data = JSON.parse(json_data)
    Rails.logger.debug { "Event: #{@current_event}, Data: #{event_data}" }
    case @current_event
    when "message_start"
      ActionCable.server.broadcast("stream_channel_#{stream_id}", { event: "message_start", data: event_data })
    when "content_block_start"
      @content_blocks ||= {}
      @current_content_block_index = event_data["index"]
      @content_blocks[@current_content_block_index] = +""
    when "content_block_delta"
      @content_blocks[@current_content_block_index] << event_data["delta"]["text"]
      ActionCable.server.broadcast("stream_channel_#{stream_id}", { event: "content_block_delta", data: event_data })
    when "content_block_stop"
      complete_block = @content_blocks.delete(@current_content_block_index)
      ActionCable.server.broadcast(
        "stream_channel_#{stream_id}",
        { event: "content_block_stop", data: { index: @current_content_block_index, content: complete_block } },
      )
    when "message_delta"
      ActionCable.server.broadcast("stream_channel_#{stream_id}", { event: "message_delta", data: event_data })
    when "message_stop"
      ActionCable.server.broadcast("stream_channel_#{stream_id}", { event: "message_stop", data: event_data })
    when "ping"
      # Handle ping event if needed
    when "error"
      ActionCable.server.broadcast("stream_channel_#{stream_id}", { event: "error", data: event_data })
      Rails.logger.error("Error event: #{event_data["error"]["message"]}")
    else
      Rails.logger.warn("Unhandled event type: #{@current_event}")
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing JSON: #{e.message} -- #{json_data}")
  end

  def anthropic_api_request(payload, &block)
    uri = URI("https://api.anthropic.com/v1/messages")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Content-Type": "application/json",
      "anthropic-version": "2023-06-01",
      "anthropic-beta": "messages-2023-12-15",
      "x-api-key": ENV.fetch("ANTHROPIC_API_KEY", nil),
    })
    request.body = payload.to_json

    http.request(request, &block)
  end
end
