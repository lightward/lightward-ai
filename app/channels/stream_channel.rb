# frozen_string_literal: true

class StreamChannel < ApplicationCable::Channel
  def subscribed
    stream_id = params[:stream_id]
    stream_from("stream_channel_#{stream_id}")
  end

  def ready
    stream_id = params[:stream_id]
    Rails.cache.write("stream_ready_#{stream_id}", true, expires_in: 5.minutes)
  end

  def unsubscribed
    stream_id = params[:stream_id]
    Rails.cache.delete("stream_ready_#{stream_id}")
  end
end
