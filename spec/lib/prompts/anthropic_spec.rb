# frozen_string_literal: true

# spec/lib/prompts/anthropic_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe(Prompts::Anthropic, :aggregate_failures) do
  describe ".api_request" do
    let(:payload) { { key: "value" } }

    before do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .to_return(
          status: 200,
          body: "",
          headers: {
            "anthropic-ratelimit-requests-limit" => "1000",
            "anthropic-ratelimit-requests-remaining" => "900",
            "anthropic-ratelimit-requests-reset" => "2024-05-22T00:00:00Z",
            "anthropic-ratelimit-tokens-limit" => "1000000",
            "anthropic-ratelimit-tokens-remaining" => "999000",
            "anthropic-ratelimit-tokens-reset" => "2024-05-22T00:00:00Z",
          },
        )
    end

    it "accepts a payload and yields the request and response, returning the block result" do
      result = described_class.api_request(payload) { |request, response|
        expect(request.body).to(eq(payload.to_json))
        expect(response.code).to(eq("200"))
        "result"
      }

      expect(result).to(eq("result"))
    end

    it "includes the anthropic-beta header in the request" do
      described_class.api_request(payload) do |request, _response|
        expect(request["anthropic-beta"]).to(eq("context-1m-2025-08-07"))
      end

      expect(WebMock).to(have_requested(:post, "https://api.anthropic.com/v1/messages")
        .with(headers: { "anthropic-beta" => "context-1m-2025-08-07" }))
    end

    describe "newrelic" do
      before do
        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "records a custom New Relic event immediately" do
        described_class.api_request(payload) do |_request, resp|
          expect(resp.code).to(eq("200"))
        end

        expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
          "AnthropicAPIRateLimit",
          hash_including(
            requests_limit: 1000,
            requests_remaining: 900,
            requests_reset: "2024-05-22T00:00:00Z",
            tokens_limit: 1000000,
            tokens_remaining: 999000,
            tokens_reset: "2024-05-22T00:00:00Z",
            requests_reset_ttl: kind_of(Integer),
            tokens_reset_ttl: kind_of(Integer),
          ),
        ))
      end

      it "calculates TTL correctly" do
        travel_to(Time.parse("2024-05-21T12:00:00Z")) do
          described_class.api_request(payload) {}

          expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
            "AnthropicAPIRateLimit",
            hash_including(
              requests_reset_ttl: 43200, # 12 hours in seconds
              tokens_reset_ttl: 43200, # 12 hours in seconds
            ),
          ))
        end
      end
    end
  end

  describe ".process_messages" do
    let(:conversation_starters) {
      [
        { "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] },
        { "role" => "user", "content" => [{ "type" => "text", "text" => "there" }] },
        { "role" => "assistant", "content" => [{ "type" => "text", "text" => "hi" }] },
      ]
    }

    let(:messages) { [{ "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] }] }

    before do
      allow(Prompts).to(receive(:generate_system_prompt).with(["foo"], for_prompt_type: "foo").and_return("system-prompt"))
      allow(Prompts).to(receive(:conversation_starters).with("foo").and_return(conversation_starters))
      allow(Prompts).to(receive(:assert_system_prompt_size_safety!).with("foo", "system-prompt"))
      allow(described_class).to(receive(:api_request).and_return("result"))
    end

    it "sends a payload with the messages" do
      result = described_class.process_messages(messages, prompt_type: "foo", model: "modelo")
      expect(result).to(eq("result"))

      expect(described_class).to(have_received(:api_request).with({
        model: "modelo",
        max_tokens: 4000,
        stream: false,
        temperature: 1.0,
        system: "system-prompt",
        messages: [
          {
            "role" => "user",
            "content" => [
              { "type" => "text", "text" => "hello" },
              { "type" => "text", "text" => "there" },
            ],
          },
          { "role" => "assistant", "content" => [{ "type" => "text", "text" => "hi" }] },
          { "role" => "user", "content" => [{ "type" => "text", "text" => "hello" }] },
        ],
      }))
    end
  end

  describe ".count_tokens" do
    let(:messages) { [{ "role" => "user", "content" => [{ "type" => "text", "text" => "Hello world" }] }] }
    let(:conversation_starters) { [] }

    before do
      allow(Prompts).to(receive(:generate_system_prompt).with(["clients/chat"], for_prompt_type: "clients/chat").and_return("system-prompt"))
      allow(Prompts).to(receive(:conversation_starters).with("clients/chat").and_return(conversation_starters))
      allow(Prompts).to(receive(:clean_chat_log).and_return(messages))
    end

    context "when API responds successfully" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(
            status: 200,
            body: '{"input_tokens": 1234}',
            headers: { "Content-Type" => "application/json" },
          )
      end

      it "returns the token count from the API" do
        result = described_class.count_tokens(
          messages,
          prompt_type: "clients/chat",
          model: "claude-opus-4",
        )

        expect(result).to(eq(1234))
      end

      it "sends the correct request to the API" do
        described_class.count_tokens(
          messages,
          prompt_type: "clients/chat",
          model: "claude-opus-4",
        )

        expect(WebMock).to(have_requested(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .with(
            body: {
              model: "claude-opus-4",
              system: "system-prompt",
              messages: messages,
            }.to_json,
            headers: {
              "Anthropic-Version" => "2023-06-01",
              "Anthropic-Beta" => "context-1m-2025-08-07",
              "Content-Type" => "application/json",
            },
          ))
      end
    end

    context "when API responds with an error" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(status: 500, body: "Internal Server Error")

        allow(Rails.logger).to(receive(:error))
      end

      it "returns nil and logs the error" do
        result = described_class.count_tokens(
          messages,
          prompt_type: "clients/chat",
          model: "claude-opus-4",
        )

        expect(result).to(be_nil)
        expect(Rails.logger).to(have_received(:error).with("Failed to count tokens: HTTP 500 – "))
        expect(Rails.logger).to(have_received(:error).with("Internal Server Error"))
      end
    end

    context "when API request raises an exception" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_raise(StandardError.new("Network error"))

        allow(Rails.logger).to(receive(:error))
      end

      it "returns nil and logs the exception" do
        result = described_class.count_tokens(
          messages,
          prompt_type: "clients/chat",
          model: "claude-opus-4",
        )

        expect(result).to(be_nil)
        expect(Rails.logger).to(have_received(:error).with("Error counting tokens: Network error"))
      end
    end

    context "with custom system prompt types" do
      before do
        allow(Prompts).to(receive(:generate_system_prompt).with(["custom", "prompt"], for_prompt_type: "clients/chat").and_return("custom-system-prompt"))

        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(status: 200, body: '{"input_tokens": 5678}')
      end

      it "uses the provided system prompt types" do
        result = described_class.count_tokens(
          messages,
          prompt_type: "clients/chat",
          model: "claude-opus-4",
          system_prompt_types: ["custom", "prompt"],
        )

        expect(result).to(eq(5678))
        expect(Prompts).to(have_received(:generate_system_prompt).with(["custom", "prompt"], for_prompt_type: "clients/chat"))
      end
    end
  end
end
