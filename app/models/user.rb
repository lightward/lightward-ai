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

  def email=(email)
    username, domain = email.split("@", 2)
    self.email_obscured = "#{username[0..2]}…@#{domain[0..2]}…"
  end
end
