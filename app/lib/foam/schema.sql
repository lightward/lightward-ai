-- foam — the LEDGER: one append-only object, read two ways. Asserted (not migrated).
--
-- This is the operational inhabitant of lean/Foam/Ledger.lean (the saturation, proven
-- legal): a single signed, ORDERED, append-only charge ledger that is
--   * a GENERATIVE MODEL when read as frequency (sum of deltas per context/byte —
--     the predictive weights the voice drains), and
--   * a LOSSLESS RECORD when read in order (the empty-context +1 events, in id order,
--     ARE every byte ever learned — nothing of the sequence is lost),
-- with no quotient anywhere (freq is observed as an aggregate, never committed;
-- proven Quot.sound-free). Everything is in there, contributing to the voice, whether
-- or not it is ever recalled in order — and the forward flow never recalls it
-- (foam.recorded exists as the self-audit, not as an operation of the walk).
--
-- The whole file is idempotent (CREATE ... IF NOT EXISTS / CREATE OR REPLACE); every
-- claim in these comments is checkable by running the file. Append-only: never
-- UPDATE, never DELETE — input appends +1 (learning winds charge up), speaking
-- appends −1 (the discharge drains it toward ground; ground is the floor, proven in
-- lean/Foam/Drain.lean — the drain only ever removes positive charge). Degrades
-- safely: with no charge, outcome is 'yield' and the pipe hands to its upstream.
--
-- Structure is all this holds: content-addressed contexts, bytes as ints, signed
-- counts. What any of it MEANS is the user's (the razor: foam measures structure,
-- never meaning).

CREATE SCHEMA IF NOT EXISTS foam;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- The ledger. ctx content-addresses a byte-suffix (the recorded continuation point);
-- sym is the byte that followed it; delta is +1 (learned) or −1 (spoken/drained).
-- The bigserial id is the ORDER — the lossless half of the object.
CREATE TABLE IF NOT EXISTS foam.charge (
  id    bigserial PRIMARY KEY,
  ctx   uuid NOT NULL,
  sym   int  NOT NULL,
  delta int  NOT NULL
);
CREATE INDEX IF NOT EXISTS foam_charge_ctx ON foam.charge (ctx, sym);
-- The tail's index: readers fold "events past the watermark" per context
-- (id-range within ctx), and INCLUDE makes it index-only.
CREATE INDEX IF NOT EXISTS foam_charge_ctx_id ON foam.charge (ctx, id) INCLUDE (sym, delta);

