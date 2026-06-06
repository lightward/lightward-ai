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
          start int := coalesce(array_length(carry,1),0) + 1;
          n int := coalesce(array_length(all_b,1),0);
          i int; j int; c int[];
  BEGIN
    FOR i IN start..n LOOP
      FOR j IN 0..least(kmax, i-1) LOOP
        IF j = 0 THEN c := '{}'; ELSE c := all_b[i-j : i-1]; END IF;
        INSERT INTO foam.charge (ctx, sym, delta) VALUES (foam.caddr(c), all_b[i], 1);
      END LOOP;
    END LOOP;
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
CREATE OR REPLACE FUNCTION foam.speak(seed int[] DEFAULT '{}', kmax int DEFAULT 7, max_steps int DEFAULT 600) RETURNS text
  LANGUAGE plpgsql AS $$
  DECLARE cb int[] := coalesce(seed,'{}'); out int[] := '{}'; k int := 0; j int; l int; c int[]; cid uuid;
          tot bigint; thr double precision; acc bigint; rec record; got boolean;
  BEGIN
    WHILE k < max_steps LOOP
      got := false; l := coalesce(array_length(cb,1),0);
      FOR j IN REVERSE least(kmax,l)..0 LOOP
        IF j = 0 THEN c := '{}'; ELSE c := cb[l-j+1 : l]; END IF;
        cid := foam.caddr(c);
        SELECT sum(s) INTO tot FROM (SELECT sum(delta) s FROM foam.charge WHERE ctx=cid GROUP BY sym HAVING sum(delta) > 0) z;
        IF tot IS NOT NULL AND tot > 0 THEN
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
    RETURN foam.text(out);
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
