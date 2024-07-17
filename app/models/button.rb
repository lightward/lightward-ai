# frozen_string_literal: true

class Button < ApplicationRecord
  belongs_to :user

  validates :summary_ciphertext, presence: true
  validates :prompt_ciphertext, presence: true

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }

  def archive!
    update!(archived_at: Time.current)
  end

  def unarchive!
    update!(archived_at: nil)
  end

  def archived?
    archived_at.present?
  end

  def summary_ciphertext
    Base64.strict_encode64(summary_encrypted) if summary_encrypted
  end

  def summary_ciphertext=(value)
    self.summary_encrypted = value.nil? ? nil : Base64.decode64(value)
  end

  def prompt_ciphertext
    Base64.strict_encode64(prompt_encrypted) if prompt_encrypted
  end

  def prompt_ciphertext=(value)
    self.prompt_encrypted = value.nil? ? nil : Base64.decode64(value)
  end
end
