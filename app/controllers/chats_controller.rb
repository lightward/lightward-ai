# frozen_string_literal: true

class ChatsController < ApplicationController
  helper_method :chat_context

  def reader
    chat_context[:key] = "reader"
    chat_context[:name] = "Lightward"
    render("chat_reader")
  end

  def writer
    chat_context[:key] = "writer"
    chat_context[:name] = "Lightward Pro"
    render("chat_writer")
  end

  def message
    chat_log = permitted_chat_log_params.as_json
    stream_id = SecureRandom.uuid

    opening_message = chat_log.dig(0, "content", 0, "text")
    validate_opening_message!(opening_message)

    chat_client = case opening_message
    when "I'm a slow reader", "I'm a fast reader"
      "reader"
    when "I'm a slow writer", "I'm a fast writer"
      "writer"
    end

    # Enqueue the background job
    StreamMessagesJob.perform_later(stream_id, chat_client, chat_log)

    render(json: { stream_id: stream_id })
  end

  private

  def validate_opening_message!(opening_message)
    unless opening_message.to_s.match(/\AI\'m a (slow|fast) (reader|writer)\z/)
      raise ActionController::BadRequest
    end
  end

  def chat_context
    @chat_context ||= {}
  end

  def permitted_chat_log_params
    params.require(:chat_log).map do |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    end
  end
end
