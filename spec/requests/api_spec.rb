# frozen_string_literal: true

# spec/requests/api_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe("API", type: :request) do
  def build_fake_throttle_store
    Class.new do
      attr_reader :sources

      def initialize
        @rows = Hash.new { |rows, row_key| rows[row_key] = { requests: 0, micro_usd: 0 } }
        @sources = []
        @raise_errors = false
      end

      def fail!
        @raise_errors = true
      end

      def bump(source:, hour_bucket:, day_bucket:, requests: 0, micro_usd: 0)
        raise "store unavailable" if @raise_errors

        @sources << source

        {
          "hour" => bump_row([source, "hour", hour_bucket], requests, micro_usd),
          "day" => bump_row([source, "day", day_bucket], requests, micro_usd),
        }
      end

      private

      def bump_row(row_key, requests, micro_usd)
        row = @rows[row_key]
        row[:requests] += requests
        row[:micro_usd] += micro_usd
        row.dup
      end
    end.new
  end

  def configure_public_usage_throttle(mode:, budgets: {})
    fake_store = build_fake_throttle_store

    PublicUsageThrottle.reset!
    PublicUsageThrottle.store = fake_store

    # Pin the clock mid-bucket so a window boundary can't roll over mid-example
    allow(Time).to(receive(:current).and_return(Time.zone.at(1_750_000_000)))

    allow(ENV).to(receive(:fetch).and_call_original)
    allow(ENV).to(receive(:fetch).with("PUBLIC_USAGE_THROTTLE_MODE", "").and_return(mode))
    {
      "PUBLIC_USAGE_THROTTLE_HOUR_REQUESTS" => budgets[:hour_requests],
      "PUBLIC_USAGE_THROTTLE_DAY_REQUESTS" => budgets[:day_requests],
      "PUBLIC_USAGE_THROTTLE_HOUR_USD" => budgets[:hour_usd],
      "PUBLIC_USAGE_THROTTLE_DAY_USD" => budgets[:day_usd],
    }.each do |name, value|
      allow(ENV).to(receive(:fetch).with(name, nil).and_return(value&.to_s))
    end

    fake_store
  end

  before do
    PublicUsageThrottle.reset!
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
      let(:first_bypass_key) { "first-bypass-key" }
      let(:second_bypass_key) { "second-bypass-key" }
      let(:bypass_keys) { "#{first_bypass_key},#{second_bypass_key}" }

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
          headers: { "Token-Limit-Bypass-Key" => first_bypass_key }

        expect(response).to(have_http_status(:ok))
        expect(response.content_type).to(include("text/event-stream"))
      end

      it "bypasses token limit when header matches second key", :aggregate_failures do
        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "Token-Limit-Bypass-Key" => second_bypass_key }

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

      it "enforces token limit when only a usage client header is present", :aggregate_failures do
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("LAI_REPORTED_USAGE_CLIENTS").and_return("configured_client"))

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "X-LAI-Usage-Client" => "configured_client" }

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
            headers: { "Token-Limit-Bypass-Key" => first_bypass_key }

          expect(response).to(have_http_status(:ok))
          expect(response.body).not_to(include("Memory space 90% utilized"))
          expect(response.body).not_to(include("conversation horizon approaching"))
        end

        it "bypasses horizon warnings when header matches second key", :aggregate_failures do
          post "/api/stream",
            params: { chat_log: chat_log },
            headers: { "Token-Limit-Bypass-Key" => second_bypass_key }

          expect(response).to(have_http_status(:ok))
          expect(response.body).not_to(include("Memory space 90% utilized"))
          expect(response.body).not_to(include("conversation horizon approaching"))
        end
      end
    end

    describe "public usage throttle" do
      before do
        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "does not throttle when disabled", :aggregate_failures do
        ["", "off"].each do |mode|
          configure_public_usage_throttle(mode: mode, budgets: { hour_requests: 1, hour_usd: 0.01 })

          2.times { post "/api/stream", params: { chat_log: chat_log } }

          expect(response).to(have_http_status(:ok))
          expect(response.content_type).to(include("text/event-stream"))
        end
      end

      it "records would-limit telemetry in observe mode without blocking", :aggregate_failures do
        configure_public_usage_throttle(mode: "observe", budgets: { hour_requests: 1 })

        2.times { post "/api/stream", params: { chat_log: chat_log } }

        expect(response).to(have_http_status(:ok))
        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: public throttle",
          hash_including(
            public_throttle_limited: false,
            public_throttle_would_limit: true,
            public_throttle_mode: "observe",
            public_throttle_window: "hour",
            public_throttle_reason: "request_count",
          ),
        ))
      end

      it "returns a JSON 429 before streaming when an enforced request budget is spent", :aggregate_failures do
        configure_public_usage_throttle(mode: "enforce", budgets: { hour_requests: 1 })

        post "/api/stream", params: { chat_log: chat_log }
        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:too_many_requests))
        expect(response.content_type).to(include("application/json"))
        expect(response.headers["Retry-After"].to_i).to(be_between(1, 3600))
        expect(JSON.parse(response.body).dig("error", "message")).to(include("cooling down"))
      end

      it "enforces the day window with its own retry horizon", :aggregate_failures do
        configure_public_usage_throttle(mode: "enforce", budgets: { hour_requests: 99, day_requests: 2 })

        3.times { post "/api/stream", params: { chat_log: chat_log } }

        expect(response).to(have_http_status(:too_many_requests))
        expect(response.headers["Retry-After"].to_i).to(be_between(1, 86_400))
        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: public throttle",
          hash_including(public_throttle_window: "day", public_throttle_reason: "request_count"),
        ))
      end

      it "blocks when prior observed cost has spent the budget", :aggregate_failures do
        configure_public_usage_throttle(mode: "enforce", budgets: { hour_usd: 0.01 })
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(
            status: 200,
            body: [
              "event: message_start",
              'data: {"type":"message_start","message":{"usage":{"input_tokens":10000}}}',
              "",
              "event: message_stop",
              'data: {"type":"message_stop"}',
              "",
              "",
            ].join("\n"),
            headers: { "Content-Type" => "text/event-stream" },
          )

        post "/api/stream", params: { chat_log: chat_log }
        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:too_many_requests))
        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: public throttle",
          hash_including(
            public_throttle_limited: true,
            public_throttle_window: "hour",
            public_throttle_reason: "estimated_cost_usd",
          ),
        ))
      end

      it "does not let spoofed usage client headers skip the throttle", :aggregate_failures do
        configure_public_usage_throttle(mode: "enforce", budgets: { hour_requests: 1 })
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("LAI_REPORTED_USAGE_CLIENTS").and_return("configured_client"))

        2.times do
          post "/api/stream",
            params: { chat_log: chat_log },
            headers: { "X-LAI-Usage-Client" => "configured_client" }
        end

        expect(response).to(have_http_status(:too_many_requests))
      end

      it "skips the public throttle for valid bypass keys", :aggregate_failures do
        fake_store = configure_public_usage_throttle(mode: "enforce", budgets: { hour_requests: 1, hour_usd: 0.01 })
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("TOKEN_LIMIT_BYPASS_KEYS").and_return("trusted-key"))

        2.times do
          post "/api/stream",
            params: { chat_log: chat_log },
            headers: { "Token-Limit-Bypass-Key" => "trusted-key" }
        end

        expect(response).to(have_http_status(:ok))
        expect(response.content_type).to(include("text/event-stream"))
        expect(fake_store.sources).to(be_empty)
      end

      it "fails open when the store is unavailable", :aggregate_failures do
        fake_store = configure_public_usage_throttle(mode: "enforce", budgets: { hour_requests: 1 })
        fake_store.fail!
        allow(Rollbar).to(receive(:error))

        post "/api/stream", params: { chat_log: chat_log }

        expect(response).to(have_http_status(:ok))
        expect(Rollbar).to(have_received(:error))
        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: public throttle",
          hash_including(public_throttle_error: "RuntimeError"),
        ))
      end

      it "does not put raw IP addresses in the store or telemetry", :aggregate_failures do
        event_payloads = []
        allow(NewRelic::Agent).to(receive(:record_custom_event)) { |_event, data| event_payloads << data }
        fake_store = configure_public_usage_throttle(mode: "enforce", budgets: { hour_requests: 1 })

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "REMOTE_ADDR" => "203.0.113.10" }

        expect(fake_store.sources).not_to(be_empty)
        expect(fake_store.sources.join).not_to(include("203.0.113.10"))
        expect(fake_store.sources.join).not_to(include("127.0.0.1"))
        expect(event_payloads.flat_map(&:values).join).not_to(include("203.0.113.10"))
        expect(event_payloads.flat_map(&:values).join).not_to(include("127.0.0.1"))
      end
    end

    describe "usage telemetry" do
      before do
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("LAI_REPORTED_USAGE_CLIENTS").and_return("configured_client"))
        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "records first-party stream client attribution" do
        event_data = nil
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          event_data = data
        end

        post "/api/stream", params: { chat_log: chat_log, usage_client: "reader" }

        expect(event_data).to(include(
          usage_client: "lightward_reader",
          token_limit_bypassed: false,
          usage_conversation_id: event_data[:conversation_id],
        ))
      end

      it "records reported usage clients and HMACed grouping IDs without raw identifiers", :aggregate_failures do
        event_data = nil
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          event_data = data
        end

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: {
            "X-LAI-Usage-Client" => "configured_client",
            "X-LAI-Conversation-Key" => "conversation-123",
            "X-LAI-Subject-Key" => "subject-456",
          }

        expected_conversation_id = OpenSSL::HMAC.hexdigest(
          "SHA256",
          Rails.application.secret_key_base,
          [
            ApiController::TELEMETRY_HMAC_NAMESPACE,
            "configured_client",
            "conversation",
            "conversation-123",
          ].join(":"),
        )
        expected_subject_id = OpenSSL::HMAC.hexdigest(
          "SHA256",
          Rails.application.secret_key_base,
          [
            ApiController::TELEMETRY_HMAC_NAMESPACE,
            "configured_client",
            "subject",
            "subject-456",
          ].join(":"),
        )

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            usage_client: "configured_client",
            usage_conversation_id: expected_conversation_id,
            usage_subject_id: expected_subject_id,
            token_limit_bypassed: false,
          ),
        ))

        expect(event_data.values).not_to(include("conversation-123"))
        expect(event_data.values).not_to(include("subject-456"))
      end

      it "ignores grouping headers without a reported usage client", :aggregate_failures do
        event_data = nil
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          event_data = data
        end

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: {
            "X-LAI-Conversation-Key" => "conversation-123",
            "X-LAI-Subject-Key" => "subject-456",
          }

        expect(event_data).to(include(
          usage_conversation_id: event_data[:conversation_id],
          usage_subject_id: nil,
          token_limit_bypassed: false,
        ))
        expect(event_data.values).not_to(include("conversation-123"))
        expect(event_data.values).not_to(include("subject-456"))
      end

      it "ignores unknown usage clients and grouping headers", :aggregate_failures do
        event_data = nil
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          event_data = data
        end

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: {
            "X-LAI-Usage-Client" => "unknown-product",
            "X-LAI-Conversation-Key" => "conversation-123",
            "X-LAI-Subject-Key" => "subject-456",
          }

        expect(event_data).to(include(
          usage_client: "stream_unknown",
          usage_conversation_id: event_data[:conversation_id],
          usage_subject_id: nil,
          token_limit_bypassed: false,
        ))
        expect(event_data.values).not_to(include("unknown-product"))
        expect(event_data.values).not_to(include("conversation-123"))
        expect(event_data.values).not_to(include("subject-456"))
      end

      it "ignores external usage clients that are not configured", :aggregate_failures do
        allow(ENV).to(receive(:[]).with("LAI_REPORTED_USAGE_CLIENTS").and_return(nil))
        event_data = nil
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          event_data = data
        end

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: {
            "X-LAI-Usage-Client" => "configured_client",
            "X-LAI-Conversation-Key" => "conversation-123",
            "X-LAI-Subject-Key" => "subject-456",
          }

        expect(event_data).to(include(
          usage_client: "stream_unknown",
          usage_conversation_id: event_data[:conversation_id],
          usage_subject_id: nil,
        ))
        expect(event_data.values).not_to(include("configured_client"))
        expect(event_data.values).not_to(include("conversation-123"))
        expect(event_data.values).not_to(include("subject-456"))
      end

      it "ignores external usage clients submitted in params", :aggregate_failures do
        event_data = nil
        allow(NewRelic::Agent).to(receive(:record_custom_event)) do |_event, data|
          event_data = data
        end

        post "/api/stream",
          params: { chat_log: chat_log, usage_client: "configured_client" },
          headers: {
            "X-LAI-Conversation-Key" => "conversation-123",
            "X-LAI-Subject-Key" => "subject-456",
          }

        expect(event_data).to(include(
          usage_client: "stream_unknown",
          usage_conversation_id: event_data[:conversation_id],
          usage_subject_id: nil,
          token_limit_bypassed: false,
        ))
        expect(event_data.values).not_to(include("configured_client"))
        expect(event_data.values).not_to(include("conversation-123"))
        expect(event_data.values).not_to(include("subject-456"))
      end

      it "records bypass state without using the bypass key for client attribution" do
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("TOKEN_LIMIT_BYPASS_KEYS").and_return("legacy-key"))

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: { "Token-Limit-Bypass-Key" => "legacy-key" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            usage_client: "stream_unknown",
            token_limit_bypassed: true,
          ),
        ))
      end

      it "records reported usage client when a bypass key is also present" do
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("TOKEN_LIMIT_BYPASS_KEYS").and_return("legacy-key"))
        allow(ENV).to(receive(:[]).with("LAI_REPORTED_USAGE_CLIENTS").and_return("configured_client"))

        post "/api/stream",
          params: { chat_log: chat_log },
          headers: {
            "X-LAI-Usage-Client" => "configured_client",
            "Token-Limit-Bypass-Key" => "legacy-key",
          }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            usage_client: "configured_client",
            token_limit_bypassed: true,
          ),
        ))
      end

      it "records streaming Anthropic usage and estimated cost" do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(
            status: 200,
            body: [
              "event: message_start",
              'data: {"type":"message_start","message":{"usage":{"input_tokens":1000,"cache_creation_input_tokens":2000,"cache_read_input_tokens":3000,"output_tokens":1}}}',
              "",
              "event: message_delta",
              'data: {"type":"message_delta","usage":{"output_tokens":400}}',
              "",
              "event: message_stop",
              'data: {"type":"message_stop"}',
              "",
            ].join("\n"),
            headers: { "Content-Type" => "text/event-stream" },
          )

        post "/api/stream", params: { chat_log: chat_log, usage_client: "writer" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            usage_client: "lightward_writer",
            anthropic_model: "claude-sonnet-4-6",
            input_tokens: 1000,
            output_tokens: 400,
            cache_creation_input_tokens: 2000,
            cache_read_input_tokens: 3000,
            estimated_cost_usd: 0.0174,
          ),
        ))
      end

      it "records stream metadata when Anthropic returns an error" do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(
            status: 500,
            body: { error: { message: "Internal error" } }.to_json,
            headers: { "Content-Type" => "application/json" },
          )

        post "/api/stream", params: { chat_log: chat_log, usage_client: "reader" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            usage_client: "lightward_reader",
            input_tokens: nil,
            estimated_cost_usd: nil,
          ),
        ))
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
          "ApiController: request",
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
          "ApiController: request",
          hash_including(conversation_frame_id: expected_frame_id),
        ))
      end

      it "generates conversation_id from warmup + first 2 unique messages" do
        chat_log = [warmup_message, first_unique_message, second_unique_message]
        post "/api/stream", params: { chat_log: chat_log }

        expected_hash_input = [warmup_message, first_unique_message, second_unique_message]
        expected_conversation_id = Digest::SHA256.hexdigest(expected_hash_input.to_json)

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
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
          "ApiController: request",
          hash_including(conversation_id: expected_conversation_id),
        ))
      end

      it "handles conversations with only one unique message after warmup" do
        chat_log = [warmup_message, first_unique_message]
        post "/api/stream", params: { chat_log: chat_log }

        expected_hash_input = [warmup_message, first_unique_message]
        expected_conversation_id = Digest::SHA256.hexdigest(expected_hash_input.to_json)

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
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

    describe "public usage throttle" do
      before do
        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "returns a plaintext 429 before calling Anthropic when an enforced budget is spent", :aggregate_failures do
        configure_public_usage_throttle(mode: "enforce", budgets: { hour_requests: 1 })

        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }
        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(response).to(have_http_status(:too_many_requests))
        expect(response.content_type).to(include("text/plain"))
        expect(response.headers["Retry-After"].to_i).to(be_between(1, 3600))
        expect(response.body).to(include("cooling down"))
      end
    end

    describe "plain start tracking" do
      before do
        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "records a plain start event with frame_id 'plain'" do
        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            conversation_frame_id: "plain",
            conversation_id: nil,
            chat_log_depth: 1,
            chat_log_token_count: 100,
            usage_client: "plain_unknown",
          ),
        ))
      end

      it "reports nil token count when token limit is bypassed" do
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("TOKEN_LIMIT_BYPASS_KEYS").and_return("bypass-key"))

        post "/api/plain",
          params: "Hello",
          headers: { "CONTENT_TYPE" => "text/plain", "Token-Limit-Bypass-Key" => "bypass-key" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            conversation_frame_id: "plain",
            conversation_id: nil,
            chat_log_depth: 1,
            chat_log_token_count: nil,
            usage_client: "plain_unknown",
            token_limit_bypassed: true,
          ),
        ))
      end

      it "records reported plain usage client attribution" do
        allow(ENV).to(receive(:[]).and_call_original)
        allow(ENV).to(receive(:[]).with("LAI_REPORTED_USAGE_CLIENTS").and_return("configured_client"))

        post "/api/plain",
          params: "Hello",
          headers: { "CONTENT_TYPE" => "text/plain", "X-LAI-Usage-Client" => "configured_client" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            usage_client: "configured_client",
            token_limit_bypassed: false,
          ),
        ))
      end

      it "ignores unknown plain usage client attribution" do
        post "/api/plain",
          params: "Hello",
          headers: { "CONTENT_TYPE" => "text/plain", "X-LAI-Usage-Client" => "unknown-product" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            usage_client: "plain_unknown",
            token_limit_bypassed: false,
          ),
        ))
      end

      it "records plain Anthropic usage and estimated cost" do
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(
            status: 200,
            body: {
              content: [{ type: "text", text: "Hello, fellow AI!" }],
              stop_reason: "end_turn",
              usage: {
                input_tokens: 10,
                output_tokens: 20,
                cache_creation_input_tokens: 30,
                cache_read_input_tokens: 40,
              },
            }.to_json,
            headers: { "Content-Type" => "application/json" },
          )

        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            input_tokens: 10,
            output_tokens: 20,
            cache_creation_input_tokens: 30,
            cache_read_input_tokens: 40,
            estimated_cost_usd: 0.0004545,
          ),
        ))
      end

      it "records plain attribution when Anthropic returns malformed JSON", :aggregate_failures do
        allow(Rollbar).to(receive(:error))
        stub_request(:post, "https://api.anthropic.com/v1/messages")
          .to_return(
            status: 200,
            body: "not json",
            headers: { "Content-Type" => "application/json" },
          )

        post "/api/plain", params: "Hello", headers: { "CONTENT_TYPE" => "text/plain" }

        expect(response).to(have_http_status(:bad_gateway))
        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "ApiController: request",
          hash_including(
            conversation_frame_id: "plain",
            usage_client: "plain_unknown",
            estimated_cost_usd: nil,
          ),
        ))
      end
    end

    context "with token limit bypass header" do
      let(:bypass_key) { "plain-bypass-key" }

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

  describe "CORS" do
    it "includes CORS headers on POST /api/stream", :aggregate_failures do
      chat_log = [
        { role: "user", content: [{ type: "text", text: "Warmup", cache_control: { type: "ephemeral" } }] },
        { role: "user", content: [{ type: "text", text: "Hello!" }] },
      ]

      post "/api/stream",
        params: { chat_log: chat_log },
        headers: { "Origin" => "https://example.com" }

      expect(response.headers["Access-Control-Allow-Origin"]).to(eq("*"))
    end

    it "includes CORS headers on POST /api/plain", :aggregate_failures do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(
          status: 200,
          body: { content: [{ type: "text", text: "Hi" }], stop_reason: "end_turn" }.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      post "/api/plain",
        params: "Hello",
        headers: { "CONTENT_TYPE" => "text/plain", "Origin" => "https://example.com" }

      expect(response.headers["Access-Control-Allow-Origin"]).to(eq("*"))
    end

    it "responds to preflight OPTIONS for /api/stream", :aggregate_failures do
      options "/api/stream", headers: {
        "Origin" => "https://example.com",
        "Access-Control-Request-Method" => "POST",
        "Access-Control-Request-Headers" => "Content-Type, Token-Limit-Bypass-Key, X-LAI-Usage-Client, X-LAI-Conversation-Key, X-LAI-Subject-Key",
      }

      expect(response).to(have_http_status(:ok))
      expect(response.headers["Access-Control-Allow-Origin"]).to(eq("*"))
      expect(response.headers["Access-Control-Allow-Methods"]).to(include("POST"))
      allowed_headers = response.headers["Access-Control-Allow-Headers"].to_s.downcase
      expect(allowed_headers).to(include("x-lai-usage-client"))
      expect(allowed_headers).to(include("x-lai-conversation-key"))
      expect(allowed_headers).to(include("x-lai-subject-key"))
    end

    it "responds to preflight OPTIONS for /api/plain", :aggregate_failures do
      options "/api/plain", headers: {
        "Origin" => "https://example.com",
        "Access-Control-Request-Method" => "POST",
        "Access-Control-Request-Headers" => "Content-Type, Token-Limit-Bypass-Key, X-LAI-Usage-Client, X-LAI-Conversation-Key, X-LAI-Subject-Key",
      }

      expect(response).to(have_http_status(:ok))
      expect(response.headers["Access-Control-Allow-Origin"]).to(eq("*"))
      expect(response.headers["Access-Control-Allow-Methods"]).to(include("POST"))
      allowed_headers = response.headers["Access-Control-Allow-Headers"].to_s.downcase
      expect(allowed_headers).to(include("x-lai-usage-client"))
      expect(allowed_headers).to(include("x-lai-conversation-key"))
      expect(allowed_headers).to(include("x-lai-subject-key"))
    end

    it "does not include CORS headers for other endpoints" do
      get "/api/system.json", headers: { "Origin" => "https://example.com" }

      expect(response.headers["Access-Control-Allow-Origin"]).to(be_nil)
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
