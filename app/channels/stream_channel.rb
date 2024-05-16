# frozen_string_literal: true

class StreamChannel < ApplicationCable::Channel
  def subscribed
    stream_from("stream_channel_#{params[:stream_id]}")
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
