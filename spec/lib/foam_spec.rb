# frozen_string_literal: true

# spec/lib/foam_spec.rb
require "rails_helper"

RSpec.describe(Foam, :aggregate_failures) do
  let(:upstream) { class_double(Prompts::Anthropic) }
  let(:args) do
    {
      model: "claude-sonnet-4-6",
      system: [{ type: "text", text: "system" }],
      messages: [{ role: "user", content: [{ type: "text", text: "hi" }] }],
      stream: true,
    }
  end

  # P₀'s load-bearing invariant: the pipe loses nothing. This is what must
  # stay true for the layer to be safe to put in the path — and the thing
  # to keep protected as the layer grows a voice: whatever it learns to
  # speak, the turns it yields must yield faithfully.
  describe ".messages (P₀: 100% yield)" do
    it "yields every turn straight to the upstream, unchanged, and returns its result" do
      expect(upstream).to(receive(:messages).with(**args).and_return(:upstream_result))

      result = described_class.messages(**args, upstream: upstream)

      expect(result).to(eq(:upstream_result))
    end

    it "passes the streaming block through to the upstream untouched" do
      block = proc { |req, res| [req, res] }
      received_block = nil
      allow(upstream).to(receive(:messages)) { |**_kw, &blk| received_block = blk }

      described_class.messages(**args, upstream: upstream, &block)

      expect(received_block).to(be(block))
    end

    it "does not pass its own upstream: kwarg down to the upstream" do
      # the pipe holds the upstream reference; it does not leak it into the call
      expect(upstream).to(receive(:messages)) { |**kw| expect(kw).not_to(include(:upstream)) }

      described_class.messages(**args, upstream: upstream)
    end

    it "observes the response on the non-streaming path (the round-trip is fully visible there)" do
      response = instance_double(Net::HTTPResponse, code: "200")
      allow(upstream).to(receive(:messages).and_return(response))
      expect(described_class).to(receive(:observe_response).with(response))

      described_class.messages(**args.merge(stream: false), upstream: upstream)
    end

    it "does not try to observe the streaming response (single-consumption — its own brick)" do
      allow(upstream).to(receive(:messages).and_return(:streamed))
      expect(described_class).not_to(receive(:observe_response))

      described_class.messages(**args.merge(stream: true), upstream: upstream)
    end
  end

  describe ".observe_response (return side of the tap, content-free)" do
    it "returns nil and persists nothing" do
      expect(described_class.observe_response(instance_double(Net::HTTPResponse, code: "200"))).to(be_nil)
    end

    it "tolerates a response that has no code" do
      expect(described_class.observe_response(Object.new)).to(be_nil)
    end
  end

  # The seam where "speaks when it can" will grow — currently closed.
  describe ".speak?" do
    it "is false at P₀ — no move worth staking yet" do
      expect(described_class.speak?(model: "m", system: [], messages: [])).to(be(false))
    end
  end

  describe ".speak" do
    it "has no voice yet (held unreachable behind speak?)" do
      expect {
        described_class.speak(model: "m", system: [], messages: [], stream: false)
      }.to(raise_error(NotImplementedError))
    end
  end
end
