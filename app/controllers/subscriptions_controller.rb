# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :assert_stripe_ready!

  def start
    customer = current_user.ensure_stripe_customer!

    stripe_product_id = ENV.fetch("STRIPE_PRODUCT_ID")
    stripe_product = Stripe::Product.retrieve(stripe_product_id)

    trial_days = [
      ((current_user.trial_ends_at.to_f - Time.current.to_f) / 86400).ceil,
      0,
    ].max

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      success_url: confirm_subscription_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: user_url,
      customer: customer.id,
      line_items: [{
        price: stripe_product.default_price,
        quantity: 1,
      }],
      subscription_data: trial_days.positive? ? { trial_period_days: trial_days } : {},
    )

    redirect_to(session.url, allow_other_host: true)
  end

  def confirm
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    subscription = Stripe::Subscription.retrieve(session.subscription)

    current_user.update!(stripe_subscription_id: subscription.id)

    redirect_to(:user)
  end

  def cancel
    return head(:unprocessable_entity) unless current_user.stripe_subscription_id

    Stripe::Subscription.cancel(current_user.stripe_subscription_id)
    current_user.update!(stripe_subscription_id: nil)

    redirect_to(:user)
  end
end
