# frozen_string_literal: true

# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    google_id { "12345" }
    email { "test@example.com" }
    public_key { OpenSSL::PKey::RSA.new(2048).public_key.to_pem }
    private_key_encrypted { "valid_encrypted_string" }
    salt { SecureRandom.random_bytes(16) }
  end
end
