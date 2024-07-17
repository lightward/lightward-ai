# frozen_string_literal: true

class User < ApplicationRecord
  validates :google_id, presence: true

  validates :public_key, public_key: true, allow_nil: true
  validates :salt, allow_nil: true, length: { is: 16 }

  # all or nothing
  validates :public_key, :private_key_encrypted, :salt, presence: true, if: -> {
    public_key.present? || private_key_encrypted.present? || salt.present?
  }

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

  def encrypt(plaintext)
    raise ArgumentError, "Argument must be a string" unless plaintext.is_a?(String)

    raise ArgumentError, "Public key is missing" if public_key.blank?

    # Convert the stored public key string to an OpenSSL::PKey::RSA object
    rsa_public = OpenSSL::PKey::RSA.new(public_key)

    # Encrypt the plaintext
    encrypted = rsa_public.public_encrypt(plaintext, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)

    # Return the encrypted data as a Base64 encoded string
    Base64.strict_encode64(encrypted)
  end

  def public_key_base64
    Base64.strict_encode64(public_key) if public_key
  end

  def public_key_base64=(value)
    self.public_key = value.nil? ? nil : Base64.decode64(value)
  end

  def private_key_ciphertext
    Base64.strict_encode64(private_key_encrypted) if private_key_encrypted
  end

  def private_key_ciphertext=(value)
    self.private_key_encrypted = value.nil? ? nil : Base64.decode64(value)
  end

  def salt_base64
    Base64.strict_encode64(salt) if salt
  end

  def salt_base64=(value)
    self.salt = value.nil? ? nil : Base64.decode64(value)
  end
end
