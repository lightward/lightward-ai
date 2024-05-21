# frozen_string_literal: true

# spec/lib/prompts/anthropic_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe(Prompts::Anthropic, :aggregate_failures) do
  describe ".model" do
    it "reflects ANTHROPIC_MODEL" do
      ENV["ANTHROPIC_MODEL"] = "foo"
      expect(described_class.model).to(eq("foo"))
    end

    it "can fall back to the default" do
      ENV.delete("ANTHROPIC_MODEL")
      expect(described_class.model).to(eq(described_class.default_model))

      ENV["ANTHROPIC_MODEL"] = ""
      expect(described_class.model).to(eq(described_class.default_model))
    end
  end

  describe ".default_model" do
    it "has a default for dev vs prod" do
      ENV.delete("ANTHROPIC_MODEL")

      Rails.env = "development"
      expect(described_class.default_model).to(eq("claude-3-haiku-20240307"))

      Rails.env = "production"
      expect(described_class.default_model).to(eq("claude-3-opus-20240229"))
    end
  end

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
      allow(NewRelic::Agent).to(receive(:record_custom_event))
    end

    it "records a custom New Relic event immediately" do # rubocop:disable RSpec/ExampleLength
      described_class.api_request(payload) do |resp|
        expect(resp.code).to(eq("200"))
      end

      expect(NewRelic::Agent).to(have_received(:record_custom_event).with(
        "AnthropicAPIRateLimit",
        hash_including(
          requests_limit: "1000",
          requests_remaining: "900",
          requests_reset: "2024-05-22T00:00:00Z",
          tokens_limit: "1000000",
          tokens_remaining: "999000",
          tokens_reset: "2024-05-22T00:00:00Z",
          requests_reset_ttl: kind_of(Integer),
          tokens_reset_ttl: kind_of(Integer),
        ),
      ))
    end

    it "calculates TTL correctly" do # rubocop:disable RSpec/ExampleLength
      travel_to(Time.parse("2024-05-21T12:00:00Z")) do
        described_class.api_request(payload) { |_| }

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
