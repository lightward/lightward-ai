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

  describe "#active?" do
    let(:user) { described_class.create!(google_id: "12345", email: "foo@bar.baz") }

    context "with subscription" do
      before { user.update!(stripe_subscription_id: "sub_123") }

      it { expect(user).to(be_active) }
    end

    context "when during trial period" do
      it { expect(user).to(be_active) }
    end

    context "when after trial expiration" do
      before { user.update!(created_at: 16.days.ago) }

      it { expect(user).not_to(be_active) }
    end

    context "when record is new" do
      let(:user) { described_class.new(google_id: "12345", email: "foo@bar.baz") }

      it { expect(user).to(be_active) }
    end
  end

  describe "#admin?" do
    let(:user) { described_class.new(email: "foo@bar.baz") }

    it "returns true for lightward.com email addresses" do
      expect {
        user.email = "isaac@lightward.com"
      }.to(change(user, :admin?).from(false).to(true))
    end
  end
end
