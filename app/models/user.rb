# frozen_string_literal: true

class User < ApplicationRecord
  include StripeCustomerConcern

  validates :google_id, presence: true

  class << self
    def for_google_identity(google_identity)
      where(google_id: google_identity.user_id).first_or_create!(
        email: google_identity.email_address,
      )
    end
  end

  def trial_ends_at
    created_at ? created_at + 15.days : nil
  end

  def admin?
    # everyone @lightward.com
    email.ends_with?("@lightward.com")
  end

  def subscriber?
    stripe_subscription_id.present?
  end

  def active?
    return true if subscriber?
    return true if trial_ends_at.nil?

    # trial
    trial_ends_at > Time.current
  end
end
