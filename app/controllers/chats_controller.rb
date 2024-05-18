# frozen_string_literal: true

class ChatsController < ApplicationController
  def index
  end

  def message
    chat_log = permitted_chat_log_params.as_json
    stream_id = SecureRandom.uuid

    # Enqueue the background job
    StreamMessagesJob.perform_later(stream_id, chat_type, chat_log)

    render(json: { stream_id: stream_id })
  end

  private

  def chat_type
    "lightward"
  end

  def permitted_chat_log_params
    params.require(:chat_log).map do |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    end
  end
end
