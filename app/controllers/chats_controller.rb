# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :chat_context # warmup the chat context
  helper_method :chat_context

  def index
  end

  def message
    chat_log = permitted_chat_log_params.as_json
    stream_id = SecureRandom.uuid

    chat_client = "reader"

    if current_user&.writer?
      if chat_log.dig(0, "content", 0, "text") == "ooo.fun"
        chat_client = "writer"
      end
    end

    # Enqueue the background job
    StreamMessagesJob.perform_later(stream_id, chat_client, chat_log)

    render(json: { stream_id: stream_id })
  end

  private

  def chat_context
    @chat_context ||= {}
    @chat_context[:localstorage_chatlog_key] ||= "chatLogData"

    @chat_context
  end

  def permitted_chat_log_params
    params.require(:chat_log).map do |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    end
  end
end
