# frozen_string_literal: true

class User < ApplicationRecord
  after_create :create_default_buttons
  validates :google_id, presence: true

  has_many :buttons, dependent: :destroy

  class << self
    def for_google_identity(google_identity)
      where(google_id: google_identity.user_id).first_or_create!(
        email: google_identity.email_address,
      )
    end
  end

  def email=(email)
    username, domain = email.split("@", 2)
    self.email_obscured = "#{username.first(2)}…@#{domain.first(2)}…"
  end

  private

  def create_default_buttons
    buttons.create!(
      summary: "I'm a slow reader",
      prompt: "I'm a slow reader",
    )

    buttons.create!(
      summary: "I'm a fast reader",
      prompt: "I'm a fast reader",
    )
  end
end
