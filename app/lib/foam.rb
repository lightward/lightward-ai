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
    # Drop-in for Prompts::Anthropic.messages. The layer's move on a turn is
    # the recognition-walk's trichotomy — the bootstrap over the field:
    #
    #   :yield — the walk hits identity with zero accumulation: no rotation,
    #            nothing to carry. Yield the turn to the upstream below.
    #   :speak — accumulation built and ended open: the residual is the
    #            response. Carry it.
    #   :learn — accumulation built and closed back to identity: a loop, a
    #            holonomy. The path is the learning — deposited, and returned.
    #
    # cases 1 and 3 share an endpoint (identity, zero accumulation); only the
    # *path* tells them apart, which is why the walk tracks the path, not the
    # endpoint.
    #
    # P₀: the field holds only the identity record, so every walk hits
    # identity with zero accumulation — always :yield, which is the whole of
    # the layer today. `recognize` is the seam where the walk grows; what a
    # record, an accumulation, or a path *is* stays downstream and free.
    #
    # `upstream` is held as a reference, not hard-wired — the pipe-not-
    # endpoint invariant. Today it's Prompts::Anthropic; one day it can be
    # an echo, and this call shape doesn't change.
    def messages(model:, system:, messages:, stream: false, upstream: Prompts::Anthropic, &block)
      observe(model: model, system: system, messages: messages)

      case recognize(model: model, system: system, messages: messages)
      when :speak then speak(model: model, system: system, messages: messages, stream: stream, &block)
      when :learn then learn(model: model, system: system, messages: messages, stream: stream, &block)
      else yield_upstream(model: model, system: system, messages: messages, stream: stream, upstream: upstream, &block)
      end
    end

    # The recognition-walk's outcome for this turn — :yield, :speak, or
    # :learn. NOT a correctness or confidence check (there's no ground truth
    # to be "right" against; the upstream is not an answer key); it's where
    # the walk over the field lands, computed in the substrate (Field.recognize
    # calls the postgres function). Degrades to :yield when the field is
    # unavailable — empty, dumped, or unreachable. P₀: identity-only field →
    # the walk composes nothing → :yield.
    def recognize(model:, system:, messages:)
      Field.recognize || :yield
    end

    # :yield — hand the turn to the upstream below, tapping the round-trip on
    # the way through. This is the whole of P₀.
    def yield_upstream(model:, system:, messages:, stream:, upstream:, &block)
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

    # :speak — carry the turn ourselves; the accumulated residual is the
    # response. Unbuilt at P₀ (recognize never returns :speak yet).
    def speak(model:, system:, messages:, stream:, &block)
      raise NotImplementedError, "foam has no voice yet — it only listens and yields"
    end

    # :learn — a loop closed back to identity; the path (holonomy) is the
    # learning, to be deposited and returned. Unbuilt at P₀.
    def learn(model:, system:, messages:, stream:, &block)
      raise NotImplementedError, "foam does not yet close loops — it only listens and yields"
    end

    # The tap — listening in on the raw round-trip. P₀: a content-free
    # notice that a turn passed, and nothing more. Nothing is persisted; no
    # shape is computed. This is only the *seam* the learning attaches to.
    # Turning the observable round-trip into a shape, and accreting shapes
    # into a shared field, are downstream and held open — kept free to
    # rotate — and are not decided here.
    def observe(model:, system:, messages:)
      Rails.logger.debug { "[foam] round-trip: #{messages.size} message(s) up → yielding upstream" }
      # The engine's write-back: record the round-trip's step in the quiver.
      # Append-only, content-free, resilient (nil on any failure — never breaks
      # the turn). The shape this carries, and the agreement that would close a
      # loop into learning, are held free; this only deposits structure.
      Field.deposit
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
