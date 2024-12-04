# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV.fetch("STRIPE_WEBHOOK_SECRET")
      )

      case event.type
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      when "invoice.payment_failed"
        handle_payment_failed(event.data.object)
      end

      head(:ok)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head(:bad_request)
    end

    private

    def handle_subscription_deleted(subscription)
      user = User.find_by(stripe_subscription_id: subscription.id)
      user&.update!(stripe_subscription_id: nil)
    end

    def handle_payment_failed(invoice)
      subscription = invoice.subscription
      user = User.find_by(stripe_subscription_id: subscription)
      return unless user

      Stripe::Subscription.cancel(subscription)
      user.update!(stripe_subscription_id: nil)
    end
  end
end
