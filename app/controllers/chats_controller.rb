# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :stream]

  def index
    if current_user
      render("index_user")
    else
      @show_h1_letter = true
      render("index_guest")
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
  end

  def create
    chat_messages = permitted_chat_messages_params.as_json

    chat = current_user.chats.create!(
      messages_encrypted: encrypt_data(chat_messages.to_json),
    )

    # Enqueue the background job
    StreamMessagesJob.perform_later({ chat_id: chat.id }, chat_messages)

    redirect_to(chat)
  end

  def update
    chat_messages = permitted_chat_messages_params.as_json

    chat = current_user.chats.find(params[:id])
    chat.update!(data_encrypted: encrypt_data(chat_messages.to_json))

    # Enqueue the background job
    StreamMessagesJob.perform_later({ chat_id: chat.id }, chat_messages)

    redirect_to(chat)
  end

  def stream
    chat_messages = permitted_chat_messages_params.as_json
    stream_id = SecureRandom.uuid

    # Enqueue the background job
    StreamMessagesJob.perform_later({ stream_id: stream.id }, chat_messages)

    render(json: { stream_id: stream_id })
  end

  private

  def permitted_chat_messages_params
    params.require(:chat_messages).map do |log_entry|
      log_entry.permit(:role, content: [:type, :text])
    end
  end
end
