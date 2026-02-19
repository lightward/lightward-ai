# frozen_string_literal: true

require "rails_helper"

RSpec.describe(CachePerformanceMonitor) do
  describe ".record_api_call" do
    let(:cache_ttl) { "1h" }

    context "when cache hit (only read tokens)" do
      let(:headers) {
        {
          "x-anthropic-cache-creation-input-tokens" => "0",
          "x-anthropic-cache-read-input-tokens" => "1000",
        }
      }

      it "records cache hit status" do
        expect(Rails.logger).to(receive(:info).with(/status=hit/))

        result = described_class.record_api_call(headers, cache_ttl)

        expect(result[:status]).to(eq("hit"))
        expect(result[:creation_tokens]).to(eq(0))
        expect(result[:read_tokens]).to(eq(1000))
      end
    end

    context "when cache miss (only creation tokens)" do
      let(:headers) {
        {
          "x-anthropic-cache-creation-input-tokens" => "1000",
          "x-anthropic-cache-read-input-tokens" => "0",
        }
      }

      it "records cache miss status" do
        expect(Rails.logger).to(receive(:info).with(/status=miss/))

        result = described_class.record_api_call(headers, cache_ttl)

        expect(result[:status]).to(eq("miss"))
        expect(result[:creation_tokens]).to(eq(1000))
        expect(result[:read_tokens]).to(eq(0))
      end
    end

    context "when partial cache hit" do
      let(:headers) {
        {
          "x-anthropic-cache-creation-input-tokens" => "500",
          "x-anthropic-cache-read-input-tokens" => "500",
        }
      }

      it "records partial status" do
        expect(Rails.logger).to(receive(:info).with(/status=partial/))

        result = described_class.record_api_call(headers, cache_ttl)

        expect(result[:status]).to(eq("partial"))
        expect(result[:creation_tokens]).to(eq(500))
        expect(result[:read_tokens]).to(eq(500))
      end
    end

    context "when no cache information available" do
      let(:headers) { {} }

      it "records unknown status" do
        expect(Rails.logger).to(receive(:info).with(/status=unknown/))

        result = described_class.record_api_call(headers, cache_ttl)

        expect(result[:status]).to(eq("unknown"))
        expect(result[:creation_tokens]).to(eq(0))
        expect(result[:read_tokens]).to(eq(0))
      end
    end

    context "with NewRelic available" do
      before do
        stub_const("NewRelic::Agent", double)
      end

      it "sends custom event to NewRelic" do
        headers = {
          "x-anthropic-cache-creation-input-tokens" => "0",
          "x-anthropic-cache-read-input-tokens" => "1000",
        }

        expect(NewRelic::Agent).to(receive(:record_custom_event).with(
          "AnthropicCachePerformance",
          hash_including(
            cache_status: "hit",
            cache_ttl: "1h",
            creation_tokens: 0,
            read_tokens: 1000,
          ),
        ))

        expect(Rails.logger).to(receive(:info))

        described_class.record_api_call(headers, cache_ttl)
      end
    end
  end
end