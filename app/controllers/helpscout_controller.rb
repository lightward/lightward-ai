# frozen_string_literal: true

class HelpscoutController < ApplicationController
  def receive
    request_body = request.raw_post
    signature = request.headers["X-HelpScout-Signature"]
    event = request.headers["X-HelpScout-Event"]

    if valid_signature?(request_body, signature)
      event_data = JSON.parse(request_body)
      HelpscoutJob.perform_later(event, event_data)

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
