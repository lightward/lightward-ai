# frozen_string_literal: true

class User < ApplicationRecord
  validates :google_id, presence: true

  class << self
    def for_google_identity(google_identity)
      where(google_id: google_identity.user_id).first_or_create!(
        email: google_identity.email_address,
      )
    end
  end

  def pro?
    # all auth'd users, for now :) secret soft launch. we'll lock this down when payments are ready to roll
    true
  end

  def admin?
    # everyone @lightward.com
    email.ends_with?("@lightward.com")
  end
end
