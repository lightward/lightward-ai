# frozen_string_literal: true

class User < ApplicationRecord
  include StripeCustomerConcern

  scope :subscribers, -> { where.not(stripe_subscription_id: nil) }

  validates :google_id, presence: true

  class << self
    def for_google_identity(google_identity)
      user = where(google_id: google_identity.user_id).first_or_initialize
      user.email = google_identity.email_address # Always update email to stay in sync
      user.save!
      user
    end
  end

  def trial_ends_at
    if admin?
      1.day.from_now
    else
      created_at ? created_at + 15.days : nil
    end
  end

  def admin?
    # everyone @lightward.com
    email&.ends_with?("@lightward.com")
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
