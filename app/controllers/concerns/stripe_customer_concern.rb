# frozen_string_literal: true

# app/models/concerns/stripe_customer_concern.rb
module StripeCustomerConcern
  extend ActiveSupport::Concern

  def ensure_stripe_customer!
    return stripe_customer if valid_stripe_customer?

    # Clear invalid ID if present
    self.stripe_customer_id = nil if stripe_customer_id

    # Find or create customer
    customer = find_or_create_stripe_customer
    update!(stripe_customer_id: customer.id)
    customer
  end

  private

  def stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  end

  def valid_stripe_customer?
    return false unless stripe_customer_id

    stripe_customer
    true
  rescue Stripe::InvalidRequestError
    false
  end

  def find_or_create_stripe_customer
    existing = Stripe::Customer.list(email: email, limit: 1).data.first
    existing || Stripe::Customer.create(email: email)
  end
end
