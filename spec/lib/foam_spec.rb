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

  # The field is a BIPEDAL walk: HEAR (ingest) and SAY (speak). In production it
  # always rests on the say-foot — yields to the upstream — and hears on the way
  # through. There is no "recognize" decider (frontstage fiction over the two feet),
  # so nothing to stub: messages always yields.

  # P₀'s load-bearing invariant: the pipe loses nothing. This is what must
  # stay true for the layer to be safe to put in the path — and the thing
  # to keep protected as the layer grows a voice: whatever it learns to
  # speak, the turns it yields must yield faithfully.
  describe ".messages (P₀: 100% yield — the say-foot rests)" do
    it "yields every turn straight to the upstream, unchanged, and returns its result" do
      allow(upstream).to(receive(:messages).with(**args).and_return(:upstream_result))

      result = described_class.messages(**args, upstream: upstream)

      expect(result).to(eq(:upstream_result))
      expect(upstream).to(have_received(:messages).with(**args))
    end

    it "does not pass its own upstream: kwarg down to the upstream" do
      # the pipe holds the upstream reference; it does not leak it into the call
      received = nil
      allow(upstream).to(receive(:messages)) { |**kw| received = kw }

      described_class.messages(**args, upstream: upstream)

      expect(received).not_to(include(:upstream))
    end

    it "observes the response on the non-streaming path (the round-trip is fully visible there)" do
      response = instance_double(Net::HTTPResponse, code: "200")
      allow(upstream).to(receive(:messages).and_return(response))
      allow(described_class).to(receive(:observe_response))

      described_class.messages(**args.merge(stream: false), upstream: upstream)

      expect(described_class).to(have_received(:observe_response).with(response))
    end

    it "does not try to observe the streaming response (single-consumption — its own brick)" do
      allow(upstream).to(receive(:messages).and_return(:streamed))
      allow(described_class).to(receive(:observe_response))

      described_class.messages(**args.merge(stream: true), upstream: upstream)

      expect(described_class).not_to(have_received(:observe_response))
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
      described_class.messages(**args, upstream: upstream) do |_request, response|
        response.read_body { |_chunk| nil }
      end

      expect(streaming_response).to(have_received(:read_body).once)
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

  # The HEAR-foot degrades like everything else: with no field, observe_chunk is a
  # no-op (Field.ingest_step → nil) and the bytes still flow to the reader untouched.
  # (Verified live in the streaming tests above: the tap runs, the caller gets every
  # chunk.) The voice — what the field would SAY — is the free fiber, held downstream
  # via the seeded gate (Field.outcome → Field.speak), wired in production at the
  # drip-horizon, not decided in this plumbing. The pipe hands up; it never raises
  # (a raise would be an endpoint, and the upstream slot never closes).
  describe ".observe_chunk (the hear-foot, content-free without a field)" do
    it "returns nil with no field and never raises" do
      expect { described_class.observe_chunk("data: {}\n\n") }.not_to(raise_error)
      expect(described_class.observe_chunk("data: {}\n\n")).to(be_nil)
    end
  end
end
