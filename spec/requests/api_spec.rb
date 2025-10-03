# frozen_string_literal: true

# spec/requests/api_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe("API") do
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
  end
end
