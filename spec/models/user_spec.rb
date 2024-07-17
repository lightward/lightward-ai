# frozen_string_literal: true

# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe(User) do
  describe ".for_google_identity" do
    let(:google_identity) {
      instance_double(GoogleSignIn::Identity, user_id: "123", email_address: "foo@bar.baz")
    }

    it "returns a user by google id" do
      user = described_class.for_google_identity(google_identity)
      expect(user.google_id).to(eq("123"))
    end

    it "creates a user if one does not exist" do
      expect { described_class.for_google_identity(google_identity) }.to(change(described_class, :count).by(1))
    end

    it "retrieves an existing user" do
      existing_user = described_class.create!(google_id: "123", email_obscured: "fo…@ba…")
      user = described_class.for_google_identity(google_identity)
      expect(user.id).to(eq(existing_user.id))
    end

    it "obscures the email" do
      user = described_class.for_google_identity(google_identity)
      expect(user.email_obscured).to(eq("fo…@ba…"))
    end
  end

  describe "validations" do
    let(:user) { build(:user) } # assuming you have a factory for User

    it "is valid with valid attributes" do
      expect(user).to(be_valid)
    end

    it "is not valid without a google_id" do
      user.google_id = nil
      expect(user).not_to(be_valid)
    end

    describe "public_key validations" do
      let(:valid_rsa_key) { OpenSSL::PKey::RSA.new(2048).public_key.to_pem }
      let(:invalid_rsa_key) { "invalid_rsa_key" }

      it "is valid with a valid public_key" do
        user.public_key = Base64.strict_encode64(valid_rsa_key)
        expect(user).to(be_valid)
      end

      it "is not valid with an invalid public_key", :aggregate_failures do
        user.public_key = invalid_rsa_key
        expect(user).not_to(be_valid)
        expect(user.errors[:public_key]).to(include("must be a valid RSA public key"))
      end

      it "is valid with a nil public_key" do
        user.public_key = nil
        expect(user).to(be_valid)
      end
    end

    describe "encrypted_private_key validations" do
      let(:valid_encrypted_string) { Base64.strict_encode64("valid_encrypted_string") }
      let(:invalid_encrypted_string) { "invalid_base64_string" }

      it "is valid with a valid encrypted_private_key" do
        user.encrypted_private_key = valid_encrypted_string
        expect(user).to(be_valid)
      end

      it "is not valid with an invalid encrypted_private_key", :aggregate_failures do
        user.encrypted_private_key = invalid_encrypted_string
        expect(user).not_to(be_valid)
        expect(user.errors[:encrypted_private_key]).to(include("must be a valid base64 encoded string"))
      end

      it "is valid with a nil encrypted_private_key" do
        user.encrypted_private_key = nil
        expect(user).to(be_valid)
      end
    end

    describe "salt validations" do
      let(:valid_salt) { Base64.strict_encode64(SecureRandom.random_bytes(16)) }
      let(:invalid_salt) { Base64.strict_encode64(SecureRandom.random_bytes(8)) }
      let(:non_base64_salt) { "non_base64_salt" }

      it "is valid with a valid salt" do
        user.salt = valid_salt
        expect(user).to(be_valid)
      end

      it "is not valid with a salt of incorrect size", :aggregate_failures do
        user.salt = invalid_salt
        expect(user).not_to(be_valid)
        expect(user.errors[:salt]).to(include("must be a base64 encoded string of size 16"))
      end

      it "is not valid with a non-base64 salt", :aggregate_failures do
        user.salt = non_base64_salt
        expect(user).not_to(be_valid)
        expect(user.errors[:salt]).to(include("must be a valid base64 encoded string"))
      end

      it "is valid with a nil salt" do
        user.salt = nil
        expect(user).to(be_valid)
      end
    end
  end

  describe "#encrypt" do
    let(:user) { create(:user, public_key: Base64.strict_encode64(OpenSSL::PKey::RSA.new(2048).public_key.to_pem)) }
    let(:plaintext) { "some sensitive data" }

    it "raises an error if the plaintext is not a string" do
      expect { user.encrypt(123) }.to(raise_error(ArgumentError, "Argument must be a string"))
    end

    it "raises an error if the public_key is missing" do
      user.update!(public_key: nil)
      expect { user.encrypt(plaintext) }.to(raise_error(ArgumentError, "Public key is missing"))
    end

    it "encrypts the plaintext", :aggregate_failures do
      encrypted = user.encrypt(plaintext)
      expect(encrypted).not_to(be_nil)
      expect(encrypted).not_to(eq(plaintext))
    end
  end
end
