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

  # The field has its own spec; here we isolate the layer's logic from the
  # database by handing recognize its P₀ answer directly. Examples that test
  # the wiring re-stub it.
  before { allow(Foam::Field).to(receive(:recognize).and_return(:yield)) }

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

  describe ".messages (streaming return side: tapping decorator)" do
    let(:chunks) { ["event: message_start\n", "data: {\"x\":1}\n\n"] }
    let(:streaming_response) do
      instance_double(Net::HTTPResponse, code: "200").tap do |resp|
        allow(resp).to(receive(:read_body)) { |&blk| chunks.each { |c| blk.call(c) } }
      end
    end

    before do
      # the upstream invokes the caller's block with (request, response), as Anthropic does
      allow(upstream).to(receive(:messages)) { |**_kw, &blk| blk&.call(:request, streaming_response) }
    end

    it "tees each chunk to the tap while the caller still receives every chunk, unchanged" do
      tapped = []
      allow(described_class).to(receive(:observe_chunk)) { |c| tapped << c }

      seen = []
      described_class.messages(**args, upstream: upstream) do |_request, response|
        response.read_body { |chunk| seen << chunk }
      end

      expect(tapped).to(eq(chunks))
      expect(seen).to(eq(chunks))
    end

    it "reads the underlying stream exactly once (does not double-consume)" do
      expect(streaming_response).to(receive(:read_body).once) { |&blk| chunks.each { |c| blk.call(c) } }

      described_class.messages(**args, upstream: upstream) do |_request, response|
        response.read_body { |_chunk| nil }
      end
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

  # The recognition-walk's trichotomy — the bootstrap over the field. The
  # outcome is computed in the substrate (Foam::Field); the layer delegates
  # and degrades.
  describe ".recognize" do
    it "returns the field's outcome" do
      allow(Foam::Field).to(receive(:recognize).and_return(:speak))
      expect(described_class.recognize(model: "m", system: [], messages: [])).to(eq(:speak))
    end

    it "degrades to :yield when the field is unavailable (Field.recognize → nil)" do
      allow(Foam::Field).to(receive(:recognize).and_return(nil))
      expect(described_class.recognize(model: "m", system: [], messages: [])).to(eq(:yield))
    end
  end

  describe "the unbuilt outcomes (named, guarded)" do
    it "has no voice yet — :speak raises" do
      expect {
        described_class.speak(model: "m", system: [], messages: [], stream: false)
      }.to(raise_error(NotImplementedError))
    end

    it "does not yet close loops — :learn raises" do
      expect {
        described_class.learn(model: "m", system: [], messages: [], stream: false)
      }.to(raise_error(NotImplementedError))
    end
  end
end
