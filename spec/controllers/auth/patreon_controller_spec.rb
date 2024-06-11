# frozen_string_literal: true

# spec/controllers/auth/patreon_controller_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe(Auth::PatreonController) do
  describe "GET #login" do
    let(:oauth_url) { "https://www.patreon.com/oauth2/authorize?response_type=code&client_id=fake_client_id&redirect_uri=https://test.host/auth/patreon/callback&scope=identity" }

    before do
      allow(Patreon).to(receive(:oauth_url).and_return(oauth_url))
    end

    it "redirects to the Patreon OAuth URL" do
      get :login
      expect(response).to(redirect_to(oauth_url))
    end
  end

  describe "GET #logout" do
    it "clears the session and redirects to root path", :aggregate_failures do
      session[:user_id] = 1
      get :logout
      expect(session[:user_id]).to(be_nil)
      expect(response).to(redirect_to(root_path))
    end
  end

  describe "GET #callback" do
    let(:code) { "fake_code" }
    let(:token_url) { "https://www.patreon.com/api/oauth2/token" }
    let(:access_token) { "fake_access_token" }
    let(:user_id) { 123 }
    let(:oauth_response_body) { { "access_token" => access_token } }
    let(:user_status) do
      {
        id: user_id,
        paid: true,
        expires_at: Time.parse("2024-07-01T00:00:00Z"),
      }
    end

    context "when OAuth callback is successful" do
      before do
        stub_request(:post, token_url).to_return_json(status: 200, body: oauth_response_body)
        allow(Patreon).to(receive(:user_status).with(access_token: access_token).and_return(user_status))
      end

      it "sets the session and redirects to root path", :aggregate_failures do
        get :callback, params: { code: code }
        expect(session[:user_id]).to(eq(user_id))
        expect(response).to(redirect_to(root_path))
      end
    end

    context "when OAuth callback fails" do
      before do
        stub_request(:post, token_url).to_return(status: 400, body: { error: "invalid_grant" }.to_json)
        allow(Patreon).to(receive(:oauth_callback).and_raise(Patreon::OauthError))
      end

      it "renders an error message", :aggregate_failures do
        get :callback, params: { code: code }
        expect(response.body).to(include("Failed to authenticate with Patreon! Oh no! Go back and try again?"))
        expect(response).to(have_http_status(:unauthorized))
      end
    end
  end
end
