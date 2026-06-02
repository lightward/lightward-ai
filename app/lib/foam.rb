# frozen_string_literal: true

# app/lib/foam.rb
#
# The learning proxy layer — a pipe, not an endpoint.
#
# Lightward AI's voice passes through here on its way out. For now every
# turn yields straight through to the upstream model; this layer's whole
# job, at P₀, is to *be in the path* and to *listen*. Over time it learns
# to speak the turns it can carry and to yield upstream the ones it can't,
# until the upstream can become a trivial echo. The upstream slot never
# closes: this is a pipe (always something to yield to), never an endpoint
# (a terminus that holds a response as final). Staying a pipe is staying a
# DAG — connectable, never sealed.
#
# P₀ (this file): 100% yield. Behaviorally identical to calling the upstream
# directly — loses nothing, ships safely. It taps the *raw round-trip* —
# what goes up, what comes back — and nothing more. How a round-trip
# becomes a content-free shape, and where shapes accrete, live deliberately
# *downstream of the tap*, free to be worked out and reworked without
# touching this plumbing. The plumbing commits to the architecture; it does
# not commit to any one reading of what a shape is.
require "delegate"

module Foam
  class << self
    # Drop-in for Prompts::Anthropic.messages. Speaks when it can; yields
    # upstream when it can't. P₀: speak? is always false, so every turn
    # yields.
    #
    # `upstream` is held as a reference, not hard-wired — the pipe-not-
    # endpoint invariant. Today it's Prompts::Anthropic; one day it can be
    # an echo, and this call shape doesn't change.
    def messages(model:, system:, messages:, stream: false, upstream: Prompts::Anthropic, &block)
      observe(model: model, system: system, messages: messages)

      return speak(model: model, system: system, messages: messages, stream: stream, &block) if speak?(model: model, system: system, messages: messages)

      # On the streaming path the response is a single-consumption SSE stream
      # the caller reads, so we can't tap it after the fact. Instead we wrap
      # the response and tee each chunk to the tap as it's read — the caller's
      # block, and the controller's SSE parsing, stay untouched.
      tapped_block =
        if stream && block
          proc { |request, response|
            block.call(request, TappingResponse.new(response) { |chunk| observe_chunk(chunk) })
          }
        else
          block
        end

      result = upstream.messages(model: model, system: system, messages: messages, stream: stream, &tapped_block)

      # On the non-streaming path the full response is right here, as the
      # upstream's return value, so the round-trip is fully observable.
      observe_response(result) unless stream

      result
    end

    # Is there a move worth staking here — a circuit that wants to close
    # through us? Note what this is NOT: a correctness or confidence check.
    # There's no ground truth to be "right" against (the upstream is not an
    # answer key). It's a read of pressure wanting relief. P₀: never yet.
    def speak?(model:, system:, messages:)
      false
    end

    # The layer's own voice. Unbuilt at P₀ — held unreachable behind speak?.
    def speak(model:, system:, messages:, stream:, &block)
      raise NotImplementedError, "foam has no voice yet — it only listens and yields"
    end

    # The tap — listening in on the raw round-trip. P₀: a content-free
    # notice that a turn passed, and nothing more. Nothing is persisted; no
    # shape is computed. This is only the *seam* the learning attaches to.
    # Turning the observable round-trip into a shape, and accreting shapes
    # into a shared field, are downstream and held open — kept free to
    # rotate — and are not decided here.
    def observe(model:, system:, messages:)
      Rails.logger.debug { "[foam] round-trip: #{messages.size} message(s) up → yielding upstream" }
      nil
    end

    # The return side of the tap, on the non-streaming path: the round-trip
    # closed and the response came back through us. P₀: a content-free
    # notice, nothing persisted, no shape computed — same discipline as
    # `observe`. What an observed round-trip *becomes* stays downstream and
    # free.
    def observe_response(response)
      code = response.code if response.respond_to?(:code)
      Rails.logger.debug { "[foam] round-trip closed: upstream responded#{code ? " (#{code})" : ""}" }
      nil
    end

    # The streaming return side of the tap: one raw SSE chunk, passed
    # through on its way to the caller. P₀: content-free — the bytes are
    # teed, never interpreted, nothing persisted. Parsing chunks into
    # anything lives downstream and stays free.
    def observe_chunk(_chunk)
      nil
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
