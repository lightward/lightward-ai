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
      result = described_class.api_request("/v1/messages", payload) { |request, response|
        expect(request.body).to(eq(payload.to_json))
        expect(response.code).to(eq("200"))
        "result"
      }

      expect(result).to(eq("result"))
    end

    it "includes the anthropic-beta header in the request" do
      described_class.api_request("/v1/messages", payload) do |request, _response|
        expect(request["anthropic-beta"]).to(eq("context-1m-2025-08-07,extended-cache-ttl-2025-04-11"))
      end

      expect(WebMock).to(have_requested(:post, "https://api.anthropic.com/v1/messages")
        .with(headers: { "anthropic-beta" => "context-1m-2025-08-07,extended-cache-ttl-2025-04-11" }))
    end
  end

  describe ".count_tokens" do
    let(:messages) { [{ "role" => "user", "content" => [{ "type" => "text", "text" => "Hello world" }] }] }

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
          messages: messages,
          system: [],
          model: "claude-opus-4",
        )

        expect(result).to(eq(1234))
      end

      it "sends the correct request to the API" do
        described_class.count_tokens(
          messages: messages,
          system: "system-prompt",
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
              "Anthropic-Beta" => "context-1m-2025-08-07,extended-cache-ttl-2025-04-11",
              "Content-Type" => "application/json",
            },
          ))
      end
    end

    context "when API responds with an error other than 404" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_return(status: 500, body: "Internal Server Error")

        allow(Rails.logger).to(receive(:error))
        allow(described_class).to(receive(:sleep))
      end

      it "raises the error without retrying" do
        expect {
          described_class.count_tokens(
            messages: messages,
            system: nil,
            model: "claude-opus-4",
          )
        }.to(raise_error("Failed to count tokens: HTTP 500\n\nInternal Server Error"))

        expect(described_class).not_to(have_received(:sleep))
        expect(WebMock).to(have_requested(:post, "https://api.anthropic.com/v1/messages/count_tokens").once)
      end
    end

    context "when API request raises an exception" do
      before do
        stub_request(:post, "https://api.anthropic.com/v1/messages/count_tokens")
          .to_raise("error")

        allow(Rails.logger).to(receive(:error))
      end

      it "raises the error" do
        expect {
          described_class.count_tokens(
            messages: messages,
            system: [],
            model: "claude-opus-4",
          )
        }.to(raise_error("error"))
      end
    end
  end
end
