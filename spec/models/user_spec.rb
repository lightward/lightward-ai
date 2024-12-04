# frozen_string_literal: true

require "rails_helper"

RSpec.describe(User) do
  describe "associations and inclusions" do
    subject { described_class }

    it { is_expected.to(include(StripeCustomerConcern)) }
  end

  describe "validations" do
    subject(:user) { described_class.new(email: "user@example.com") }

    it "yells if google_id is missing" do
      expect(user.tap(&:validate).errors[:google_id]).to(include("can't be blank"))
    end
  end

  describe ".for_google_identity" do
    let(:google_identity) do
      instance_double(
        GoogleSignIn::Identity,
        user_id: "123",
        email_address: "user@example.com",
      )
    end

    context "when user does not exist" do
      it "creates a new user" do
        expect {
          described_class.for_google_identity(google_identity)
        }.to(change(described_class, :count).by(1))
      end

      it "sets correct attributes" do
        user = described_class.for_google_identity(google_identity)

        expect(user).to(have_attributes(
          google_id: "123",
          email: "user@example.com",
        ))
      end
    end

    context "when user exists" do
      let!(:existing_user) do
        described_class.create!(
          google_id: "123",
          email: "old@example.com",
        )
      end

      it "returns existing user" do
        user = described_class.for_google_identity(google_identity)
        expect(user).to(eq(existing_user))
      end

      it "does not create new user" do
        expect {
          described_class.for_google_identity(google_identity)
        }.not_to(change(described_class, :count))
      end

      it "updates email if changed" do
        user = described_class.for_google_identity(google_identity)
        expect(user.email).to(eq("user@example.com"))
      end
    end
  end

  describe "#trial_ends_at" do
    let(:user) { described_class.new(google_id: "12345", email: "user@example.com", created_at: 1.day.ago) }

    context "when user is admin" do
      before { allow(user).to(receive(:admin?).and_return(true)) }

      it "returns 1 day from now" do
        expect(user.trial_ends_at).to(be_within(1.second).of(1.day.from_now))
      end
    end

    context "when user is not admin" do
      before { allow(user).to(receive(:admin?).and_return(false)) }

      context "when created_at is present" do
        it "returns 15 days from created_at" do
          expect(user.trial_ends_at).to(be_within(1.second).of(user.created_at + 15.days))
        end
      end

      context "when created_at is nil" do
        before { user.created_at = nil }

        it "returns nil" do
          expect(user.trial_ends_at).to(be_nil)
        end
      end
    end
  end

  describe "#admin?" do
    let(:user) { described_class.new(google_id: "12345") }

    context "with lightward.com email" do
      it "returns true" do
        user.email = "user@lightward.com"
        expect(user).to(be_admin)
      end
    end

    context "with non-lightward.com email" do
      it "returns false" do
        user.email = "user@example.com"
        expect(user).not_to(be_admin)
      end
    end

    context "with nil email" do
      it "returns false" do
        user.email = nil
        expect(user).not_to(be_admin)
      end
    end
  end

  describe "#subscriber?" do
    let(:user) { described_class.new(google_id: "12345", email: "user@example.com") }

    context "with stripe_subscription_id" do
      it "returns true" do
        user.stripe_subscription_id = "sub_123"
        expect(user).to(be_subscriber)
      end
    end

    context "without stripe_subscription_id" do
      it "returns false" do
        user.stripe_subscription_id = nil
        expect(user).not_to(be_subscriber)
      end
    end
  end

  describe "#active?" do
    let(:user) { described_class.new(google_id: "12345", email: "user@example.com", created_at: 10.days.ago) }

    context "when user is subscriber" do
      before { allow(user).to(receive(:subscriber?).and_return(true)) }

      it "returns true" do
        expect(user).to(be_active)
      end
    end

    context "when trial_ends_at is nil" do
      before { allow(user).to(receive(:trial_ends_at).and_return(nil)) }

      it "returns true" do
        expect(user).to(be_active)
      end
    end

    context "when during trial period" do
      before do
        allow(user).to(receive_messages(subscriber?: false, trial_ends_at: 5.days.from_now))
      end

      it "returns true" do
        expect(user).to(be_active)
      end
    end

    context "when after trial expiration" do
      before do
        allow(user).to(receive_messages(subscriber?: false, trial_ends_at: 1.day.ago))
      end

      it "returns false" do
        expect(user).not_to(be_active)
      end
    end
  end
end
