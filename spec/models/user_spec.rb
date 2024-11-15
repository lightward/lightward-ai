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
      existing_user = described_class.create!(google_id: "123", email: "foo@bar.baz")
      user = described_class.for_google_identity(google_identity)
      expect(user.id).to(eq(existing_user.id))
    end
  end

  describe "validations" do
    let(:user) { described_class.new(google_id: "12345", email: "foo@bar.baz") }

    it "is valid with valid attributes" do
      expect(user).to(be_valid)
    end

    it "is not valid without a google_id" do
      user.google_id = nil
      expect(user).not_to(be_valid)
    end
  end

  describe "#pro?" do
    let(:user) { described_class.new(email: "foo@bar.baz") }

    it "returns true" do
      expect(user.pro?).to(be(true))
    end

    # it "returns true for lightward.com email addresses" do
    #   expect {
    #     user.email = "isaac@lightward.com"
    #   }.to(change(user, :pro?).from(false).to(true))
    # end
  end
end
