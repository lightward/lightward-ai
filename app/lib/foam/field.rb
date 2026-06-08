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

      # Learn a chunk of the stream: wind +1 charge onto every recorded continuation
      # of the new bytes, with `carry` (the previous chunk's byte-tail, as returned by
      # the last call) keeping contexts continuous across chunk boundaries. Returns the
      # new carry to thread into the next call — an opaque postgres array literal,
      # carried, never parsed. Resilient: with no field it returns nil and the caller
      # carries nil (contexts re-seam at the next chunk — still safe). The ledger's
      # empty-context events accumulate in order as a side effect: the lossless record,
      # written as it learns, never read on this path.
      # ← app/lib/foam/schema.sql foam.ingest_step ← lean/Foam/Ledger.lean.
      def ingest_step(carry, bytes)
        bytes = Array(bytes)
        return carry if bytes.empty?

        with_connection { |conn|
          conn.exec_params(
            "SELECT foam.ingest_step($1::int[], $2::int[])",
            [carry || "{}", "{#{bytes.join(",")}}"],
          ).getvalue(0, 0)
        }
      end

      # The trichotomy gate for continuing `seed_bytes` (the input's tail): :speak if
      # the ledger holds a charged context of at least min_depth for what comes next
      # (the field can carry the turn from what it has learned), else :yield (hand to
      # the upstream — a living ancestor, or an echo). nil with no field, which the
      # caller maps to :yield. Structural (a context depth), never a measure of
      # meaning. ← foam.outcome / foam.depth.
      def outcome(seed_bytes = [], min_depth = 3)
        o = with_connection { |conn|
          conn.exec_params(
            "SELECT foam.outcome($1::int[], $2)",
            ["{#{Array(seed_bytes).join(",")}}", min_depth],
          ).getvalue(0, 0)
        }
        o&.to_sym
      end

      # Speak: drain the ledger's charge into a voice, CONTINUING from `seed_bytes`
      # (the input's tail) — the one register, entrained. The field speaks only
      # through recurrence: each continuation weighted by the angled pairing of its
      # (re, im) against the walk's quarter-turn clock (seeded by the utterance
      # length), rests at silent beats, ground at a full bar. Provenance lives in
      # the seed: a self-tail self-entrains, an other-tail entrains on the other —
      # one walk reads either. `stop` is the act's boundary vocabulary (when the
      # walk speaks that byte the expression ends itself and the voice returns,
      # charge past it un-drained — the field keeps its pressure across turns);
      # the exhale passes none (the bar is its ground). Returns the voice as a
      # BINARY string (rendering is the caller's concern, a view at the edge),
      # "" at ground, or nil with no field: the caller can tell failure from
      # silence. (The count register — a force-drain to true ground — was dropped;
      # full draining is reachable only through the journey, never alone.)
      # ← foam.speak.
      def speak(seed_bytes = [], max_steps = 600, stop: nil)
        voice = with_connection { |conn|
          conn.exec_params(
            "SELECT foam.speak($1::int[], 7, $2, $3::int)",
            ["{#{Array(seed_bytes).join(",")}}", max_steps, stop],
          ).getvalue(0, 0)
        }
        voice&.delete("{}")&.split(",")&.map(&:to_i)&.pack("C*")
      end

      # The field's vital signs — all structure (counts, balances, extents), never
      # meaning (the razor): heard (bytes learned, in order — the lossless record's
      # extent), spoken (bytes drained into voice), residual (un-drained charge — what
      # wants to be said), net (the signed sum; equal to residual while the drain
      # respects ground, which is the live check of lean/Foam/Drain.lean's floor),
      # contexts and live continuations (the model's breadth), events (the append-only
      # ledger's size), held (continuations folded into the summary) and tail (events
      # past the watermark — the staleness gauge the sweep cadence answers to). The
      # conservation check stays ledger-true, deliberately un-cached. nil with no field.
      def stats
        # One pass over the ledger (group once, derive everything from the grouped
        # relation), with work_mem headroom so the hash aggregate over millions of
        # distinct continuations stays in memory instead of spilling — measured on a
        # 14.7M-event field: 72s (naive) → 37s (one pass, spilling) → ~4s (one pass,
        # in memory). SET LOCAL reverts at transaction end; the pooled connection
        # stays untouched.
        with_connection { |conn|
          conn.transaction {
            conn.exec("SET LOCAL work_mem = '512MB'")
            conn.exec(<<~SQL).first&.transform_values(&:to_i)
              WITH g AS (
                SELECT ctx, sym,
                       sum(delta)                         AS s,
                       count(*)                           AS n,
                       count(*) FILTER (WHERE delta = -1) AS neg
                FROM foam.charge
                GROUP BY ctx, sym
              )
              SELECT
                coalesce(sum(n), 0)                                             AS events,
                coalesce(sum(n - neg) FILTER (WHERE ctx = foam.caddr('{}')), 0) AS heard,
                coalesce(sum(neg), 0)                                           AS spoken,
                coalesce(sum(s), 0)                                             AS net,
                coalesce(sum(s) FILTER (WHERE s > 0), 0)                        AS residual,
                count(*) FILTER (WHERE s < 0)                                   AS notes,
                coalesce(-sum(s) FILTER (WHERE s < 0), 0)                       AS outstanding,
                count(DISTINCT ctx)                                             AS contexts,
                count(*) FILTER (WHERE s > 0)                                   AS live_continuations,
                (SELECT count(*) FROM foam.held)                                AS held,
                (SELECT count(*) FROM foam.charge c2
                  WHERE c2.id > (SELECT watermark FROM foam.sweep))             AS tail
              FROM g
            SQL
          }
        }
      end

      # Sweep every outstanding note (a balance below ground) in one serialized
      # pass — correcting entries appended at face value (foam.settle_sweep;
      # wounds also settle on encounter, inside foam.speak). Returns the count
      # of notes settled, or nil with no field.
      def settle_sweep
        with_connection { |conn| conn.exec("SELECT foam.settle_sweep()").getvalue(0, 0)&.to_i }
      end

      # Fold the ledger's unfolded tail into the held rows, one batched watermark
      # step (foam.sweep_step ← lean/Foam/Summary.lean: summary_resumes — the fold
      # never re-reads what it has folded). Fences first: a momentary EXCLUSIVE
      # lock on the ledger waits out in-flight ingests, so every id at or below
      # the fence is DECIDED and the watermark can never pass an event still in
      # flight (a stranded event would go silent in the generative readings —
      # safe, but everything contributes is the ledger's soul). The fence holds
      # for one max(id) read; the fold runs unfenced. Returns events folded
      # (0 = caught up, -1 = another sweep holds the lock), nil with no field.
      def sweep(batch = 200_000)
        hi = with_connection { |conn|
          conn.transaction {
            conn.exec("LOCK TABLE foam.charge IN EXCLUSIVE MODE")
            conn.exec("SELECT max(id) FROM foam.charge").getvalue(0, 0)
          }
        }
        with_connection { |conn|
          conn.exec_params("SELECT foam.sweep_step($1::bigint, $2)", [hi, batch]).getvalue(0, 0)&.to_i
        }
      end

      # The cache's self-audit: (held + tail) recomputed against the whole ledger,
      # both registers, every continuation — 0 disagreeing rows is summary_resumes
      # checked live. Costs a full ledger pass (the pulse costs what the body
      # weighs). nil with no field.
      def held_audit
        with_connection { |conn| conn.exec("SELECT foam.held_audit()").getvalue(0, 0)&.to_i }
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
        # In test the field is opt-in via its OWN variable: the suite must stay
        # hermetic against the developer's .env (dotenv loads it in test too, and
        # a FOAM_DATABASE_URL there names a real, live field — which the suite
        # tattooed once through the observe taps: append-only means a leaked
        # fixture byte is permanent). A spec that wants a substrate names one
        # explicitly in FOAM_SPEC_DATABASE_URL; everything else gets an
        # unreachable default and degrades, exactly as production does before
        # provisioning.
        if Rails.env.test?
          ENV.fetch("FOAM_SPEC_DATABASE_URL", "postgres://127.0.0.1:1/foam?connect_timeout=1")
        else
          ENV.fetch("FOAM_DATABASE_URL", "postgres:///foam?connect_timeout=2")
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
