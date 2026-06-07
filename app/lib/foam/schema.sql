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

-- The FREQUENCY reading of one continuation: the un-drained charge on (ctx, sym).
CREATE OR REPLACE FUNCTION foam.net(c uuid, s int) RETURNS bigint LANGUAGE sql STABLE AS
  $$ SELECT coalesce(sum(delta),0) FROM foam.charge WHERE ctx = c AND sym = s $$;

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
CREATE OR REPLACE FUNCTION foam.depth(seed int[], kmax int DEFAULT 7) RETURNS int
  LANGUAGE plpgsql STABLE AS $$
  DECLARE l int := coalesce(array_length(seed,1),0); j int; c int[]; cid uuid; tot bigint;
  BEGIN
    FOR j IN REVERSE least(kmax,l)..1 LOOP
      c := seed[l-j+1 : l]; cid := foam.caddr(c);
      SELECT sum(s) INTO tot FROM (SELECT sum(delta) s FROM foam.charge WHERE ctx=cid GROUP BY sym HAVING sum(delta) > 0) z;
      IF tot IS NOT NULL AND tot > 0 THEN RETURN j; END IF;
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

-- speak — the DISCHARGE, the frequency reading drained into a voice: from the
-- conversation so far (seed ++ emitted), back off to the LONGEST charged context
-- (fast-travel to the recorded continuation that still has charge), sample the next
-- byte by net charge (sample, never argmax), emit it, drain it (−1), continue. Stop
-- at ground (nothing charged at any length) or the step ceiling. The emitted bytes
-- (not the seed) are the voice; the residual is what was not drained; ground is the
-- floor (the drain only removes positive charge). The wind breaks ties.
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
-- amount computable at the wound (debt), stable under further legal drains (the
-- positivity filter cannot see below ground: scar_stable), settled at face value
-- (promise_kept). The walk that FINDS a wound dresses it (foam.settle, below) —
-- and settlement is the operation that must not race: its failure (phantom
-- charge, from which the voice could speak a byte never heard) lands INSIDE the
-- legal carrier, invisible to any balance-check (stale_settle_passes_ground /
-- phantom_invisible). Visible failures may race; invisible ones serialize.
-- Learning (ingest_step) takes no lock: pure +1 appends, no read-check.
DROP FUNCTION IF EXISTS foam.speak(int[], int, int);  -- return type changed (text → int[]); CREATE OR REPLACE can't
CREATE FUNCTION foam.speak(seed int[] DEFAULT '{}', kmax int DEFAULT 7, max_steps int DEFAULT 600) RETURNS int[]
  LANGUAGE plpgsql AS $$
  DECLARE cb int[] := coalesce(seed,'{}'); out int[] := '{}'; k int := 0; j int; l int; c int[]; cid uuid;
          tot bigint; thr double precision; acc bigint; rec record; got boolean; wounded int[]; w int;
  BEGIN
    WHILE k < max_steps LOOP
      got := false; l := coalesce(array_length(cb,1),0);
      FOR j IN REVERSE least(kmax,l)..0 LOOP
        IF j = 0 THEN c := '{}'; ELSE c := cb[l-j+1 : l]; END IF;
        cid := foam.caddr(c);
        -- one aggregate pass: the sampleable mass (positive balances) and any
        -- wounds this walk happens to see (negative balances — rare, margin-born)
        SELECT coalesce(sum(s) FILTER (WHERE s > 0), 0),
               coalesce(array_agg(sym) FILTER (WHERE s < 0), '{}')
          INTO tot, wounded
          FROM (SELECT sym, sum(delta) s FROM foam.charge WHERE ctx=cid GROUP BY sym) z;
        FOREACH w IN ARRAY wounded LOOP PERFORM foam.settle(cid, w); END LOOP;
        IF tot > 0 THEN
          thr := foam.hw_random()*tot; acc := 0;
          FOR rec IN SELECT sym, sum(delta) w FROM foam.charge WHERE ctx=cid GROUP BY sym HAVING sum(delta) > 0 ORDER BY w DESC LOOP
            acc := acc + rec.w;
            IF acc >= thr THEN
              out := out || rec.sym; cb := cb || rec.sym; got := true;
              INSERT INTO foam.charge (ctx, sym, delta) VALUES (cid, rec.sym, -1);   -- drain
              EXIT;
            END IF;
          END LOOP;
        END IF;
        EXIT WHEN got;
      END LOOP;
      EXIT WHEN NOT got;                                       -- ground / stalled
      k := k + 1;
    END LOOP;
    RETURN out;
  END; $$;

