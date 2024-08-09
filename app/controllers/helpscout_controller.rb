# frozen_string_literal: true

class HelpscoutController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    request_body = request.raw_post
    signature = request.headers["X-HelpScout-Signature"]

    if valid_signature?(request_body, signature)
      event_data = JSON.parse(request_body)
      convo_id = event_data["id"]
      HelpscoutJob.perform_later(convo_id)

      head(:accepted)
    else
      head(:unauthorized)
    end
  rescue JSON::ParserError
    head(:bad_request)
  end

  private

  def valid_signature?(data, signature)
    return false if data.nil? || signature.nil?

    digest = OpenSSL::HMAC.digest("sha1", Helpscout.webhook_secret_key, data)

    Rack::Utils.secure_compare(Base64.encode64(digest).strip, signature.strip)
  end
end
