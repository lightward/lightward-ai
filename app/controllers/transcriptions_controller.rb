# frozen_string_literal: true

# app/controllers/transcriptions_controller.rb
class TranscriptionsController < ApplicationController
  def create
    audio_file = params[:audio]

    if audio_file
      # Generate a unique job UUID
      transcription_id = SecureRandom.uuid

      # Start the transcription job (using a background job)
      submit_to_rev(transcription_id, audio_file)

      render(json: { transcription_id: transcription_id }, status: :ok)
    else
      render(json: { error: "No audio file received" }, status: :bad_request)
    end
  end

  protected

  def submit_to_rev(transcription_id, audio_file)
    rev_api_token = ENV.fetch("REV_AI_TOKEN")

    # digest of stream id with rev api token
    notification_token = Digest::SHA256.hexdigest("#{transcription_id}#{rev_api_token}")
    notification_url = "https://#{ENV.fetch("HOST")}/webhooks/rev?transcription_id=#{transcription_id}"

    options = {
      notification_config: {
        url: notification_url,
        auth_headers: {
          Authorization: "Bearer #{notification_token}",
        },
      },
      language: "en",
      transcriber: "fusion",
      skip_punctuation: false,
      skip_postprocessing: false,
      skip_diarization: false,
      diarization_type: "premium",
      remove_atmospherics: false,
      remove_disfluencies: false,
      filter_profanity: false,
      delete_after_seconds: 60,
      custom_vocabularies: [
        { phrases: ["lightward", "ooo.fun"] },
      ],
    }

    response = HTTParty.post(
      "https://api.rev.ai/speechtotext/v1/jobs",
      headers: {
        "Authorization" => "Bearer #{rev_api_token}",
      },
      multipart: true,
      body: {
        media: File.open(audio_file),
        options: options.to_json,
      },
    )

    if response.code != 200
      $stderr.puts "Error submitting job to Rev: #{response.code}"
      $stderr.puts response.body

      raise ActionController::BadRequest, "Error submitting job to Rev"
    end
  end
end
