# frozen_string_literal: true

# spec/helpscout_spec.rb

require "rails_helper"
require "httparty"

RSpec.describe(Helpscout) do
  describe ".fetch_conversation" do
    let(:conversation_id) { 123 }
    let(:auth_token) { "fake_auth_token" }
    let(:conversation_response) do
      {
        "id" => conversation_id,
        "subject" => "Test Conversation",
      }
    end

    before do
      allow(described_class).to(receive(:cached_auth_token).and_return(auth_token))
    end

    it "fetches conversation with threads" do
      stub_request(:get, "https://api.helpscout.net/v2/conversations/#{conversation_id}?embed=threads")
        .with(headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" })
        .to_return(status: 200, body: conversation_response.to_json, headers: { "Content-Type" => "application/json" })

      result = described_class.fetch_conversation(conversation_id, with_threads: true)

      expect(result).to(eq(conversation_response))
    end

    it "fetches conversation without threads" do
      stub_request(:get, "https://api.helpscout.net/v2/conversations/#{conversation_id}")
        .with(headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" })
        .to_return(status: 200, body: conversation_response.to_json, headers: { "Content-Type" => "application/json" })

      result = described_class.fetch_conversation(conversation_id, with_threads: false)

      expect(result).to(eq(conversation_response))
    end

    it "raises an error if the response is not successful" do # rubocop:disable RSpec/ExampleLength
      stub_request(:get, "https://api.helpscout.net/v2/conversations/#{conversation_id}?embed=threads")
        .with(headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" })
        .to_return(status: 404, body: "oh no!", headers: {})

      expect {
        described_class.fetch_conversation(conversation_id, with_threads: true)
      }.to(raise_error(Helpscout::ResponseError, "Failed to fetch conversation: 404\n\noh no!"))
    end
  end

  describe ".cached_auth_token" do
    let(:token_response) do
      {
        "token_type" => "bearer",
        "access_token" => "fake_access_token",
        "expires_in" => 172800,
      }
    end

    before do
      allow(Rails.cache).to(receive(:fetch).with("helpscout_auth_token", expires_in: 2.hours).and_yield)
      stub_request(:post, "https://api.helpscout.net/v2/oauth2/token")
        .with(body: {
          grant_type: "client_credentials",
          client_id: "fake_app_id",
          client_secret: "fake_app_secret",
        })
        .to_return(status: 200, body: token_response.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "caches the auth token" do
      token = described_class.send(:cached_auth_token)

      expect(token).to(eq(token_response["access_token"]))
    end

    it "raises an error if the auth token request fails" do # rubocop:disable RSpec/ExampleLength
      stub_request(:post, "https://api.helpscout.net/v2/oauth2/token")
        .with(body: {
          grant_type: "client_credentials",
          client_id: "fake_app_id",
          client_secret: "fake_app_secret",
        })
        .to_return(status: 401, body: "nope", headers: {})

      expect {
        described_class.send(:cached_auth_token)
      }.to(raise_error(Helpscout::ResponseError, "Failed to fetch auth token: 401\n\nnope"))
    end
  end
end
