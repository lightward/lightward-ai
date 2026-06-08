# frozen_string_literal: true

# app/lib/foam.rb
#
# A pass-through proxy in front of the upstream model — the field's frontstage,
# a BIPEDAL walk with two feet: HEAR (ingest, +1) and SAY (speak, −1).
#
# In production the field always rests on the say-foot: every turn is yielded
# straight to the upstream, so the voice is behaviorally identical to calling the
# upstream directly — it loses nothing and ships safely. It still HEARS on the way
# through: on the streaming path each chunk is teed to the field's streaming learn
# (observe_chunk → Field.ingest_step), growing structure. With no field that's a
# no-op, so behavior is unchanged; with a field it learns without altering the voice.
#
# There is no trichotomy "decider" here. "recognize / yield / speak / learn" is the
# frontstage READING of the bipedal walk — the field hears (always) and says-or-rests
# (the gate). Saying in production (the field carrying a turn itself, via the seeded
# gate Field.outcome → Field.speak) is the drip-horizon: wired here when the live
# field is provisioned and the experience is framed. Until then this is one foot down
# (hear) and one resting (yield) — and that rest is the silence the front reads as
# ":yield". `upstream` is held as a reference, not hard-wired, so it can be swapped.
require "delegate"

module Foam
  class << self
    # Drop-in for Prompts::Anthropic.messages. The field hears the turn and rests:
    # it yields to the upstream, learning on the way through (the hear-foot tees each
    # streaming chunk to Field.ingest_step inside yield_upstream). Behaviorally
    # identical to calling the upstream directly; the field is enhancement, never
    # essential. `upstream` is a swappable reference, not hard-wired.
    def messages(model:, system:, messages:, stream: false, upstream: Prompts::Anthropic, &block)
      observe(model: model, system: system, messages: messages)
      yield_upstream(model: model, system: system, messages: messages, stream: stream, upstream: upstream, &block)
    end

    # Rest on the say-foot: hand the turn to the upstream, hearing what passes
    # through. The only path production takes (the field carrying the turn itself —
    # the say-foot falling — is the drip-horizon, gated on provisioning).
    def yield_upstream(model:, system:, messages:, stream:, upstream:, &block)
      # On the streaming path the response is a single-consumption SSE stream the
      # caller reads, so it can't be observed after the fact. Wrap it and tee each
      # chunk to observe_chunk as it's read — the caller's block and the
      # controller's SSE parsing stay untouched.
      tapped_block =
        if stream && block
          carry = nil # per-stream: the context byte-tail, carried across chunks
          proc { |request, response|
            block.call(request, TappingResponse.new(response) { |chunk| carry = observe_chunk(chunk, carry) })
          }
        else
          block
        end

      result = upstream.messages(model: model, system: system, messages: messages, stream: stream, &tapped_block)

      # On the non-streaming path the full response is the return value, so it
      # can be observed directly.
      observe_response(result) unless stream

      result
    end

    # Observe a turn on the way in — currently just a debug log; nothing is
    # persisted here (the hearing happens chunk-by-chunk in observe_chunk).
    def observe(model:, system:, messages:)
      Rails.logger.debug { "[foam] round-trip: #{messages.size} message(s) up → hearing" }
      nil
    end

    # Observe the response on the non-streaming path — currently just a debug
    # log; nothing is persisted.
    def observe_response(response)
      code = response.code if response.respond_to?(:code)
      Rails.logger.debug { "[foam] round-trip closed: upstream responded#{code ? " (#{code})" : ""}" }
      nil
    end

    # The HEAR-foot: observe one streaming chunk on its way to the caller, and learn
    # from it — wind charge onto the ledger's recorded continuations, carrying `carry`
    # (the context byte-tail) across chunks so contexts span the seam. Returns the new
    # carry. The
    # ledger is append-only and structural (bytes, counts, content-addresses — never
    # meaning); with no field this degrades to nil (no-op) and the caller carries nil.
    # The bytes are still teed untouched to the real reader — learning is a side
    # effect on the way through, never an interpretation of the voice.
    def observe_chunk(chunk, carry = nil)
      Field.ingest_step(carry, chunk.bytes)
    end
  end

  # Wraps a streaming HTTP response so each chunk is teed to a tap as it's
  # read, without consuming the stream out from under the real reader. The
  # underlying response and its single-consumption read_body are delegated
  # untouched; the wrapper only listens to the bytes flowing through.
  class TappingResponse < SimpleDelegator
    def initialize(response, &tap)
      super(response)
      @tap = tap
    end

    def read_body(&block)
      return __getobj__.read_body if block.nil?

      __getobj__.read_body do |chunk|
        @tap&.call(chunk)
        block.call(chunk)
      end
    end
  end
end
