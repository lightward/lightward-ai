# frozen_string_literal: true

# spec/controllers/subscriptions_controller_spec.rb
require "rails_helper"

RSpec.describe(SubscriptionsController, :aggregate_failures) do
  let(:user) { User.create!(google_id: "123", email: "test@example.com") }

  before do
    allow(controller).to(receive(:current_user).and_return(user))
  end

  describe "#start" do
    before do
      stub_stripe_customer_lookup(email: user.email)
      stub_stripe_customer_create(email: user.email, customer_id: "cus_123")

      user.update!(subscription_price_usd: 5)
    end

    it "creates a checkout session and redirects" do
      stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
        .with(
          body: {
            "cancel_url" => "http://test.host/you",
            "customer" => "cus_123",
            "line_items" => [{
              "price_data" => {
                "currency" => "usd",
                "product" => "prod_test123",
                "unit_amount" => "500",
                "recurring" => { "interval" => "month" },
              },
              "quantity" => "1",
            }],
            "mode" => "subscription",
            "subscription_data" => { "trial_period_days" => "15" },
            "success_url" => "http://test.host/pro/subscription/confirm?session_id={CHECKOUT_SESSION_ID}",
          },
        )
        .to_return(body: { id: "cs_123", url: "https://checkout.stripe.com/123" }.to_json)

      put(:start)

      expect(response).to(redirect_to("https://checkout.stripe.com/123"))
    end

    it "rounds up trial days" do
      user.update!(trial_expires_at: 1.week.from_now - 13.hours)

      stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
        .with(
          body: hash_including("subscription_data" => { "trial_period_days" => "7" }),
        )
        .to_return(body: { id: "cs_123", url: "https://checkout.stripe.com/123" }.to_json)

      put(:start)

      expect(response).to(redirect_to("https://checkout.stripe.com/123"))
    end
  end

  describe "#confirm" do
    it "updates user with subscription id" do
      stub_request(:get, "https://api.stripe.com/v1/checkout/sessions/cs_123")
        .to_return(body: { subscription: "sub_123" }.to_json)

      stub_request(:get, "https://api.stripe.com/v1/subscriptions/sub_123")
        .to_return(body: { id: "sub_123" }.to_json)

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