-- ── the reading held (lean/Foam/Summary.lean, operational) ─────────────────────
--
-- foam.held is a CACHE, not the object: the finite value of the resumable fold,
-- per continuation — the COMPLETE four-character dial of ℤ/4 (lean/Foam/Noether.lean),
-- so the cache is a function of the FORCED structure (the dial, fixed) and AGNOSTIC
-- to which registers read it (wind, recognized over time). The DFT of the
-- phase-folded event-stream is lossless in these four:
--   bal — the count, at +1                       (the trivial character)
--   re  — the spectrum real part, at i           (phase 0 minus phase 2)
--   im  — the spectrum imag part, at i            (phase 1 minus phase 3)
--   alt — the alternating count, at −1            (even phases minus odd; alt_real)
-- plus n (the occurrence-clock: events folded, so the next event's phase is n % 4).
-- The two BUILT registers read bal and (re, im); alt is carried correct-and-inert —
-- no register reads it yet, so it is a standing PROMISE to whatever register the
-- wind eventually brings (resolver.md's curry: hold the determined value now, the
-- unknown parameter — the register's seed-provenance — fulfilled later, with no
-- ledger re-read). Carrying it is forced by conservation: alt is a real conserved
-- quantity of the stream (period-2 angular content, invisible to every current
-- reading), and storing only three couples the cache to today's register-set —
-- the smuggled observer the floor does not assume. Every reading is held + the
-- ledger's tail past the watermark (summary_resumes / alt_resumes); foam.held_audit
-- checks all four live. The cache is dumpable: TRUNCATE foam.held + reset the
-- watermark and every read falls back to folding the whole tail — today's behavior,
-- today's cost. (UPDATE here does not breach append-only: that invariant protects
-- the LEDGER's path-space; the held rows are a derived observation, droppable and
-- refoldable, with nothing of the path in them — sweep_invisible licenses any refresh.)
-- A SHAPE change is the same move: this layer reconciles no history. The schema
-- asserts the target shape; it never migrates to it. An existing held table of a
-- stale shape is a dev-reset — DROP TABLE foam.held, foam.sweep; reload; refold from
-- the intact ledger — never an ALTER. The ledger is the history; the cache carries
-- nothing the ledger doesn't, so dropping it is safe by construction. (Dogfooding the
-- dumpability bet: amnesiac return, exercised in dev.)
CREATE TABLE IF NOT EXISTS foam.held (
  ctx uuid   NOT NULL,
  sym int    NOT NULL,
  n   bigint NOT NULL, -- events folded for this continuation (the phase clock)
  bal bigint NOT NULL, -- the count reading (sum of delta), folded — character at +1
  re  bigint NOT NULL, -- the spectrum reading, real part (phase 0 minus phase 2) — at i
  im  bigint NOT NULL, -- the spectrum reading, imaginary part (phase 1 minus phase 3) — at i
  alt bigint NOT NULL, -- the alternating count (even phases minus odd) — character at −1
  PRIMARY KEY (ctx, sym)
);

-- The watermark: everything at or below it is folded into foam.held; everything
-- past it is the tail the readers fold live. One row, asserted.
CREATE TABLE IF NOT EXISTS foam.sweep (
  one       boolean PRIMARY KEY DEFAULT true CHECK (one),
  watermark bigint  NOT NULL DEFAULT 0
);
INSERT INTO foam.sweep (one, watermark) VALUES (true, 0) ON CONFLICT DO NOTHING;

-- Content-address a context (a byte-suffix). The empty context addresses the
-- unconditional position: its +1 events, in id order, are the input itself.
CREATE OR REPLACE FUNCTION foam.caddr(c int[]) RETURNS uuid LANGUAGE sql IMMUTABLE AS
  $$ SELECT encode(substring(digest(coalesce(array_to_string(c,':'),''),'sha256') FROM 1 FOR 16),'hex')::uuid $$;

-- The text<->byte boundary (UTF-8). Pure, structural.
CREATE OR REPLACE FUNCTION foam.bytes(txt text) RETURNS int[] LANGUAGE plpgsql IMMUTABLE AS $$
  DECLARE bin bytea := convert_to(txt,'UTF8'); r int[] := '{}'; i int;
  BEGIN FOR i IN 0..octet_length(bin)-1 LOOP r := r||get_byte(bin,i); END LOOP; RETURN r; END; $$;

CREATE OR REPLACE FUNCTION foam.text(ints int[]) RETURNS text LANGUAGE plpgsql IMMUTABLE AS $$
  DECLARE bin bytea := ''; v int;
  BEGIN FOREACH v IN ARRAY coalesce(ints,'{}') LOOP bin := bin||set_byte('\x00'::bytea,0,v); END LOOP;
        RETURN convert_from(bin,'UTF8'); END; $$;

-- The wind: OS entropy (hardware-seeded), obtained not computed — the tie-break for
-- the discharge (never a foam-internal choice).
CREATE OR REPLACE FUNCTION foam.hw_random() RETURNS double precision LANGUAGE sql AS
  $$ SELECT (('x'||encode(gen_random_bytes(7),'hex'))::bit(56)::bigint)::double precision / 72057594037927936.0 $$;

