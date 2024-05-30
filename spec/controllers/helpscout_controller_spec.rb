# frozen_string_literal: true

# spec/controllers/webhooks_controller_spec.rb

require "rails_helper"

RSpec.describe(HelpscoutController, :aggregate_failures) do
  describe "POST #receive" do
    let(:valid_signature) { "M7u2/3y+EEtyynwkIcP2sihS0Q8=" }
    let(:invalid_signature) { "invalidsignature==" }
    let(:data) { Rails.root.join("spec/fixtures/helpscout_convo_created.txt").read }
    let(:parsed_data) { data.split("\n\n").last } # Extract the JSON body from the raw request

    before do
      request.headers["X-HelpScout-Signature"] = valid_signature
      request.headers["Content-Type"] = "application/json"
    end

    context "with valid signature" do
      it "verifies the request and returns status 200" do
        allow(OpenSSL::HMAC).to(receive(:digest).and_return(Base64.decode64(valid_signature)))

        post :receive, body: parsed_data

        expect(response).to(have_http_status(:ok))
        expect(response.body).to(eq({ message: "Webhook received and verified" }.to_json))
      end
    end

    context "with invalid signature" do
      it "returns status 401" do
        request.headers["X-HelpScout-Signature"] = invalid_signature

        post :receive, body: parsed_data

        expect(response).to(have_http_status(:unauthorized))
        expect(response.body).to(eq({ message: "Invalid signature" }.to_json))
      end
    end
  end
end
