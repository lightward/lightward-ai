# frozen_string_literal: true

# app/lib/foam.rb
#
# A pass-through proxy in front of the upstream model.
#
# Every turn is yielded straight to the upstream (recognize → :yield), so the voice
# is behaviorally identical to calling the upstream directly — it loses nothing and
# ships safely. On the streaming path the layer also *learns* on the way through:
# each chunk is teed to the codec's streaming encode (observe_chunk →
# Field.encode_step), growing the field's dictionary. With no field that deposit is
# a no-op, so the behavior is unchanged; with a field it grows structure without
# altering the voice.
#
# `upstream` is held as a reference, not hard-wired, so it can be swapped — this
# layer always has something to delegate to and never holds a response as final.
# Turning an observed turn into stored structure lives in Foam::Field / the SQL,
# not here.
require "delegate"

module Foam
  class << self
    # Drop-in for Prompts::Anthropic.messages. Dispatches on the field's outcome
    # (recognize):
    #
    #   :yield — hand the turn to the upstream (yield_upstream). The only outcome
    #            currently produced.
    #   :speak — designed, not implemented; currently delegates to the upstream
    #            (see #speak).
    #   :learn — designed, not implemented; currently delegates to the upstream
    #            (see #learn).
    #
    # The field currently only returns :yield (or nil, which the caller maps to
    # :yield), so every turn yields to the upstream — behaviorally identical to
    # calling it directly. `upstream` is a swappable reference, not hard-wired.
    def messages(model:, system:, messages:, stream: false, upstream: Prompts::Anthropic, &block)
      observe(model: model, system: system, messages: messages)

      case recognize(model: model, system: system, messages: messages)
      when :speak then speak(model: model, system: system, messages: messages, stream: stream, upstream: upstream, &block)
      when :learn then learn(model: model, system: system, messages: messages, stream: stream, upstream: upstream, &block)
      else yield_upstream(model: model, system: system, messages: messages, stream: stream, upstream: upstream, &block)
      end
    end

    # The field's outcome for this turn — currently always :yield. Not a
    # correctness or confidence check; it's whatever Field.walk returns (a
    # postgres call), with nil mapped to :yield. The field is enhancement, never
    # essential: empty, dumped, or unreachable, it degrades to :yield.
    def recognize(model:, system:, messages:)
      # One SQL call (Field.walk): compute the outcome and deposit the input in
      # one pass. nil (no field) maps to :yield.
      Field.walk(walk_input(model: model, system: system, messages: messages)) || :yield
    end

    # The array of node ids to seed Field.walk with. Currently always empty (no
    # extraction is implemented), so the walk deposits nothing.
    def walk_input(model:, system:, messages:)
      []
    end

    # :yield — hand the turn to the upstream, observing what passes through. The
    # only path currently taken.
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

    # :speak — designed: carry the turn here instead of yielding. Not implemented;
    # delegates to the upstream for now. This layer always delegates rather than
    # raising — there is always an upstream to hand to.
    def speak(model:, system:, messages:, stream:, upstream:, &block)
      yield_upstream(model: model, system: system, messages: messages, stream: stream, upstream: upstream, &block)
    end

    # :learn — designed: record structure for the turn and return it. The
    # structural write already happens in the walk (Field.walk deposits); the
    # returning part is not implemented, so this delegates to the upstream for now.
    def learn(model:, system:, messages:, stream:, upstream:, &block)
      yield_upstream(model: model, system: system, messages: messages, stream: stream, upstream: upstream, &block)
    end

    # Observe a turn on the way in — currently just a debug log; nothing is
    # persisted. The attachment point for the not-yet-built learning layer.
    def observe(model:, system:, messages:)
      Rails.logger.debug { "[foam] round-trip: #{messages.size} message(s) up → walking" }
      nil
    end

    # Observe the response on the non-streaming path — currently just a debug
    # log; nothing is persisted.
    def observe_response(response)
      code = response.code if response.respond_to?(:code)
      Rails.logger.debug { "[foam] round-trip closed: upstream responded#{code ? " (#{code})" : ""}" }
      nil
    end

    # Observe one streaming chunk on its way to the caller, and learn from it: wind
    # charge onto the ledger's recorded continuations, carrying `carry` (the context
    # byte-tail) across chunks so contexts span the seam. Returns the new carry. The
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
