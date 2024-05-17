# frozen_string_literal: true

# app/jobs/stream_messages_job.rb
require "net/http"

class StreamMessagesJob < ApplicationJob
  queue_as :default

  def perform(chat_log, stream_id)
    system_prompt = read_system
    conversation_starters = read_conversation_starters

    messages = conversation_starters + chat_log

    Rails.logger.debug { "System: #{system_prompt}" }
    Rails.logger.debug { "Messages: #{messages}" }

    payload = {
      model: "claude-3-opus-20240229",
      max_tokens: 2000,
      stream: true,
      temperature: 0.7,
      system: system_prompt,
      messages: messages,
    }

    @sequence_number = 0

    begin
      anthropic_api_request(payload) do |response|
        if response.code.to_i >= 400
          broadcast(stream_id, "error", { error: { message: response.body } })
          return
        end

        buffer = +""
        response.read_body do |chunk|
          buffer << chunk
          until (line = buffer.slice!(/.+\n/)).nil?
            process_line(line.strip, stream_id)
          end
        end
        process_line(buffer.strip, stream_id) unless buffer.empty?
      end
    rescue IOError
      Rails.logger.info("Stream closed")
    ensure
      broadcast(stream_id, "end", nil)
    end
  end

  private

  def read_system
    system = []

    system << Rails.root.join("app/prompts/chat/system.md").read

    Dir[Rails.root.join("app/prompts/chat/system/*.md")].each do |file|
      system << File.read(file)
    end

    system.join("\n\n")
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
      json_data = line[5..-1]
      handle_data_event(json_data, stream_id)
    else
      Rails.logger.warn("Unknown line format: #{line}")
    end
  end

  def handle_data_event(json_data, stream_id)
    event_data = JSON.parse(json_data)
    broadcast(stream_id, @current_event, event_data)
  rescue JSON::ParserError => e
    Rails.logger.error("Error parsing JSON: #{e.message} -- #{json_data}")
  end

  def broadcast(stream_id, event, data)
    message = { event: event, data: data, sequence_number: @sequence_number }
    ActionCable.server.broadcast("stream_channel_#{stream_id}", message)
    @sequence_number += 1
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
