# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :verify_helpscout_signature

  def helpscout
  end

  private

  def helpscout_signature
    @helpscout_signature ||= request.headers["x-helpscout-signature"]
  end

  def helpscout_event
    @helpscout_event ||= request.headers["x-helpscout-event"]
  end

  def helpscout_webhook_secret_key
    ENV.fetch("HELPSCOUT_WEBHOOK_SECRET_KEY")
  end

  def verify_helpscout_signature
    calculated_digest = OpenSSL::HMAC.digest("sha1", helpscout_webhook_secret_key, request.body.read)
    calculated_signature = Base64.encode64(calculated_digest)

    unless Rack::Utils.secure_compare(calculated_signature, helpscout_signature)
      head(:unauthorized)
    end
  end
end
