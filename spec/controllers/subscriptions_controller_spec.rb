# frozen_string_literal: true

# spec/controllers/subscriptions_controller_spec.rb
require "rails_helper"

RSpec.describe(SubscriptionsController, :aggregate_failures) do
  let(:user) { User.create!(google_id: "123", email: "test@example.com", trial_expires_at: 2.weeks.from_now) }

  before do
    allow(controller).to(receive(:current_user).and_return(user))

    # Set Stripe test values
    ENV["STRIPE_PRICE_ID"] = "price_test123"
    ENV["STRIPE_SECRET_KEY"] = "sk_test_123"
    Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
  end

  describe "#start" do
    before do
      stub_stripe_customer_lookup(email: user.email)
      stub_stripe_customer_create(email: user.email, customer_id: "cus_123")
    end

    it "creates a checkout session and redirects" do
      stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
        .with(
          body: hash_including(
            "mode" => "subscription",
            "customer" => "cus_123",
            "success_url" => "http://test.host/pro/subscription/confirm?session_id={CHECKOUT_SESSION_ID}",
            "cancel_url" => "http://test.host/you",
            "line_items" => [{ "price" => "price_test123", "quantity" => "1" }],
            "subscription_data" => { "trial_period_days" => "14" },
          ),
        )
        .to_return(body: { id: "cs_123", url: "https://checkout.stripe.com/123" }.to_json)

      put(:start)

      expect(response).to(redirect_to("https://checkout.stripe.com/123"))
    end
  end

  describe "#confirm" do
    it "updates user with subscription details" do
      stub_request(:get, "https://api.stripe.com/v1/checkout/sessions/cs_123")
        .to_return(body: { subscription: "sub_123" }.to_json)

      stub_request(:get, "https://api.stripe.com/v1/subscriptions/sub_123")
        .to_return(body: {
          id: "sub_123",
          trial_end: 2.weeks.from_now.to_i,
        }.to_json)

      get(:confirm, params: { session_id: "cs_123" })

      expect(user.reload.stripe_subscription_id).to(eq("sub_123"))
      expect(response).to(redirect_to(user_url))
    end
  end

  describe "#cancel" do
    context "with active subscription" do
      before { user.update!(stripe_subscription_id: "sub_123") }

      it "cancels subscription and updates user" do
        stub_request(:delete, "https://api.stripe.com/v1/subscriptions/sub_123")
          .to_return(body: { id: "sub_123", status: "canceled" }.to_json)

        delete(:cancel)

        expect(user.reload.stripe_subscription_id).to(be_nil)
        expect(response).to(redirect_to(user_url))
      end
    end

    context "without active subscription" do
      it "returns unprocessable entity" do
        delete(:cancel)
        expect(response).to(have_http_status(:unprocessable_entity))
      end
    end
  end
end