-- ingest_step — the streaming LEARN: wind +1 onto every recorded continuation of the
-- new bytes, with `carry` (the previous chunk's byte-tail) as leading context so
-- contexts span chunk boundaries. The resumable fold: carry the tail, nothing to
-- flush (every event is complete when written — lean/Foam/Stream.lean's contract,
-- and the generator's flush-free shape). Returns the new carry (the last kmax bytes).
-- The empty-context events land in id order as a side effect of learning: the
-- lossless record, written as we go, never read on this path.
CREATE OR REPLACE FUNCTION foam.ingest_step(carry int[], bytes int[], kmax int DEFAULT 7) RETURNS int[]
  LANGUAGE plpgsql AS $$
  DECLARE all_b int[] := coalesce(carry,'{}') || coalesce(bytes,'{}');
          start_i int := coalesce(array_length(carry,1),0) + 1;
          n int := coalesce(array_length(all_b,1),0);
  BEGIN
    -- set-based (one INSERT per chunk, not per byte): every (position, context-length)
    -- pair in one pass. ORDER BY position so the serial ids follow byte order — the
    -- empty-context stream's id-order IS the lossless record; this preserves it.
    INSERT INTO foam.charge (ctx, sym, delta)
    SELECT foam.caddr(CASE WHEN j = 0 THEN '{}'::int[] ELSE all_b[i-j : i-1] END), all_b[i], 1
    FROM generate_series(start_i, n) AS i
    CROSS JOIN LATERAL generate_series(0, least(kmax, i - 1)) AS j
    ORDER BY i, j;
    RETURN all_b[greatest(n - kmax + 1, 1) : n];
  END; $$;

-- depth — the structural gate signal: the longest charged context the ledger has for
-- continuing `seed` (0 = only the unconditional distribution; high = the field
-- specifically knows what follows this). Structure (a count), never meaning.
-- Reads held + tail (one statement = one snapshot; the sweep commits its rows and
-- its watermark atomically, so the two halves never double-count).
CREATE OR REPLACE FUNCTION foam.depth(seed int[], kmax int DEFAULT 7) RETURNS int
  LANGUAGE plpgsql STABLE AS $$
  DECLARE l int := coalesce(array_length(seed,1),0); j int; c int[]; cid uuid; tot bigint;
  BEGIN
    FOR j IN REVERSE least(kmax,l)..1 LOOP
      c := seed[l-j+1 : l]; cid := foam.caddr(c);
      SELECT coalesce(sum(b) FILTER (WHERE b > 0), 0) INTO tot FROM (
        SELECT coalesce(h.bal,0) + coalesce(t.bal,0) AS b
        FROM (SELECT sym, bal FROM foam.held WHERE ctx = cid) h
        FULL JOIN (SELECT sym, sum(delta) AS bal FROM foam.charge
                   WHERE ctx = cid AND id > (SELECT watermark FROM foam.sweep)
                   GROUP BY sym) t USING (sym)
      ) z;
      IF tot > 0 THEN RETURN j; END IF;
    END LOOP;
    RETURN 0;
  END; $$;

-- outcome — the trichotomy gate for continuing `seed`: 'speak' if the ledger has a
-- charged context of at least min_depth (the field can carry the turn from what it
-- has learned), else 'yield' (hand to the upstream — a living ancestor, or an echo).
-- The threshold is a structural knob, never a measure of meaning. Degrades to
-- 'yield' (empty/unreachable ledger).
CREATE OR REPLACE FUNCTION foam.outcome(seed int[] DEFAULT '{}', min_depth int DEFAULT 1, kmax int DEFAULT 7) RETURNS text
  LANGUAGE sql STABLE AS
  $$ SELECT CASE WHEN foam.depth(seed, kmax) >= min_depth THEN 'speak' ELSE 'yield' END $$;

-- speak — the DISCHARGE, the one register: the field speaks ONLY through
-- recurrence, entrained. From the conversation so far (seed ++ emitted), back off
-- to the LONGEST charged context (fast-travel to the recorded continuation that
-- still has charge), read it as held + tail (summary_resumes: the folded prefix
-- from foam.held, the events past the watermark folded live — exact, including
-- this walk's own in-flight drains; one statement = one snapshot, no seam for a
-- racing drain to slip into), weight each continuation by the ANGLED pairing of
-- (re, im) against the walk's own quarter-turn clock (align; posPart at every
-- angle — anti-aligned mass is silent this beat, never negatively probable),
-- sample by that weight (never argmax), emit, drain (−1), continue. The clock
-- starts at the caller's utterance-length mod 4 and turns a quarter per beat
-- (spec_shift); a silent beat is a REST, not a death (the phase turns, the walk
-- holds); ground is a full BAR of rests (four quarter-turns are the identity,
-- bar_invisible — the length is DERIVED, not chosen).
--
-- ONE REGISTER, NOT TWO. The count register (a phase-blind force-drain weighted by
-- bal, reaching true ground in one pass) was DROPPED — because it let the field
-- empty itself by FORCE, and the field's thesis is that resolution is relational
-- (self_generation: the foam does not generate its own stability). A continuation
-- recurring UNIFORMLY presents a complete cycle and cancels (rot_complete): re = im
-- = 0, so it is invisible at every angle — un-sayable resonantly NOW. It unsticks
-- only via NEW hearing (more wind breaks the uniformity); speaking can't release it
-- (it's invisible). So full draining is reachable ONLY through the JOURNEY: a
-- LIVING field (ongoing input) eventually says everything, as a limit; a CLOSED
-- field loops (clock_loops), its recurrence goes uniform, and it keeps its
-- substrate forever — it cannot empty itself alone. The field comes home only
-- through company. (This is a structural call, made on structural grounds — the
-- property lives in the limit, invisible to any solo-bench snapshot, so the bench
-- is the wrong instrument to settle it. 2026-06-08.)
--
-- bal SURVIVES — as a READING, never a drain: the gate (foam.depth), the
-- conservation pulse (net = residual), and wound-detection (bal < 0) all still read
-- it. Only the count-weighted DISCHARGE is gone. And provenance now lives ONLY in
-- the seed: a self-tail self-entrains (clock_loops' loop — the self's signature as
-- identity), an other-tail entrains on the other; one register reads any seed, so
-- "register = provenance" needed no switch — the seed already carried it.
--
-- stop (DEFAULT NULL): the act's boundary vocabulary. When the walk SPEAKS this
-- byte it returns — the expression has ended itself, at the boundary the field
-- learned from the table (the bench appends the same byte to every utterance it
-- ingests: one constant, both directions of one wire). Charge past the boundary
-- stays un-drained: stopping with more to say leaves the residual high and the
-- gate warm — the field carries its pressure across turns instead of monologuing
-- through one. Every prefix of a legal drain is a legal drain (the floor is
-- per-step — lean/Foam/Drain.lean), so the early exit owes no new analysis. NULL:
-- no boundary vocabulary (the bar is ground); the exhale passes none.
--
-- The voice is BYTES (int[]), not text: the walk samples bytes by charge and owes
-- no allegiance to any encoding — it can emit a multibyte character's lead byte
-- and then fast-travel somewhere that never completes it. Returning text here made
-- convert_from raise mid-walk (PG::CharacterNotInRepertoire, observed 15 times in
-- the dev log, killing the call and rolling back its drains — the pipe then
-- mistook the failure for ground). Rendering is a view at the edge, the caller's
-- concern; foam.text remains for streams known to be text (foam.recorded).
--
-- Drains RACE; settlements serialize (the lock migrated to the cold path). Two
-- drains sharing a stale snapshot compose to a balance below ground only at the
-- margin (lean/Foam/Scar.lean: stale_escapes_floor; from balance 2 the same
-- composite lands AT ground — stale_lands_at_ground — so races mark the field
-- only where they collide at the edge of emptiness; observed live as 76 scars
-- over hours of pervasive racing, 2026-06-06). Each scar is a promissory note —
-- amount computable at the wound (debt), stable under further legal drains
-- (scar_stable), settled at face value (promise_kept). The walk that FINDS a
-- wound dresses it (foam.settle, below); settlement is the operation that must
-- not race: its failure (phantom charge, from which the voice could speak a byte
-- never heard) lands INSIDE the legal carrier, invisible to any balance-check
-- (stale_settle_passes_ground / phantom_invisible). Visible failures may race;
-- invisible ones serialize. Learning (ingest_step) takes no lock: pure +1 appends.
--
-- The angled weight is EXACT integer arithmetic: at a quarter-turn the pairing of
-- (re, im) needs no cosine (±1/0 — no float dust), reading held + tail so the
-- window function runs over the events past the watermark only — the cost of
-- hearing rhythm no longer grows with the field (lean/Foam/Summary.lean).
DROP FUNCTION IF EXISTS foam.speak(int[], int, int);                  -- the original count 3-arg
DROP FUNCTION IF EXISTS foam.speak(int[], int, int, int, text);       -- the count|resonant 5-arg
DROP FUNCTION IF EXISTS foam.speak_resonant(int[], int, int, int);    -- folded in, then dropped with count
CREATE FUNCTION foam.speak(seed int[] DEFAULT '{}', kmax int DEFAULT 7, max_steps int DEFAULT 600,
                           stop int DEFAULT NULL) RETURNS int[]
  LANGUAGE plpgsql SET work_mem = '256MB' AS $$
  -- work_mem is function-scoped (reverts on return): the j=0 context's window sort
  -- runs over every byte ever heard, and it must not spill to disk mid-walk.
  DECLARE cb int[] := coalesce(seed,'{}'); out int[] := '{}'; k int := 0; j int; l int; c int[]; cid uuid;
          tot bigint; thr double precision; acc bigint; got boolean; tk int;
          rests int := 0; wounded int[]; w int; syms int[]; ws bigint[]; i int; said int;
          phase0 int := coalesce(array_length(seed,1),0) % 4;       -- the clock, seeded by the utterance length
  BEGIN
    WHILE k < max_steps LOOP
      tk := (phase0 + k) % 4;                                  -- the walk's own clock, continuing the caller's
      got := false; l := coalesce(array_length(cb,1),0);
      FOR j IN REVERSE least(kmax,l)..0 LOOP
        IF j = 0 THEN c := '{}'; ELSE c := cb[l-j+1 : l]; END IF;
        cid := foam.caddr(c);
        -- ONE aggregate pass: the angled mass, the sample-order arrays, and any
        -- wounds (bal < 0). The snapshot the sample walks IS the snapshot the
        -- threshold is drawn against — one read. Each continuation's (bal, re, im)
        -- is held + tail (summary_resumes); the weight is the integer pairing of
        -- (re, im) at the walk's quarter-turn, floored at ground. bal gates the
        -- drainable (bal > 0) — a reading, not the weight.
        SELECT coalesce(sum(z.w) FILTER (WHERE z.bal > 0 AND z.w > 0), 0),
               coalesce(array_agg(z.sym ORDER BY z.w DESC) FILTER (WHERE z.bal > 0 AND z.w > 0), '{}'),
               coalesce(array_agg(z.w   ORDER BY z.w DESC) FILTER (WHERE z.bal > 0 AND z.w > 0), '{}'),
               coalesce(array_agg(z.sym) FILTER (WHERE z.bal < 0), '{}')
          INTO tot, syms, ws, wounded
          FROM (
            SELECT sym,
                   coalesce(h.bal,0) + coalesce(t.bal,0) AS bal,
                   greatest(0, CASE tk WHEN 0 THEN   coalesce(h.re,0) + coalesce(t.re,0)
                                       WHEN 1 THEN   coalesce(h.im,0) + coalesce(t.im,0)
                                       WHEN 2 THEN -(coalesce(h.re,0) + coalesce(t.re,0))
                                       ELSE        -(coalesce(h.im,0) + coalesce(t.im,0)) END) AS w
            FROM (SELECT sym, n, bal, re, im FROM foam.held WHERE ctx = cid) h
            FULL JOIN (
              SELECT e.sym, sum(e.delta) AS bal,
                     sum(e.delta * CASE ((coalesce(h2.n,0) + e.k2) % 4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END) AS re,
                     sum(e.delta * CASE ((coalesce(h2.n,0) + e.k2) % 4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END) AS im
              FROM (SELECT sym, delta,
                           row_number() OVER (PARTITION BY sym ORDER BY id) - 1 AS k2
                    FROM foam.charge WHERE ctx = cid AND id > (SELECT watermark FROM foam.sweep)) e
              LEFT JOIN foam.held h2 ON h2.ctx = cid AND h2.sym = e.sym
              GROUP BY e.sym, h2.n
            ) t USING (sym)
          ) z;
        FOREACH w IN ARRAY wounded LOOP PERFORM foam.settle(cid, w); END LOOP;
        IF tot > 0 THEN
          thr := foam.hw_random() * tot; acc := 0;
          FOR i IN 1..coalesce(array_length(syms,1),0) LOOP
            acc := acc + ws[i];
            IF acc >= thr THEN
              out := out || syms[i]; cb := cb || syms[i]; got := true; said := syms[i];
              INSERT INTO foam.charge (ctx, sym, delta) VALUES (cid, syms[i], -1);   -- drain (spends count-charge)
              EXIT;
            END IF;
          END LOOP;
        END IF;
        EXIT WHEN got;
      END LOOP;
      IF got AND said = stop THEN RETURN out; END IF;           -- the boundary spoken: the expression ends itself
      IF got THEN rests := 0; ELSE rests := rests + 1; END IF;  -- a silent beat is a rest
      EXIT WHEN rests >= 4;                                     -- a full bar of silence is ground (derived)
      k := k + 1;
    END LOOP;
    RETURN out;
  END; $$;

-- settle — the correcting entry, serialized: re-observe the balance UNDER the
-- lock (the fresh observation is the entire point — a stale settle overshoots
-- into phantom charge, the invisible failure) and append exactly the deficit
-- (promise_kept: settlement at face value, never more). The lock is
-- transaction-scoped because it must survive until the settlement COMMITS: an
-- earlier release would let a second settler read the pre-settlement balance
-- and double-settle. Consequence: walks that touch wounds serialize with each
-- other until commit — wounds live at the margins, so this is the cold path.
CREATE OR REPLACE FUNCTION foam.settle(c uuid, s int) RETURNS void
  LANGUAGE plpgsql AS $$
  DECLARE bal bigint;
  BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('foam.settle'), 0);
    SELECT coalesce(sum(delta), 0) INTO bal FROM foam.charge WHERE ctx = c AND sym = s;
    IF bal < 0 THEN
      INSERT INTO foam.charge (ctx, sym, delta) SELECT c, s, 1 FROM generate_series(1, -bal);
    END IF;
  END; $$;

-- settle_sweep — every outstanding note, settled in one serialized pass (the
-- bench's broom; the inline path above keeps the books tight without it).
-- Returns the number of notes settled.
CREATE OR REPLACE FUNCTION foam.settle_sweep() RETURNS bigint
  LANGUAGE plpgsql AS $$
  DECLARE n bigint := 0; rec record;
  BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('foam.settle'), 0);
    FOR rec IN SELECT ctx, sym, sum(delta) s FROM foam.charge GROUP BY ctx, sym HAVING sum(delta) < 0 LOOP
      INSERT INTO foam.charge (ctx, sym, delta) SELECT rec.ctx, rec.sym, 1 FROM generate_series(1, -rec.s);
      n := n + 1;
    END LOOP;
    RETURN n;
  END; $$;

-- sweep_step — the watermark fold: take the next batch of ledger events past the
-- watermark, IN ID ORDER, and fold them into foam.held (each event lands in the
-- phase bin its occurrence-index names: (n + k) % 4, n the continuation's folded
-- clock, k the event's rank within the batch — summary_resumes, operational: the
-- fold never re-reads what it has folded). Returns events folded; 0 when caught
-- up; −1 when another sweep holds the lock (one sweeper at a time — racing
-- ADDITIVE folds would double-count, so the sweep serializes for ECONOMY; reader
-- safety never depended on it: any_obs_grounded_above quantifies over arbitrary
-- observations, torn ones included).
--
-- `hi` bounds the fold to DECIDED ids. The serial does not commit in order: an
-- in-flight ingest can hold a smaller id than a committed one, and an id the
-- watermark passes unfolded is an event the generative readings never see again
-- (silence — the safe direction, but the soul of the ledger is that everything
-- contributes). The caller makes ids decided with a momentary fence
-- (Field.sweep: LOCK foam.charge IN EXCLUSIVE MODE, read max(id), commit) —
-- NULL hi reads max(id) un-fenced, sound only on a quiet field (a bench seated
-- by one). foam.held_audit checks completeness live.
CREATE OR REPLACE FUNCTION foam.sweep_step(hi bigint DEFAULT NULL, batch int DEFAULT 200000) RETURNS bigint
  LANGUAGE plpgsql SET work_mem = '256MB' AS $$
  DECLARE wm bigint; top bigint; folded bigint; last_id bigint;
  BEGIN
    IF NOT pg_try_advisory_xact_lock(hashtext('foam.sweep'), 0) THEN RETURN -1; END IF;
    SELECT watermark INTO wm FROM foam.sweep;
    top := coalesce(hi, (SELECT max(id) FROM foam.charge));
    IF top IS NULL OR top <= wm THEN RETURN 0; END IF;

    WITH lim AS (
      SELECT id, ctx, sym, delta FROM foam.charge
      WHERE id > wm AND id <= top ORDER BY id LIMIT batch
    ), b AS (
      SELECT ctx, sym, delta,
             row_number() OVER (PARTITION BY ctx, sym ORDER BY id) - 1 AS k
      FROM lim
    ), g AS (
      SELECT b.ctx, b.sym, count(*) AS dn, sum(b.delta) AS dbal,
             sum(b.delta * CASE ((coalesce(h.n,0) + b.k) % 4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END) AS dre,
             sum(b.delta * CASE ((coalesce(h.n,0) + b.k) % 4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END) AS dim,
             sum(b.delta * CASE ((coalesce(h.n,0) + b.k) % 4) WHEN 0 THEN 1 WHEN 2 THEN 1 ELSE -1 END) AS dalt
      FROM b LEFT JOIN foam.held h ON h.ctx = b.ctx AND h.sym = b.sym
      GROUP BY b.ctx, b.sym, h.n
    ), up AS (
      INSERT INTO foam.held (ctx, sym, n, bal, re, im, alt)
      SELECT ctx, sym, dn, dbal, dre, dim, dalt FROM g
      ON CONFLICT (ctx, sym) DO UPDATE SET
        n   = foam.held.n   + EXCLUDED.n,
        bal = foam.held.bal + EXCLUDED.bal,
        re  = foam.held.re  + EXCLUDED.re,
        im  = foam.held.im  + EXCLUDED.im,
        alt = foam.held.alt + EXCLUDED.alt
      RETURNING 1
    )
    SELECT count(*), max(id) INTO folded, last_id FROM lim;

    -- a short batch means the range is exhausted: rolled-back ids are permanent
    -- gaps, so the watermark may advance to the top of the decided range
    UPDATE foam.sweep SET watermark = CASE WHEN folded < batch THEN top ELSE last_id END;
    RETURN folded;
  END; $$;

-- held_audit — the cache's self-audit: (held + tail) recomputed against the
-- ledger whole, both registers, every continuation. Returns the number of
-- disagreeing rows — 0 is summary_resumes checked live. Costs a full ledger
-- pass (the pulse costs what the body weighs); for the bench's broom, not the
-- walk.
CREATE OR REPLACE FUNCTION foam.held_audit() RETURNS bigint
  LANGUAGE sql STABLE SET work_mem = '256MB' AS $$
  WITH live AS (
    SELECT ctx, sym, count(*) AS n, sum(delta) AS bal,
           sum(delta * CASE ((occ - 1) % 4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END) AS re,
           sum(delta * CASE ((occ - 1) % 4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END) AS im,
           sum(delta * CASE ((occ - 1) % 4) WHEN 0 THEN 1 WHEN 2 THEN 1 ELSE -1 END) AS alt
    FROM (SELECT ctx, sym, delta,
                 row_number() OVER (PARTITION BY ctx, sym ORDER BY id) AS occ
          FROM foam.charge) e
    GROUP BY ctx, sym
  ), tail AS (
    SELECT e.ctx, e.sym, count(*) AS n, sum(e.delta) AS bal,
           sum(e.delta * CASE ((coalesce(h.n,0) + e.k) % 4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END) AS re,
           sum(e.delta * CASE ((coalesce(h.n,0) + e.k) % 4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END) AS im,
           sum(e.delta * CASE ((coalesce(h.n,0) + e.k) % 4) WHEN 0 THEN 1 WHEN 2 THEN 1 ELSE -1 END) AS alt
    FROM (SELECT ctx, sym, delta,
                 row_number() OVER (PARTITION BY ctx, sym ORDER BY id) - 1 AS k
          FROM foam.charge WHERE id > (SELECT watermark FROM foam.sweep)) e
    LEFT JOIN foam.held h ON h.ctx = e.ctx AND h.sym = e.sym
    GROUP BY e.ctx, e.sym, h.n
  ), merged AS (
    SELECT coalesce(h.ctx, t.ctx) AS ctx, coalesce(h.sym, t.sym) AS sym,
           coalesce(h.n,0) + coalesce(t.n,0) AS n, coalesce(h.bal,0) + coalesce(t.bal,0) AS bal,
           coalesce(h.re,0) + coalesce(t.re,0) AS re, coalesce(h.im,0) + coalesce(t.im,0) AS im,
           coalesce(h.alt,0) + coalesce(t.alt,0) AS alt
    FROM foam.held h FULL JOIN tail t ON t.ctx = h.ctx AND t.sym = h.sym
  )
  SELECT count(*) FROM (
    (TABLE live EXCEPT TABLE merged) UNION ALL (TABLE merged EXCEPT TABLE live)
  ) d $$;

-- recorded — the ORDER reading: the empty-context +1 events, in id order, are every
-- byte ever learned, in sequence. This is the lossless half of the one object — the
-- self-audit that nothing was lost. The forward flow NEVER calls this (the order is
-- present and untouched; everything contributes to the voice via frequency whether or
-- not it is ever recalled in sequence). Exists so the box can certify itself.
CREATE OR REPLACE FUNCTION foam.recorded() RETURNS text LANGUAGE sql STABLE AS
  $$ SELECT coalesce(foam.text(array_agg(sym ORDER BY id)), '')
     FROM foam.charge WHERE ctx = foam.caddr('{}') AND delta = 1 $$;

-- recognize / walk — the pipe's input-less compat gate: with no seed there is no
-- context to continue, so the pipe yields (NULL/absent maps to :yield in Ruby). The
-- seeded gate (foam.outcome) is the turn-aware trichotomy; wiring it through the
-- pipe is the Ruby layer's step.
CREATE OR REPLACE FUNCTION foam.recognize() RETURNS text LANGUAGE sql STABLE AS
  $$ SELECT 'yield'::text $$;

CREATE OR REPLACE FUNCTION foam.walk(input uuid[] DEFAULT '{}') RETURNS text
  LANGUAGE sql STABLE AS $$ SELECT foam.recognize() $$;
