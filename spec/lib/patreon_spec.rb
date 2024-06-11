# frozen_string_literal: true

# spec/lib/patreon_spec.rb
require "rails_helper"

RSpec.describe(Patreon) do
  let(:host) { "test.host" }
  let(:oauth_redirect_url) { "https://#{host}/auth/patreon/callback" }

  before do
    allow(Rails.application.routes).to(receive(:url_for).and_return(oauth_redirect_url))
  end

  describe ".client_id" do
    it "returns the PATREON_CLIENT_ID from the environment" do
      expect(described_class.client_id).to(eq(ENV.fetch("PATREON_CLIENT_ID")))
    end
  end

  describe ".client_secret" do
    it "returns the PATREON_CLIENT_SECRET from the environment" do
      expect(described_class.client_secret).to(eq(ENV.fetch("PATREON_CLIENT_SECRET")))
    end
  end

  describe ".oauth_redirect_url" do
    it "returns the correct redirect URL" do
      expect(described_class.oauth_redirect_url).to(eq(oauth_redirect_url))
    end
  end

  describe ".oauth_url" do
    it "returns the correct OAuth URL" do
      expected_url = "https://www.patreon.com/oauth2/authorize?client_id=fake_client_id&redirect_uri=#{CGI.escape(oauth_redirect_url)}&response_type=code&scope=identity"
      expect(described_class.oauth_url).to(eq(expected_url))
    end
  end

  describe ".oauth_callback" do
    let(:code) { "fake_code" }
    let(:token_url) { "https://www.patreon.com/api/oauth2/token" }
    let(:response_body) { { access_token: "fake_access_token" }.to_json }

    context "when the response is successful" do
      before do
        stub_request(:post, token_url).to_return(status: 200, body: response_body)
      end

      it "returns the response" do
        response = described_class.oauth_callback(code: code)
        expect(response.body).to(eq(response_body))
      end
    end

    context "when the response is unsuccessful" do
      before do
        stub_request(:post, token_url).to_return(status: 400, body: { error: "invalid_grant" }.to_json)
      end

      it "raises an OauthError" do
        expect { described_class.oauth_callback(code: code) }.to(raise_error(Patreon::OauthError))
      end
    end
  end

  describe ".user_identity" do
    let(:access_token) { "fake_access_token" }
    let(:identity_url) { "https://www.patreon.com/api/oauth2/v2/identity" }
    let(:response_body) { { data: { id: "123" }, included: [] }.to_json }

    before do
      stub_request(:get, identity_url).with(
        headers: { "Authorization" => "Bearer #{access_token}" },
        query: { include: "memberships", "fields[member]": "patron_status,next_charge_date" },
      ).to_return(status: 200, body: response_body)
    end

    it "returns the response" do
      response = described_class.user_identity(access_token: access_token)
      expect(response.body).to(eq(response_body))
    end
  end

  describe ".user_status" do
    let(:access_token) { "fake_access_token" }
    let(:identity_response) do
      {
        data: { id: "123" },
        included: [{ attributes: { patron_status: "active_patron", next_charge_date: "2024-07-01T00:00:00Z" } }],
      }.deep_stringify_keys
    end

    before do
      allow(described_class).to(receive(:user_identity).with(access_token: access_token).and_return(identity_response))
    end

    it "returns the user status" do # rubocop:disable RSpec/ExampleLength
      expected_status = {
        id: 123,
        paid: true,
        expires_at: Time.parse("2024-07-01T00:00:00Z"),
      }

      expect(described_class.user_status(access_token: access_token)).to(eq(expected_status))
    end
  end
end
