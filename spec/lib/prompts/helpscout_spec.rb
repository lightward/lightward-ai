# frozen_string_literal: true

# spec/helpscout_spec.rb

require "rails_helper"

RSpec.describe(Helpscout) do
  describe ".fetch_conversation" do
    let(:conversation_id) { 123 }
    let(:auth_token) { "fake_auth_token" }
    let(:conversation_response) {
      conversation = JSON.parse(Rails.root.join("spec/fixtures/helpscout_full_convo.json").read)
      conversation.merge("id" => conversation_id)
    }

    before do
      allow(described_class).to(receive(:cached_auth_token).and_return(auth_token))
    end

    it "fetches conversation with threads by default" do
      stub_request(:get, "https://api.helpscout.net/v2/conversations/#{conversation_id}?embed=threads")
        .with(headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" })
        .to_return(status: 200, body: conversation_response.to_json, headers: { "Content-Type" => "application/json" })

      result = described_class.fetch_conversation(conversation_id)

      expect(result["id"]).to(eq(conversation_id))
    end

    it "orders threads chronologically, oldest to newest" do
      stub_request(:get, "https://api.helpscout.net/v2/conversations/#{conversation_id}?embed=threads")
        .to_return(status: 200, body: conversation_response.to_json, headers: { "Content-Type" => "application/json" })

      result = described_class.fetch_conversation(conversation_id)

      threads = result["_embedded"]["threads"]
      expect(threads).to(eq(threads.sort_by { |thread| thread["createdAt"] }))
    end

    it "fetches conversation without threads" do
      stub_request(:get, "https://api.helpscout.net/v2/conversations/#{conversation_id}")
        .with(headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" })
        .to_return(status: 200, body: conversation_response.to_json, headers: { "Content-Type" => "application/json" })

      result = described_class.fetch_conversation(conversation_id, with_threads: false)

      expect(result["id"]).to(eq(conversation_id))
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

  describe ".conversation_concludes_with_assistant?" do
    let(:user_id) { 456 }
    let(:conversation) do
      {
        "_embedded" => {
          "threads" => [
            { "createdBy" => { "id" => user_id } },
          ],
        },
      }
    end

    before do
      allow(described_class).to(receive(:user_id).and_return(user_id))
    end

    it "returns true if the latest thread was created by the assistant" do
      result = described_class.conversation_concludes_with_assistant?(conversation)
      expect(result).to(be_truthy)
    end

    it "returns false if the latest thread was not created by the assistant" do
      conversation["_embedded"]["threads"].first["createdBy"]["id"] = 789
      result = described_class.conversation_concludes_with_assistant?(conversation)
      expect(result).to(be_falsey)
    end

    it "returns false if there are no threads" do
      conversation["_embedded"]["threads"] = []
      result = described_class.conversation_concludes_with_assistant?(conversation)
      expect(result).to(be_falsey)
    end
  end

  describe ".create_note" do
    let(:conversation_id) { 123 }
    let(:auth_token) { "fake_auth_token" }
    let(:note_body) { "This is a note" }

    before do
      allow(described_class).to(receive_messages(cached_auth_token: auth_token, user_id: 456))
    end

    it "creates a note successfully" do # rubocop:disable RSpec/ExampleLength
      stub_request(:post, "https://api.helpscout.net/v2/conversations/#{conversation_id}/notes")
        .with(
          headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" },
          body: { text: note_body, user: 456 }.to_json,
        )
        .to_return(status: 201, body: "", headers: {})

      expect {
        described_class.create_note(conversation_id, note_body)
      }.not_to(raise_error)
    end

    it "raises an error if creating the note fails" do # rubocop:disable RSpec/ExampleLength
      stub_request(:post, "https://api.helpscout.net/v2/conversations/#{conversation_id}/notes")
        .with(
          headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" },
          body: { text: note_body, user: 456 }.to_json,
        )
        .to_return(status: 400, body: "error", headers: {})

      expect {
        described_class.create_note(conversation_id, note_body)
      }.to(raise_error(Helpscout::ResponseError, "Failed to create note: 400\n\nerror"))
    end
  end

  describe ".create_draft_reply" do
    let(:conversation_id) { 123 }
    let(:auth_token) { "fake_auth_token" }
    let(:reply_body) { "This is a draft reply" }
    let(:customer_id) { 789 }

    before do
      allow(described_class).to(receive_messages(cached_auth_token: auth_token, user_id: 456))
    end

    it "creates a draft reply successfully" do # rubocop:disable RSpec/ExampleLength
      stub_request(:post, "https://api.helpscout.net/v2/conversations/#{conversation_id}/reply")
        .with(
          headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" },
          body: {
            text: reply_body,
            draft: true,
            user: 456,
            customer: { id: customer_id },
          }.to_json,
        )
        .to_return(status: 201, body: "", headers: {})

      expect {
        described_class.create_draft_reply(conversation_id, reply_body, customer_id: customer_id)
      }.not_to(raise_error)
    end

    it "raises an error if creating the draft reply fails" do # rubocop:disable RSpec/ExampleLength
      stub_request(:post, "https://api.helpscout.net/v2/conversations/#{conversation_id}/reply")
        .with(
          headers: { "Authorization" => "Bearer #{auth_token}", "Content-Type" => "application/json" },
          body: {
            text: reply_body,
            draft: true,
            user: 456,
            customer: { id: customer_id },
          }.to_json,
        )
        .to_return(status: 400, body: "error", headers: {})

      expect {
        described_class.create_draft_reply(conversation_id, reply_body, customer_id: customer_id)
      }.to(raise_error(Helpscout::ResponseError, "Failed to create draft reply: 400\n\nerror"))
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
