# frozen_string_literal: true

# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    google_id { "12345" }
    email { "test@example.com" }
    public_key { Base64.strict_encode64(OpenSSL::PKey::RSA.new(2048).public_key.to_pem) }
    encrypted_private_key { Base64.strict_encode64("valid_encrypted_string") }
    salt { Base64.strict_encode64(SecureRandom.random_bytes(16)) }
  end
end
