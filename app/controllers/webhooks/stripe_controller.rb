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
      when "customer.subscription.updated"
        handle_subscription_updated(event.data.object)
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

    def handle_subscription_updated(subscription)
      # Mostly for maintaining data consistency
      # Price changes we handle directly through our own interface
      user = User.find_by(stripe_subscription_id: subscription.id)
      return unless user

      # If it was suspended and is now active again, clear suspension
      if user.suspended? && subscription.status == "active"
        user.update!(suspended_at: nil, suspended_for: nil)
      end
    end

    def handle_payment_failed(invoice)
      subscription = invoice.subscription
      user = User.find_by(stripe_subscription_id: subscription)
      return unless user

      # Cancel the subscription immediately and mark as suspended
      Stripe::Subscription.cancel(subscription)
      user.suspend_for!(:payment_failed)
    end
  end
end
