# frozen_string_literal: true

# spec/models/concerns/stripe_customer_concern_spec.rb
require "rails_helper"

RSpec.describe(StripeCustomerConcern, :aggregate_failures) do
  let(:user) { User.create!(google_id: "123", email: "test@example.com") }

  describe "#ensure_stripe_customer!" do
    context "when stripe_customer_id is nil" do
      before { stub_stripe_customer_lookup(email: user.email) }

      it "creates a new customer when none exists" do
        stub_stripe_customer_create(email: user.email, customer_id: "cus_new")

        customer = user.ensure_stripe_customer!
        expect(customer.id).to(eq("cus_new"))
        expect(user.reload.stripe_customer_id).to(eq("cus_new"))
      end

      it "uses existing customer when found by email" do
        stub_stripe_customer_lookup(
          email: user.email,
          results: [{ id: "cus_existing" }],
        )

        customer = user.ensure_stripe_customer!
        expect(customer.id).to(eq("cus_existing"))
        expect(user.reload.stripe_customer_id).to(eq("cus_existing"))
      end
    end

    context "when stripe_customer_id is present" do
      before { user.update!(stripe_customer_id: "cus_old") }

      it "returns existing customer if valid" do
        stub_stripe_customer_get(customer_id: "cus_old")

        customer = user.ensure_stripe_customer!
        expect(customer.id).to(eq("cus_old"))
        expect(user.reload.stripe_customer_id).to(eq("cus_old"))
      end

      it "creates new customer if existing ID is invalid" do
        stub_stripe_customer_get(customer_id: "cus_old", status: 404)
        stub_stripe_customer_lookup(email: user.email)
        stub_stripe_customer_create(email: user.email, customer_id: "cus_new")

        customer = user.ensure_stripe_customer!
        expect(customer.id).to(eq("cus_new"))
        expect(user.reload.stripe_customer_id).to(eq("cus_new"))
      end

      it "uses existing customer by email if found after invalid ID" do
        stub_stripe_customer_get(customer_id: "cus_old", status: 404)
        stub_stripe_customer_lookup(
          email: user.email,
          results: [{ id: "cus_existing" }],
        )

        customer = user.ensure_stripe_customer!
        expect(customer.id).to(eq("cus_existing"))
        expect(user.reload.stripe_customer_id).to(eq("cus_existing"))
      end
    end
  end
end
