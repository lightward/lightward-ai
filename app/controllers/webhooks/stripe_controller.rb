# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

      event = Stripe::Webhook.construct_event(
        payload, sig_header, stripe_webhook_secret
      )

      case event.type
      when "customer.subscription.deleted"
        user = User.find_by(stripe_subscription_id: event.data.object.id)
        user&.update!(stripe_subscription_id: nil)
      when "customer.subscription.trial_will_end"
        # Stripe sends this 3 days before trial ends
        subscription = event.data.object
        user = User.find_by(stripe_subscription_id: subscription.id)
        TrialEndingNotifierJob.perform_later(user.id) if user
      end

      head(:ok)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head(:bad_request)
    end
  end
end
