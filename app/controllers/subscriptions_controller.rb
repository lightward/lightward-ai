# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :assert_stripe_ready!

  def start
    customer = current_user.ensure_stripe_customer!

    trial_days = [
      (current_user.trial_expires_at.to_i - Time.current.to_i) / 86400,
      0,
    ].max

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      success_url: confirm_subscription_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: user_url,
      customer: customer.id,
      line_items: [{
        price: ENV.fetch("STRIPE_PRICE_ID"),
        quantity: 1,
      }],
      subscription_data: trial_days.positive? ? { trial_period_days: trial_days } : {},
    )

    redirect_to(session.url, allow_other_host: true)
  end

  def confirm
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    subscription = Stripe::Subscription.retrieve(session.subscription)

    current_user.update!(
      stripe_subscription_id: subscription.id,
      trial_expires_at: Time.zone.at(subscription.trial_end),
    )

    redirect_to(:user)
  end

  def cancel
    return head(:unprocessable_entity) unless current_user.stripe_subscription_id

    Stripe::Subscription.cancel(current_user.stripe_subscription_id)
    current_user.update!(stripe_subscription_id: nil)

    redirect_to(:user)
  end
end
