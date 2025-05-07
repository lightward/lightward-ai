# frozen_string_literal: true

class TranscriptionChannel < ApplicationCable::Channel
  def subscribed
    transcription_id = params[:transcription_id]
    stream_from("transcription_channel_#{transcription_id}")
  end

  def ready
  end

  def unsubscribed
  end
end
