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
        user.public_key = valid_rsa_key
        expect(user).to(be_valid)
      end

      it "is not valid with an invalid public_key", :aggregate_failures do
        user.public_key = invalid_rsa_key
        expect(user).not_to(be_valid)
        expect(user.errors[:public_key]).to(include("must be a valid RSA public key"))
      end

      it "is valid with a nil public_key" do
        user.public_key = user.private_key_encrypted = user.salt = nil
        expect(user).to(be_valid)
      end

      it "is not valid if only the public_key is missing" do
        user.public_key = nil
        expect(user).not_to(be_valid)
      end
    end

    describe "private_key_encrypted validations" do
      it "is valid with a valid private_key_encrypted" do
        user.private_key_encrypted = "opaque value"
        expect(user).to(be_valid)
      end

      it "is valid with a nil private_key_encrypted" do
        user.public_key = user.private_key_encrypted = user.salt = nil
        expect(user).to(be_valid)
      end

      it "is not valid if only the private_key_encrypted is missing" do
        user.private_key_encrypted = nil
        expect(user).not_to(be_valid)
      end
    end

    describe "salt validations" do
      let(:valid_salt) { SecureRandom.random_bytes(16) }
      let(:invalid_salt) { SecureRandom.random_bytes(8) }

      it "is valid with a valid salt" do
        user.salt = valid_salt
        expect(user).to(be_valid)
      end

      it "is not valid with a salt of incorrect size", :aggregate_failures do
        user.salt = invalid_salt
        expect(user).not_to(be_valid)
        expect(user.errors[:salt]).to(include("is the wrong length (should be 16 characters)"))
      end

      it "is valid with a nil salt" do
        user.salt = user.public_key = user.private_key_encrypted = nil
        expect(user).to(be_valid)
      end

      it "is not valid if only the salt is missing" do
        user.salt = nil
        expect(user).not_to(be_valid)
      end
    end
  end

  describe "#encrypt" do
    let(:user) { create(:user, public_key: OpenSSL::PKey::RSA.new(2048).public_key.to_pem) }
    let(:plaintext) { "some sensitive data" }

    it "raises an error if the plaintext is not a string" do
      expect { user.encrypt(123) }.to(raise_error(ArgumentError, "Argument must be a string"))
    end

    it "raises an error if the public_key is missing" do
      user.update!(public_key: nil, private_key_encrypted: nil, salt: nil)
      expect { user.encrypt(plaintext) }.to(raise_error(ArgumentError, "Public key is missing"))
    end

    it "encrypts the plaintext", :aggregate_failures do
      encrypted = user.encrypt(plaintext)
      expect(encrypted).not_to(be_nil)
      expect(encrypted).not_to(eq(plaintext))
    end
  end
end
