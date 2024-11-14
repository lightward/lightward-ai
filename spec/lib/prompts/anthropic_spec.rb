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

    it "accepts a payload and yields the request and response, returning the block result" do # rubocop:disable RSpec/ExampleLength
      result = described_class.api_request(payload) { |request, response|
        expect(request.body).to(eq(payload.to_json))
        expect(response.code).to(eq("200"))
        "result"
      }

      expect(result).to(eq("result"))
    end

    it "uses the anthropic-beta for cache control" do
      described_class.api_request(payload) {}

      expect(WebMock).to(have_requested(:post, "https://api.anthropic.com/v1/messages").with(
        headers: { "Anthropic-Beta" => "prompt-caching-2024-07-31" },
      ))
    end

    describe "newrelic" do
      before do
        allow(NewRelic::Agent).to(receive(:record_custom_event))
      end

      it "records a custom New Relic event immediately" do # rubocop:disable RSpec/ExampleLength
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

      it "calculates TTL correctly" do # rubocop:disable RSpec/ExampleLength
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
      allow(Prompts).to(receive(:generate_system_xml).with(["foo"], for_prompt_type: "foo").and_return("system-prompt"))
      allow(Prompts).to(receive(:conversation_starters).with("foo").and_return(conversation_starters))
      allow(Prompts).to(receive(:assert_system_prompt_size_safety!).with("foo", "system-prompt"))
      allow(described_class).to(receive(:api_request).and_return("result"))
    end

    it "sends a payload with the messages" do # rubocop:disable RSpec/ExampleLength
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
end
