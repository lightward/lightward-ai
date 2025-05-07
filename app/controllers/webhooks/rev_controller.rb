# frozen_string_literal: true

module Webhooks
  class RevController < ApplicationController
    before_action :verify_rev_signature

    def receive
      case job_params[:status]
      when "failed"
        broadcast(params[:transcription_id], { error: job_params[:failure_detail] })
      when "transcribed"
        rev_api_token = ENV.fetch("REV_AI_TOKEN")
        job_id = job_params[:id]

        response = HTTParty.get(
          "https://api.rev.ai/speechtotext/v1/jobs/#{job_id}/transcript",
          query: {
            group_channels_by: "speaker",
          },
          headers: {
            "Authorization" => "Bearer #{rev_api_token}",
            "Accept" => "text/plain",
          },
        )

        broadcast(
          params[:transcription_id],
          {
            transcript: response.body,
          },
        )
      else
        broadcast(
          params[:transcription_id],
          {
            error: "Unknown status: #{job_params[:status]}",
          },
        )
      end
    end

    protected

    def broadcast(transcription_id, message)
      ActionCable.server.broadcast("transcription_channel_#{transcription_id}", message)
    end

    def verify_rev_signature
      rev_api_token = ENV.fetch("REV_AI_TOKEN")
      notification_token = Digest::SHA256.hexdigest("#{params[:transcription_id]}#{rev_api_token}")
      expected_token = request.headers["Authorization"]&.sub(/^Bearer /, "")

      unless ActiveSupport::SecurityUtils.secure_compare(notification_token, expected_token)
        render(json: { error: "Invalid signature" }, status: :unauthorized)
      end
    end

    # {
    #   "job": {
    #     "id": "jdP2425SuMaWMnko",
    #     "created_on": "2025-05-06T23:24:04.614Z",
    #     "completed_on": "2025-05-06T23:24:10.004Z",
    #     "name": "RackMultipart20250506-44447-l0r0up.webm",
    #     "skip_diarization": false,
    #     "skip_punctuation": false,
    #     "remove_disfluencies": false,
    #     "filter_profanity": false,
    #     "status": "transcribed",
    #     "duration_seconds": 4.44,
    #     "type": "async",
    #     "delete_after_seconds": 60,
    #     "strict_custom_vocabulary": false,
    #     "language": "en",
    #     "transcriber": "machine"
    #   }
    # }

    # {
    #   "job": {
    #     "id": "5hTv31B1cEiy6Q5M",
    #     "created_on": "2025-05-06T23:23:32.627Z",
    #     "completed_on": "2025-05-06T23:23:33.569Z",
    #     "name": "RackMultipart20250506-44447-yyb4qd.webm",
    #     "skip_diarization": false,
    #     "skip_punctuation": false,
    #     "remove_disfluencies": false,
    #     "filter_profanity": false,
    #     "failure": "empty_media",
    #     "failure_detail": "Audio was of insufficient length to be transcribed",
    #     "status": "failed",
    #     "type": "async",
    #     "delete_after_seconds": 60,
    #     "strict_custom_vocabulary": false,
    #     "language": "en",
    #     "transcriber": "machine"
    #   }
    # }

    def job_params
      params.expect(
        job: [
          :id,
          :created_on,
          :completed_on,
          :name,
          :skip_diarization,
          :skip_punctuation,
          :remove_disfluencies,
          :filter_profanity,
          :failure,
          :failure_detail,
          :status,
          :duration_seconds,
          :type,
          :delete_after_seconds,
          :strict_custom_vocabulary,
          :language,
        ],
      )
    end
  end
end
