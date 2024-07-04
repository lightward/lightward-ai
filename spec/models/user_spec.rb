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
end
