# frozen_string_literal: true

# spec/validators/base64_salt_validator_spec.rb
require "rails_helper"

RSpec.describe(Base64SaltValidator, type: :validator) do
  subject { user }

  let(:valid_salt) { Base64.strict_encode64(SecureRandom.random_bytes(16)) }
  let(:invalid_salt) { Base64.strict_encode64(SecureRandom.random_bytes(8)) }
  let(:non_base64_salt) { "non_base64_salt" }

  let(:user) { User.new(google_id: "12345", salt: salt) }

  context "when the salt is valid" do
    let(:salt) { valid_salt }

    it "is valid" do
      expect(user).to(be_valid)
    end
  end

  context "when the salt is not of size 16" do
    let(:salt) { invalid_salt }

    it "is not valid", :aggregate_failures do
      expect(user).not_to(be_valid)
      expect(user.errors[:salt]).to(include("must be a base64 encoded string of size 16"))
    end
  end

  context "when the salt is not a valid base64 string" do
    let(:salt) { non_base64_salt }

    it "is not valid", :aggregate_failures do
      expect(user).not_to(be_valid)
      expect(user.errors[:salt]).to(include("must be a valid base64 encoded string"))
    end
  end

  context "when the salt is nil" do
    let(:salt) { nil }

    it "is valid" do
      expect(user).to(be_valid)
    end
  end
end
