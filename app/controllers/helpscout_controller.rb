# frozen_string_literal: true

class HelpscoutController < ApplicationController
  def receive
    request_body = request.raw_post
    signature = request.headers["X-HelpScout-Signature"]

    if valid_signature?(request_body, signature)
      # Process the webhook data here
      render(json: { message: "Webhook received and verified" }, status: :ok)
    else
      render(json: { message: "Invalid signature" }, status: :unauthorized)
    end
  end

  private

  def valid_signature?(data, signature)
    return false if data.nil? || signature.nil?

    secret = ENV.fetch("HELPSCOUT_WEBHOOK_SECRET_KEY")
    digest = OpenSSL::HMAC.digest("sha1", secret, data)

    Rack::Utils.secure_compare(Base64.encode64(digest).strip, signature.strip)
  end
end
