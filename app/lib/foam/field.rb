# frozen_string_literal: true

# app/lib/foam/field.rb
#
# The connection to the field substrate — raw postgres, no ActiveRecord.
# The recognition-walk is a postgres function (foam.recognize); Ruby's only
# job here is to hold a pooled connection, assert the schema on boot, and
# call the function. There are no models and no CRUD.
#
# The whole of this file is built around one invariant: the field is
# enhancement, never essential. If the database is unreachable, empty, or
# dumped, every operation degrades to nil/:yield and the app runs exactly as
# it does without a field. Nothing here may raise into boot or into a
# request — the dumpability guarantee, in code.

require "pg"
require "connection_pool"

module Foam
  module Field
    SCHEMA_PATH = "app/lib/foam/schema.sql"

    class << self
      # Assert the substrate, idempotently — the schema as a fixed point,
      # not a migration. Uses a one-shot connection (not the pool) so it is
      # safe to run in a preloading master before fork. Boot-resilient: any
      # failure is logged and swallowed; the app boots without a field.
      def assert!
        conn = PG.connect(database_url)
        conn.exec(schema_sql)
        Rails.logger.info("[foam] field asserted")
        true
      rescue => e
        Rails.logger.warn("[foam] field assertion skipped (#{e.class}: #{e.message}) — running without a field")
        false
      ensure
        conn&.finish
      end

      # The walk's outcome for a turn, as a symbol — currently always :yield —
      # or nil if the field is unavailable (the caller maps nil to :yield).
      def recognize
        outcome = with_connection { |conn| conn.exec("SELECT foam.recognize()").getvalue(0, 0) }
        outcome&.to_sym
      end

      # One pass over the field: compute the outcome (recognize) and deposit the
      # input path, in a single SQL call (foam.walk). Returns the outcome as a
      # symbol — currently always :yield — or nil on any failure (the caller then
      # yields). `input` is an array of node ids; an empty input deposits nothing.
      def walk(input = [])
        literal = "{#{Array(input).join(",")}}"
        outcome = with_connection { |conn|
          conn.exec_params("SELECT foam.walk($1::uuid[])", [literal]).getvalue(0, 0)
        }
        outcome&.to_sym
      end

      # Grow the dictionary from a chunk of the streaming voice: one streaming pass
      # of the codec's emitting fold (foam.encode_step), resuming from `cursor` (the
      # partial match carried across chunks; nil starts at the root). It deposits new
      # chunks append-only and returns the new cursor to carry to the next chunk.
      # Learning is the deposit; the emitted id-stream is not kept, so the field
      # grows its model (the dictionary) without storing the transcript. Resilient:
      # with no field it returns nil, and the caller carries nil — resetting to root
      # on the next chunk, still lossless, just re-segmented. `bytes` is an array of
      # 0–255 ints. ← app/lib/foam/schema.sql foam.encode_step ← lean/Foam/Stream.lean.
      def encode_step(cursor, bytes)
        bytes = Array(bytes)
        return cursor if bytes.empty?

        with_connection { |conn|
          conn.exec_params(
            "SELECT next_cursor FROM foam.encode_step($1, $2::int[])",
            [cursor, "{#{bytes.join(",")}}"],
          ).getvalue(0, 0)
        }
      end

      # The field's outcome for a turn (the trichotomy gate): :speak if the field has
      # drainable charge (it can carry the turn from what it has learned), else :yield
      # (hand to the upstream — a living ancestor, or an echo). nil with no field, which
      # the caller maps to :yield. ← foam.outcome. Currently a weak gate (charge
      # presence); the structural signal stays structural, never a measure of meaning.
      def outcome
        o = with_connection { |conn| conn.exec("SELECT foam.outcome()").getvalue(0, 0) }
        o&.to_sym
      end

      # Speak: drain the field's charge into a voice (the discharge). Returns the text,
      # or nil with no field. Weak (root-anchored) at this stage — the starting-weakly
      # step; coherent generation is a later refinement. ← foam.speak.
      def speak(max_steps = 400)
        with_connection { |conn|
          conn.exec_params("SELECT foam.speak($1)", [max_steps]).getvalue(0, 0)
        }
      end

      # Drop the connection pool (e.g. on worker boot after a fork).
      # Connections re-establish lazily on next use.
      def disconnect!
        @pool&.shutdown(&:finish)
        @pool = nil
      end

      private

      # Check out a pooled connection and run the block. Any failure —
      # connection, pool-timeout, query — is swallowed to nil; a broken
      # connection is best-effort reset so the pool heals. No field ⇒ nil ⇒
      # the caller yields.
      def with_connection
        pool.with do |conn|
          conn.reset if conn.status != PG::CONNECTION_OK
          yield conn
        end
      rescue => e
        Rails.logger.debug { "[foam] field unavailable (#{e.class}: #{e.message}) — degrading to yield" }
        nil
      end

      # Created lazily, so it is never built in a preloading master — each
      # worker gets its own pool on first use, after fork.
      def pool
        @pool ||= ConnectionPool.new(size: pool_size, timeout: checkout_timeout) do
          PG.connect(database_url)
        end
      end

      def database_url
        ENV.fetch("FOAM_DATABASE_URL") do
          # In test the field is opt-in (its own spec sets the URL explicitly);
          # default to unreachable so the rest of the suite never touches a real
          # database — every Field op simply degrades, exactly as in production
          # before the field is provisioned.
          Rails.env.test? ? "postgres://127.0.0.1:1/foam?connect_timeout=1" : "postgres:///foam?connect_timeout=2"
        end
      end

      def pool_size
        Integer(ENV.fetch("FOAM_POOL_SIZE", "5"))
      end

      def checkout_timeout
        Float(ENV.fetch("FOAM_CHECKOUT_TIMEOUT", "1"))
      end

      def schema_sql
        File.read(Rails.root.join(SCHEMA_PATH))
      end
    end
  end
end
