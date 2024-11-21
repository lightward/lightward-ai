# frozen_string_literal: true

module StripeHelpers
  def stub_stripe_customer_lookup(email:, results: [])
    stub_request(:get, "https://api.stripe.com/v1/customers")
      .with(query: { email: email, limit: "1" })
      .to_return(body: { data: results }.to_json)
  end

  def stub_stripe_customer_create(email:, customer_id:)
    stub_request(:post, "https://api.stripe.com/v1/customers")
      .with(body: { email: email })
      .to_return(body: { id: customer_id }.to_json)
  end

  def stub_stripe_customer_get(customer_id:, status: 200, response_body: nil)
    stub_request(:get, "https://api.stripe.com/v1/customers/#{customer_id}")
      .to_return(
        status: status,
        body: response_body || (if status == 200
                                  { id: customer_id }.to_json
                                else
                                  {
                                    error: {
                                      type: "invalid_request_error",
                                      message: "No such customer: #{customer_id}",
                                      param: "id",
                                    },
                                  }.to_json
                                end
                               ),
      )
  end

  def stub_stripe_checkout_session_create(options = {})
    stub_request(:post, "https://api.stripe.com/v1/checkout/sessions")
      .with(body: hash_including(options))
      .to_return(body: {
        id: "cs_123",
        url: "https://checkout.stripe.com/123",
      }.to_json)
  end

  def stub_stripe_subscription_cancel(subscription_id:)
    stub_request(:delete, "https://api.stripe.com/v1/subscriptions/#{subscription_id}")
      .to_return(body: {
        id: subscription_id,
        status: "canceled",
      }.to_json)
  end
end

RSpec.configure do |config|
  config.include(StripeHelpers)

  config.before do
    # Set Stripe test values
    ENV["STRIPE_PRODUCT_ID"] = "prod_test123"
    ENV["STRIPE_SECRET_KEY"] = "sk_test_123"
    Stripe.api_key = "sk_test_123"
  end
end
