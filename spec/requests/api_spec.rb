# frozen_string_literal: true

# spec/requests/api_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe("API", type: :request) do
  before do
    host! ENV.fetch("HOST", "test.host")

    # Stub Anthropic API token counting
    stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
      .to_return(
        status: 200,
        body: { input_tokens: 100 }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

    # Stub Anthropic API streaming response
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .to_return(
        status: 200,
        body: "event: message_start\ndata: {\"type\":\"message_start\"}\n\nevent: content_block_delta\ndata: {\"type\":\"content_block_delta\",\"delta\":{\"type\":\"text_delta\",\"text\":\"Hello\"}}\n\nevent: message_stop\ndata: {\"type\":\"message_stop\"}\n\n",
        headers: { "Content-Type" => "text/event-stream" },
      )
  end

  describe "POST /api/stream" do
    let(:chat_log) do
      [
        {
          role: "user",
          content: [{ type: "text", text: "Hello!" }],
        },
      ]
    end

    it "streams a response with SSE format", :aggregate_failures do
      post "/api/stream", params: { chat_log: chat_log }

      expect(response).to(have_http_status(:ok))
      expect(response.headers["Content-Type"]).to(eq("text/event-stream"))
    end

    context "with chat opening message" do
      let(:chat_log) do
        [
          {
            role: "user",
            content: [{ type: "text", text: "I'm a slow reader" }],
          },
        ]
      end

      it "uses clients/chat prompt type" do
        # This test verifies the route works - actual prompt selection
        # is tested at the unit level
        post "/api/stream", params: { chat_log: chat_log }
        expect(response).to(have_http_status(:ok))
      end
    end

    context "with API message" do
      let(:chat_log) do
        [
          {
            role: "user",
            content: [{ type: "text", text: "What is the meaning of life?" }],
          },
        ]
      end

      it "uses clients/api prompt type" do
        # This test verifies the route works - actual prompt selection
        # is tested at the unit level
        post "/api/stream", params: { chat_log: chat_log }
        expect(response).to(have_http_status(:ok))
      end
    end

    context "when chat log exceeds token limit" do
      before do
        # Stub token count to return over the limit
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: { input_tokens: 51_000 }.to_json,
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "returns an error about conversation horizon", :aggregate_failures do
        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include("Conversation horizon has arrived"))
        expect(response.body).to(include("event: error"))
      end
    end

    context "when approaching token limit (90%)" do
      before do
        # Stub token count to return 90% of limit (45,000 tokens)
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: { input_tokens: 45_000 }.to_json,
            headers: { "Content-Type" => "application/json" },
          )

        # Update streaming response to include message_start and content_block_stop
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(
            status: 200,
            body: "event: message_start\ndata: {\"type\":\"message_start\"}\n\nevent: content_block_delta\ndata: {\"type\":\"content_block_delta\",\"delta\":{\"type\":\"text_delta\",\"text\":\"Hello\"}}\n\nevent: content_block_stop\ndata: {\"type\":\"content_block_stop\"}\n\nevent: message_stop\ndata: {\"type\":\"message_stop\"}\n\n",
            headers: { "Content-Type" => "text/event-stream" },
          )
      end

      it "injects a horizon warning in the response", :aggregate_failures do
        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include("Memory space 90% utilized"))
        expect(response.body).to(include("conversation horizon approaching"))
      end

      context "when the warning has already appeared in chat log" do
        let(:chat_log) do
          [
            {
              role: "user",
              content: [{ type: "text", text: "Hello!" }],
            },
            {
              role: "assistant",
              content: [{ type: "text", text: "Memory space 90% utilized; conversation horizon approaching" }],
            },
            {
              role: "user",
              content: [{ type: "text", text: "More stuff" }],
            },
          ]
        end

        it "does not inject the warning again", :aggregate_failures do
          post "/api/stream", params: { chat_log: chat_log }

          expect(response).to(have_http_status(:ok))
          # Count occurrences of the warning - should only be the one in chat_log, not a new one
          warning_count = response.body.scan("Memory space 90% utilized").count
          expect(warning_count).to(eq(0)) # Should not appear in the SSE stream since it's already in chat_log
        end
      end
    end

    context "with token limit bypass header" do
      let(:bypass_token) { "secret-bypass-token" }

      before do
        # Stub token count to return over the limit
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: { input_tokens: 51_000 }.to_json,
            headers: { "Content-Type" => "application/json" },
          )

        # Set the env var
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("DISABLE_TOKEN_LIMIT_AUTHORIZATION").and_return(bypass_token))
      end

      it "bypasses token limit when header matches env var", :aggregate_failures do
        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "Disable-Token-Limit-Authorization" => bypass_token }

        expect(response).to(have_http_status(:ok))
        expect(response.body).not_to(include("Conversation horizon has arrived"))
        expect(response.body).not_to(include("event: error"))
      end

      it "enforces token limit when header does not match env var", :aggregate_failures do
        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "Disable-Token-Limit-Authorization" => "wrong-token" }

        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include("Conversation horizon has arrived"))
        expect(response.body).to(include("event: error"))
      end

      it "enforces token limit when header is missing", :aggregate_failures do
        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include("Conversation horizon has arrived"))
        expect(response.body).to(include("event: error"))
      end

      context "when approaching token limit (90%)" do
        before do
          # Stub token count to return 90% of limit (45,000 tokens)
          stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
            .to_return(
              status: 200,
              body: { input_tokens: 45_000 }.to_json,
              headers: { "Content-Type" => "application/json" },
            )

          # Update streaming response to include message_start and content_block_stop
          stub_request(:post, "https://api.anthropic.com/v1/messages")
            .to_return(
              status: 200,
              body: "event: message_start\ndata: {\"type\":\"message_start\"}\n\nevent: content_block_delta\ndata: {\"type\":\"content_block_delta\",\"delta\":{\"type\":\"text_delta\",\"text\":\"Hello\"}}\n\nevent: content_block_stop\ndata: {\"type\":\"content_block_stop\"}\n\nevent: message_stop\ndata: {\"type\":\"message_stop\"}\n\n",
              headers: { "Content-Type" => "text/event-stream" },
            )
        end

        it "bypasses horizon warnings when header matches env var", :aggregate_failures do
          post "/api/stream",
            params: { chat_log: chat_log },
            headers: { "Disable-Token-Limit-Authorization" => bypass_token }

          expect(response).to(have_http_status(:ok))
          expect(response.body).not_to(include("Memory space 90% utilized"))
          expect(response.body).not_to(include("conversation horizon approaching"))
        end
      end
    end
  end
end
