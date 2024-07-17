# frozen_string_literal: true

# spec/validators/encrypted_string_validator_spec.rb
require "rails_helper"

RSpec.describe(EncryptedStringValidator, type: :validator) do
  subject { user }

  let(:valid_encrypted_string) { Base64.strict_encode64("valid_encrypted_string") }
  let(:invalid_encrypted_string) { "invalid_base64_string" }

  let(:user) { User.new(google_id: "12345", encrypted_private_key: encrypted_private_key) }

  context "when the encrypted private key is valid" do
    let(:encrypted_private_key) { valid_encrypted_string }

    it "is valid" do
      expect(user).to(be_valid)
    end
  end

  context "when the encrypted private key is invalid" do
    let(:encrypted_private_key) { invalid_encrypted_string }

    it "is not valid", :aggregate_failures do
      expect(user).not_to(be_valid)
      expect(user.errors[:encrypted_private_key]).to(include("must be a valid base64 encoded string"))
    end
  end

  context "when the encrypted private key is nil" do
    let(:encrypted_private_key) { nil }

    it "is valid" do
      expect(user).to(be_valid)
    end
  end
end
