# frozen_string_literal: true

class User < ApplicationRecord
  include StripeCustomerConcern

  validates :google_id, presence: true

  enum :suspended_for,
    {
      trial_expired: "trial_expired",
      payment_failed: "payment_failed",
    },
    instance_methods: false,
    validate: { allow_nil: true }

  class << self
    def for_google_identity(google_identity)
      where(google_id: google_identity.user_id).first_or_create!(
        email: google_identity.email_address,
      )
    end
  end

  def admin?
    # everyone @lightward.com
    email.ends_with?("@lightward.com")
  end

  def suspend_for!(reason)
    update!(
      suspended_at: Time.current,
      suspended_for: reason,
      stripe_subscription_id: nil, # Clear this since we're cancelling subscriptions on suspension
    )
  end

  def suspended?
    suspended_at.present?
  end

  def active?
    # suspended
    return false if suspended?

    # subscriber
    return true if stripe_subscription_id.present?

    # new record (might not have trial_expires_at yet)
    return true if new_record?

    # trial
    trial_expires_at > Time.current
  end
end
