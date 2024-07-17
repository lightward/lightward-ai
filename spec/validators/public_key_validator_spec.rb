# frozen_string_literal: true

# spec/validators/public_key_validator_spec.rb
require "rails_helper"

RSpec.describe(PublicKeyValidator, type: :validator) do
  subject { user }

  let(:valid_rsa_key) { OpenSSL::PKey::RSA.new(2048).public_key.to_pem }
  let(:invalid_rsa_key) { "invalid_rsa_key" }

  let(:user) { build(:user, public_key: public_key) }

  context "when the public key is valid" do
    let(:public_key) { valid_rsa_key }

    it "is valid" do
      expect(user).to(be_valid)
    end
  end

  context "when the public key is invalid" do
    let(:public_key) { invalid_rsa_key }

    it "is not valid", :aggregate_failures do
      expect(user).not_to(be_valid)
      expect(user.errors[:public_key]).to(include("must be a valid RSA public key"))
    end
  end

  context "when the public key is nil" do
    let(:public_key) { nil }

    it "has no public_key errors" do
      expect(user.errors[:public_key]).to(be_empty)
    end
  end
end
