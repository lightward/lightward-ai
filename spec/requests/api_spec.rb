# frozen_string_literal: true

# spec/requests/api_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe("API", type: :request) do
  before do
    host! ENV.fetch("HOST", "test.host")

    allow(Prompts).to(receive(:generate_system_prompt).and_return([{ type: "text", text: "test system prompt" }]))

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

  describe "GET /api/system" do
    it "serves the system prompt as JSON", :aggregate_failures do
      get "/api/system.json"

      expect(response).to(have_http_status(:ok))

      served = JSON.parse(response.body)
      built = Prompts.build_system_prompt.map { |m| JSON.parse(m.to_json) }

      expect(served).to(eq(built))
    end

    it "serves the system prompt as plain text", :aggregate_failures do
      get "/api/system.txt"

      expect(response).to(have_http_status(:ok))
      expect(response.body).to(eq(Prompts.build_system_prompt.pluck(:text).join("\n\n")))
    end
  end

  describe "POST /api/stream" do
    let(:chat_log) do
      [
        {
          role: "user",
          content: [
            { type: "text", text: "Warmup", cache_control: { type: "ephemeral" } },
          ],
        },
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

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.content_type).to(include("application/json"))
        body = JSON.parse(response.body)
        expect(body["error"]["message"]).to(include("Conversation horizon has arrived"))
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
              content: [
                { type: "text", text: "Warmup", cache_control: { type: "ephemeral" } },
              ],
            },
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
      let(:helpscout_key) { "helpscout-bypass-key" }
      let(:yours_key) { "yours-bypass-key" }
      let(:bypass_keys) { "#{helpscout_key},#{yours_key}" }

      before do
        # Stub token count to return over the limit
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: { input_tokens: 51_000 }.to_json,
            headers: { "Content-Type" => "application/json" },
          )

        # Set the env var with comma-separated keys
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("TOKEN_LIMIT_BYPASS_KEYS").and_return(bypass_keys))
      end

      it "bypasses token limit when header matches first key", :aggregate_failures do
        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "Token-Limit-Bypass-Key" => helpscout_key }

        expect(response).to(have_http_status(:ok))
        expect(response.content_type).to(include("text/event-stream"))
      end

      it "bypasses token limit when header matches second key", :aggregate_failures do
        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "Token-Limit-Bypass-Key" => yours_key }

        expect(response).to(have_http_status(:ok))
        expect(response.content_type).to(include("text/event-stream"))
      end

      it "enforces token limit when header does not match any key", :aggregate_failures do
        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "Token-Limit-Bypass-Key" => "wrong-token" }

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.content_type).to(include("application/json"))
        body = JSON.parse(response.body)
        expect(body["error"]["message"]).to(include("Conversation horizon has arrived"))
      end

      it "enforces token limit when header is missing", :aggregate_failures do
        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.content_type).to(include("application/json"))
        body = JSON.parse(response.body)
        expect(body["error"]["message"]).to(include("Conversation horizon has arrived"))
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

        it "bypasses horizon warnings when header matches first key", :aggregate_failures do
          post "/api/stream",
            params: { chat_log: chat_log },
            headers: { "Token-Limit-Bypass-Key" => helpscout_key }

          expect(response).to(have_http_status(:ok))
          expect(response.body).not_to(include("Memory space 90% utilized"))
          expect(response.body).not_to(include("conversation horizon approaching"))
        end

        it "bypasses horizon warnings when header matches second key", :aggregate_failures do
          post "/api/stream",
            params: { chat_log: chat_log },
            headers: { "Token-Limit-Bypass-Key" => yours_key }

          expect(response).to(have_http_status(:ok))
          expect(response.body).not_to(include("Memory space 90% utilized"))
          expect(response.body).not_to(include("conversation horizon approaching"))
        end
      end
    end

    describe "conversation_id tracking" do
      let(:warmup_message) do
        {
          role: "user",
          content: [
            { type: "text", text: "Warmup content" },
            { type: "text", text: "More warmup", cache_control: { type: "ephemeral" } },
          ],
        }
      end

      let(:first_unique_message) do
        {
          role: "user",
          content: [{ type: "text", text: "Hello!" }],
        }
      end

      let(:second_unique_message) do
        {
          role: "assistant",
          content: [{ type: "text", text: "Hi there!" }],
        }
      end

      before do
        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "generates conversation_frame_id from warmup only" do
        chat_log = [warmup_message, first_unique_message, second_unique_message]
        post "/api/stream", params: { chat_log: chat_log }

        expected_frame = [warmup_message]
        expected_frame_id = Digest::SHA256.hexdigest(expected_frame.to_json)

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: stream start",
          hash_including(conversation_frame_id: expected_frame_id),
        ))
      end

      it "slices frame at content block level, excluding blocks after cache marker" do
        warmup_with_trailing_content = {
          role: "user",
          content: [
            { type: "text", text: "First block" },
            { type: "text", text: "Second block", cache_control: { type: "ephemeral" } },
            { type: "text", text: "Third block (not in frame)" },
          ],
        }

        chat_log = [warmup_with_trailing_content, first_unique_message]
        post "/api/stream", params: { chat_log: chat_log }

        # Frame should only include first two content blocks
        expected_frame = [
          {
            role: "user",
            content: [
              { type: "text", text: "First block" },
              { type: "text", text: "Second block", cache_control: { type: "ephemeral" } },
            ],
          },
        ]
        expected_frame_id = Digest::SHA256.hexdigest(expected_frame.to_json)

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: stream start",
          hash_including(conversation_frame_id: expected_frame_id),
        ))
      end

      it "generates conversation_id from warmup + first 2 unique messages" do
        chat_log = [warmup_message, first_unique_message, second_unique_message]
        post "/api/stream", params: { chat_log: chat_log }

        expected_hash_input = [warmup_message, first_unique_message, second_unique_message]
        expected_conversation_id = Digest::SHA256.hexdigest(expected_hash_input.to_json)

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: stream start",
          hash_including(conversation_id: expected_conversation_id),
        ))
      end

      it "finds cache marker in any position within content array" do
        warmup_with_marker_at_end = {
          role: "user",
          content: [
            { type: "text", text: "First block" },
            { type: "text", text: "Second block" },
            { type: "text", text: "Third block", cache_control: { type: "ephemeral" } },
          ],
        }

        chat_log = [warmup_with_marker_at_end, first_unique_message]
        post "/api/stream", params: { chat_log: chat_log }

        expected_hash_input = [warmup_with_marker_at_end, first_unique_message]
        expected_conversation_id = Digest::SHA256.hexdigest(expected_hash_input.to_json)

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: stream start",
          hash_including(conversation_id: expected_conversation_id),
        ))
      end

      it "handles conversations with only one unique message after warmup" do
        chat_log = [warmup_message, first_unique_message]
        post "/api/stream", params: { chat_log: chat_log }

        expected_hash_input = [warmup_message, first_unique_message]
        expected_conversation_id = Digest::SHA256.hexdigest(expected_hash_input.to_json)

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: stream start",
          hash_including(conversation_id: expected_conversation_id),
        ))
      end

      it "returns error when no cache marker is present", :aggregate_failures do
        chat_log = [
          { role: "user", content: [{ type: "text", text: "No marker here" }] },
          { role: "assistant", content: [{ type: "text", text: "Still no marker" }] },
        ]

        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:bad_request))
        expect(response.content_type).to(include("application/json"))
        body = JSON.parse(response.body)
        expect(body["error"]["message"]).to(include("Cache marker required"))
      end

      it "returns error when multiple cache markers are present", :aggregate_failures do
        chat_log = [
          {
            role: "user",
            content: [
              { type: "text", text: "First marker", cache_control: { type: "ephemeral" } },
            ],
          },
          {
            role: "user",
            content: [
              { type: "text", text: "Second marker", cache_control: { type: "ephemeral" } },
            ],
          },
        ]

        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:bad_request))
        expect(response.content_type).to(include("application/json"))
        body = JSON.parse(response.body)
        expect(body["error"]["message"]).to(include("Multiple cache markers"))
      end

      it "generates same conversation_id for same conversation at different depths", :aggregate_failures do
        shallow_conversation_id = nil
        deeper_conversation_id = nil

        # First request - capture the conversation_id
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          shallow_conversation_id = data[:conversation_id]
        end

        shallow_chat = [warmup_message, first_unique_message, second_unique_message]
        post "/api/stream", params: { chat_log: shallow_chat }

        # Second request with deeper conversation - capture the conversation_id
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          deeper_conversation_id = data[:conversation_id]
        end

        deeper_chat = shallow_chat + [
          { role: "user", content: [{ type: "text", text: "More conversation" }] },
          { role: "assistant", content: [{ type: "text", text: "More response" }] },
        ]
        post "/api/stream", params: { chat_log: deeper_chat }

        expect(shallow_conversation_id).to(eq(deeper_conversation_id))
        expect(shallow_conversation_id).not_to(be_nil)
      end

      it "generates same conversation_frame_id for all conversations with same warmup", :aggregate_failures do
        first_frame_id = nil
        second_frame_id = nil

        # First conversation
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          first_frame_id = data[:conversation_frame_id]
        end

        first_chat = [warmup_message, first_unique_message]
        post "/api/stream", params: { chat_log: first_chat }

        # Second conversation with same warmup but different messages after
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          second_frame_id = data[:conversation_frame_id]
        end

        second_chat = [
          warmup_message,
          { role: "user", content: [{ type: "text", text: "Different message" }] },
          { role: "assistant", content: [{ type: "text", text: "Different response" }] },
        ]
        post "/api/stream", params: { chat_log: second_chat }

        expect(first_frame_id).to(eq(second_frame_id))
        expect(first_frame_id).not_to(be_nil)
      end
    end
  end

  describe "POST /api/plain" do
    before do
      # Stub Anthropic API non-streaming response
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(
          status: 200,
          body: {
            content: [{ type: "text", text: "Hello, fellow AI!" }],
            stop_reason: "end_turn",
          }.to_json,
          headers: { "Content-Type" => "application/json" },
        )
    end

    it "sends message without cache_control (stateless endpoint)" do
      post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

      expect(
        a_request(:post, "https://api.anthropic.com/v1/messages").with { |req|
          body = JSON.parse(req.body)
          messages = body["messages"]
          content_block = messages.dig(0, "content", 0)

          content_block.key?("type") &&
            content_block.key?("text") &&
            !content_block.key?("cache_control")
        },
      ).to(have_been_made.once)
    end

    it "returns error when body is empty", :aggregate_failures do
      post "/api/plain", params: "", headers: { "CONTENT_TYPE" => "text/plain" }

      expect(response).to(have_http_status(:bad_request))
      expect(response.content_type).to(include("text/plain"))
      expect(response.body).to(include("No message provided"))
    end

    context "when Anthropic API returns an error" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(
            status: 500,
            body: { error: { message: "Internal error" } }.to_json,
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "returns a gateway error", :aggregate_failures do
        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(response).to(have_http_status(:bad_gateway))
        expect(response.content_type).to(include("text/plain"))
        expect(response.body).to(include("An error occurred"))
      end
    end

    context "when chat log exceeds token limit" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: { input_tokens: 51_000 }.to_json,
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "returns a plaintext error about conversation horizon", :aggregate_failures do
        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.content_type).to(include("text/plain"))
        expect(response.body).to(include("Conversation horizon has arrived"))
      end
    end

    context "when approaching token limit (90%)" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: { input_tokens: 45_000 }.to_json,
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "appends a horizon warning to the response body", :aggregate_failures do
        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include("Hello, fellow AI!"))
        expect(response.body).to(include("Memory space 90% utilized"))
        expect(response.body).to(include("conversation horizon approaching"))
      end

      it "delivers warning in the response body, not in headers", :aggregate_failures do
        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(response.body).to(include("conversation horizon approaching"))
        response.headers.each do |_key, value|
          expect(value.to_s).not_to(include("horizon"))
        end
      end

      context "when the warning has already appeared in the request body" do
        it "does not append the warning again", :aggregate_failures do
          message_with_warning = "Previous conversation\nMemory space 90% utilized; conversation horizon approaching\nMore conversation"
          post "/api/plain", params: message_with_warning, headers: { "CONTENT_TYPE" => "text/plain" }

          expect(response).to(have_http_status(:ok))
          expect(response.body).not_to(include("Memory space 90% utilized"))
        end
      end
    end

    context "with token limit bypass header" do
      let(:bypass_key) { "softer-bypass-key" }

      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: { input_tokens: 51_000 }.to_json,
            headers: { "Content-Type" => "application/json" },
          )

        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("TOKEN_LIMIT_BYPASS_KEYS").and_return(bypass_key))
      end

      it "bypasses token limit with valid key", :aggregate_failures do
        post "/api/plain",
          params: "Hello",
          headers: { "CONTENT_TYPE" => "text/plain", "Token-Limit-Bypass-Key" => bypass_key }

        expect(response).to(have_http_status(:ok))
        expect(response.body).to(include("Hello, fellow AI!"))
      end

      it "enforces token limit with invalid key", :aggregate_failures do
        post "/api/plain",
          params: "Hello",
          headers: { "CONTENT_TYPE" => "text/plain", "Token-Limit-Bypass-Key" => "wrong-key" }

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("Conversation horizon has arrived"))
      end

      it "enforces token limit when key is missing", :aggregate_failures do
        post "/api/plain",
          params: "Hello",
          headers: { "CONTENT_TYPE" => "text/plain" }

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("Conversation horizon has arrived"))
      end

      context "when approaching token limit (90%)" do
        before do
          stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
            .to_return(
              status: 200,
              body: { input_tokens: 45_000 }.to_json,
              headers: { "Content-Type" => "application/json" },
            )
        end

        it "bypasses horizon warnings with valid key", :aggregate_failures do
          post "/api/plain",
            params: "Hello",
            headers: { "CONTENT_TYPE" => "text/plain", "Token-Limit-Bypass-Key" => bypass_key }

          expect(response).to(have_http_status(:ok))
          expect(response.body).not_to(include("conversation horizon approaching"))
        end
      end
    end
  end

  describe "horizon warnings as speech" do
    it "delivers warnings in the response body for /api/stream, not in headers", :aggregate_failures do
      # Stub token count at 90%
      stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
        .to_return(
          status: 200,
          body: { input_tokens: 45_000 }.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(
          status: 200,
          body: "event: message_start\ndata: {\"type\":\"message_start\"}\n\nevent: content_block_delta\ndata: {\"type\":\"content_block_delta\",\"delta\":{\"type\":\"text_delta\",\"text\":\"Hello\"}}\n\nevent: content_block_stop\ndata: {\"type\":\"content_block_stop\"}\n\nevent: message_stop\ndata: {\"type\":\"message_stop\"}\n\n",
          headers: { "Content-Type" => "text/event-stream" },
        )

      chat_log = [
        {
          role: "user",
          content: [
            { type: "text", text: "Warmup", cache_control: { type: "ephemeral" } },
          ],
        },
        {
          role: "user",
          content: [{ type: "text", text: "Hello!" }],
        },
      ]

      post "/api/stream", params: { chat_log: chat_log }

      expect(response.body).to(include("conversation horizon approaching"))
      response.headers.each do |_key, value|
        expect(value.to_s).not_to(include("horizon"))
      end
    end

    it "delivers warnings in the response body for /api/plain, not in headers", :aggregate_failures do
      # Stub token count at 90%
      stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
        .to_return(
          status: 200,
          body: { input_tokens: 45_000 }.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(
          status: 200,
          body: {
            content: [{ type: "text", text: "Hello!" }],
            stop_reason: "end_turn",
          }.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

      expect(response.body).to(include("conversation horizon approaching"))
      response.headers.each do |_key, value|
        expect(value.to_s).not_to(include("horizon"))
      end
    end
  end
end