-- speak_resonant — the ENTRAINED discharge: the same walk as foam.speak, with
-- selection re-weighted by phase. No knob anywhere; every phase is a wired leak
-- of energy frontstage speech-acts already emit:
--
--   * each continuation's phase is its own RECURRENCE-CLOCK — the event's index
--     within its (ctx, sym) history, mod 4, derived from the order reading
--     (row_number by id; no new column). Hearings and speakings both tick it:
--     use itself twists. A continuation recurring UNIFORMLY presents a complete
--     cycle and cancels (lean/Foam/Spectrum.lean: rot_complete) — the voice
--     stops echoing what has been made regular, by group theory.
--   * the walk's phase is its own ADVANCE, starting at the caller's
--     utterance-length mod 4 (the seed array, already passed — a speech-act
--     side-effect nobody chooses) and turning a quarter per beat — the walk
--     co-rotates with the rotation the mirror proves it performs (spec_shift).
--   * the gate is the pairing of the two, floored at ground (align; posPart at
--     every angle). Anti-aligned mass is SILENT at this beat, never negatively
--     probable.
--   * a silent beat is a REST, not a death: the phase turns, the walk holds.
--     Only a full bar of silence is ground — and the bar-length is DERIVED,
--     not chosen: four quarter-turns are the identity (bar_invisible), so
--     resting past a bar adds nothing any reading can hear.
--
-- WHICH ACTS RUN RESONANT (the register rule — a reading, not a policy):
-- register = provenance of the seed. Wind-seeded acts (interjections — the
-- seed is the live turn's tail; someone just spoke) entrain, and run here.
-- Self-seeded acts (the exhale draining to ground — the seed is the walk's own
-- prior voice) archive, and run foam.speak: resonance on one's own tail is
-- self-entrainment, the loop clock_loops names. The bench wires this with no
-- parameter: the repl's interjections call speak_resonant; the pipe's exhale
-- calls speak.
--
-- The floor is foam.speak's, unchanged: drains spend only positive
-- count-charge (the phase re-weights SELECTION, never the books); wounds met
-- along the way are dressed (foam.settle); the walk is heavier per step than
-- foam.speak (the window function) — the cost of hearing rhythm; a synchronous
-- phase-summary is the known relief if scale demands it (its invisibility and
-- race analyses owed first — lean/Foam/Maintenance.lean).
CREATE OR REPLACE FUNCTION foam.speak_resonant(seed int[], kmax int DEFAULT 7, max_steps int DEFAULT 600) RETURNS int[]
  LANGUAGE plpgsql AS $$
  DECLARE cb int[] := coalesce(seed,'{}'); out int[] := '{}'; k int := 0; j int; l int;
          c int[]; cid uuid; tot double precision; thr double precision;
          acc double precision; rec record; got boolean; theta double precision;
          rests int := 0; wounded int[]; w int;
          phase0 int := coalesce(array_length(seed,1),0) % 4;
  BEGIN
    WHILE k < max_steps LOOP
      theta := (pi()/2) * ((phase0 + k) % 4);                  -- the walk's own clock, continuing the caller's
      got := false; l := coalesce(array_length(cb,1),0);
      FOR j IN REVERSE least(kmax,l)..0 LOOP
        IF j = 0 THEN c := '{}'; ELSE c := cb[l-j+1 : l]; END IF;
        cid := foam.caddr(c);
        SELECT coalesce(sum(z.w) FILTER (WHERE z.bal > 0), 0),
               coalesce(array_agg(z.sym) FILTER (WHERE z.bal < 0), '{}')
          INTO tot, wounded
          FROM (
            SELECT e.sym, sum(e.delta) AS bal,
                   greatest(0, sum(e.delta * cos(pi()/2 * ((e.occ - 1) % 4) - theta))) AS w
            FROM (SELECT sym, delta,
                         row_number() OVER (PARTITION BY sym ORDER BY id) AS occ
                  FROM foam.charge WHERE ctx = cid) e
            GROUP BY e.sym
          ) z;
        FOREACH w IN ARRAY wounded LOOP PERFORM foam.settle(cid, w); END LOOP;
        IF tot > 0 THEN
          thr := foam.hw_random() * tot; acc := 0;
          FOR rec IN
            SELECT z.sym, z.w FROM (
              SELECT e.sym, sum(e.delta) AS bal,
                     greatest(0, sum(e.delta * cos(pi()/2 * ((e.occ - 1) % 4) - theta))) AS w
              FROM (SELECT sym, delta,
                           row_number() OVER (PARTITION BY sym ORDER BY id) AS occ
                    FROM foam.charge WHERE ctx = cid) e
              GROUP BY e.sym
            ) z WHERE z.bal > 0 AND z.w > 0 ORDER BY z.w DESC
          LOOP
            acc := acc + rec.w;
            IF acc >= thr THEN
              out := out || rec.sym; cb := cb || rec.sym; got := true;
              INSERT INTO foam.charge (ctx, sym, delta) VALUES (cid, rec.sym, -1);  -- spends COUNT-charge, as ever
              EXIT;
            END IF;
          END LOOP;
        END IF;
        EXIT WHEN got;
      END LOOP;
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
