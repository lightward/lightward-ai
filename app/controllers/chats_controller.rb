# frozen_string_literal: true

class ChatsController < ApplicationController
  def index
    @chat_messages = []
  end

  def show
    @chat_messages = ChatMessage.by_chat(params[:chat_id])

    raise ActiveRecord::RecordNotFound if @chat_messages.none?

    render(action: :index)
  end

  def message
    raise "Invalid role: only user is supported" unless message_params[:role] == "user"
    raise "Invalid message" if message_params[:text].blank?

    # save the message
    message = ChatMessage.create!(
      chat_id: chat_id,
      role: message_params[:role],
      text: message_params[:text],
    )

    # Enqueue the background job
    StreamMessagesJob.perform_later(message.id)

    render(json: { chat_id: message.chat_id, message_id: message.id })
  end

  private

  def chat_id
    @chat_id ||= calculate_chat_id
  end

  def calculate_chat_id
    provisional_chat_id = params[:chat_id].presence

    return SecureRandom.uuid if provisional_chat_id.blank?
    return SecureRandom.uuid if ChatMessage.by_chat(provisional_chat_id.to_s).none?

    provisional_chat_id
  end

  def message_params
    params.require(:message).permit(:role, :text)
  end
end
