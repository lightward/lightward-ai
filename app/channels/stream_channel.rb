# frozen_string_literal: true

class StreamChannel < ApplicationCable::Channel
  def subscribed
    message_id = params[:message_id]
    stream_from("stream_channel_#{message_id}")
  end

  def ready
    message_id = params[:message_id]
    ChatMessage.client_ready!(message_id)
  end

  def unsubscribed
  end
end
