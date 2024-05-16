class ChatsController < ApplicationController

  def index
  end

  def message
    chat_log = permitted_chat_log_params
    stream_id = SecureRandom.uuid

    # Enqueue the background job
    StreamMessagesJob.perform_later(chat_log, stream_id)

    render json: { stream_id: stream_id }
  end

  private

  def permitted_chat_log_params
    params.require(:chat_log).map do |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    end
  end
end
