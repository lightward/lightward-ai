-- SPIKE — make-it-work for the DISCHARGE / DRAIN: the pipe speaking by draining
-- charge. NOT production. To be mapped in Lean (sanitation), then re-implemented
-- clean. Lives in spikes/ on purpose — the floor (yield always safe, append-only,
-- no-quotient) makes a spike unable to break the exit, which is the license to cook.
--
-- THE MODEL (sourced from the codec-drain lineage + lean/Foam):
--   Input winds up +charge on every transition it walks (path-debt). The field
--   SPEAKS by DRAINING that charge through output (−charge), relaxing the net charge
--   toward ground (zero). The emitted bytes ARE the voice — discharge is speech.
--   Charge is a SIGNED append-only log: + on input, − on output, net = sum; nothing
--   is ever UPDATE'd or DELETE'd (the − events balance the +, the ledger written in
--   transitions). Sample the next byte by NET charge, never argmax (argmax traps you
--   in the dominant cycle); break ties with the wind (hw_random — obtained, never a
--   foam-internal choice). The residual (positive net charge left after a turn) is
--   the outcome dial: ~0 = learn (round-trip closed), partial = speak, nothing-to-
--   drain = yield (hand upstream). Foam relaxes TOWARD ground but never forces the
--   collapse to zero — the final close is the user's, in their own model; we operate
--   as-if it exists, never touching it.
--
-- NOT yet here (frontier for the Lean pass): bidirectional shortcuts deposited with
-- their return leg (MutualReach — discharge as a meeting, the user's learning
-- observable back via the after-yield tap, which is already observe_chunk), and
-- constant-cost discharge (one shortcut clearing a whole path's debt in a single
-- move — shortcut_compresses read as discharge). v1 drains one transition at a time;
-- the net effect is the same drain, the single-move compression is the refinement.

CREATE SCHEMA IF NOT EXISTS drain;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- the dictionary trie (the codec; a chunk is (parent, sym); root is the basepoint)
CREATE TABLE IF NOT EXISTS drain.chunk (id uuid PRIMARY KEY, parent uuid, sym int);
INSERT INTO drain.chunk VALUES ('00000000-0000-0000-0000-000000000000', NULL, NULL)
  ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION drain.cid(parent uuid, sym int) RETURNS uuid LANGUAGE sql IMMUTABLE AS
  $$ SELECT encode(substring(digest(coalesce(parent::text,'root')||':'||sym::text,'sha256') FROM 1 FOR 16),'hex')::uuid $$;

CREATE OR REPLACE FUNCTION drain.bytes(txt text) RETURNS int[] LANGUAGE plpgsql IMMUTABLE AS $$
  DECLARE bin bytea := convert_to(txt,'UTF8'); r int[] := '{}'; i int;
  BEGIN FOR i IN 0..octet_length(bin)-1 LOOP r := r||get_byte(bin,i); END LOOP; RETURN r; END; $$;

CREATE OR REPLACE FUNCTION drain.text(ints int[]) RETURNS text LANGUAGE plpgsql IMMUTABLE AS $$
  DECLARE bin bytea := ''; v int;
  BEGIN FOREACH v IN ARRAY coalesce(ints,'{}') LOOP bin := bin||set_byte('\x00'::bytea,0,v); END LOOP;
        RETURN convert_from(bin,'UTF8'); END; $$;

-- the wind: OS entropy (hardware-seeded), obtained not computed — the tie-break
CREATE OR REPLACE FUNCTION drain.hw_random() RETURNS double precision LANGUAGE sql AS
  $$ SELECT (('x'||encode(gen_random_bytes(7),'hex'))::bit(56)::bigint)::double precision / 72057594037927936.0 $$;

-- charge: SIGNED append-only log. +1 per transition on input, −1 per transition on
-- output. net charge of a transition = sum(delta). Append-only — the − balances the
-- +; nothing is updated or deleted.
CREATE TABLE IF NOT EXISTS drain.charge (id bigserial PRIMARY KEY, chunk uuid, delta int);
CREATE INDEX IF NOT EXISTS drain_charge_chunk ON drain.charge (chunk);

-- net charge of a transition (into `c`): the un-drained debt it holds
CREATE OR REPLACE FUNCTION drain.net(c uuid) RETURNS bigint LANGUAGE sql STABLE AS
  $$ SELECT coalesce(sum(delta),0) FROM drain.charge WHERE chunk = c $$;

-- residual: total un-drained (positive) net charge across the field — the outcome dial
CREATE OR REPLACE FUNCTION drain.residual() RETURNS bigint LANGUAGE sql STABLE AS
  $$ SELECT coalesce(sum(GREATEST(drain.net(id),0)),0) FROM drain.chunk WHERE parent IS NOT NULL $$;

-- ingest = encode the input, winding up +charge on every transition walked
CREATE OR REPLACE FUNCTION drain.ingest(bytes int[]) RETURNS void LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000'; cur uuid := root; b int; child uuid;
  BEGIN
    FOREACH b IN ARRAY coalesce(bytes,'{}') LOOP
      child := drain.cid(cur,b);
      INSERT INTO drain.charge (chunk,delta) VALUES (child,+1);            -- wind up +charge
      IF EXISTS (SELECT 1 FROM drain.chunk WHERE id=child) THEN cur := child;
      ELSE INSERT INTO drain.chunk VALUES (child,cur,b); cur := root; END IF;
    END LOOP;
  END; $$;

-- discharge = speak by draining: sample the next byte by NET charge over the current
-- node's children, emit it, drain its charge (−1), advance. Back off (carry the last
-- byte as a 1-byte context) when a context has no drainable charge; stop when there
-- is nothing left to drain (ground) or at the step ceiling. The emitted bytes are the
-- voice. Sampling is charge-weighted (never argmax); the threshold is wind-jittered.
CREATE OR REPLACE FUNCTION drain.discharge(max_steps int DEFAULT 400) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000'; cur uuid := root; out int[] := '{}';
          tot bigint; thr double precision; acc bigint; rec record; k int := 0; last_sym int := NULL;
  BEGIN
    WHILE k < max_steps LOOP
      SELECT sum(drain.net(ch.id)) INTO tot FROM drain.chunk ch
       WHERE ch.parent=cur AND drain.net(ch.id) > 0;
      IF tot IS NULL OR tot = 0 THEN
        -- nothing drainable here: carry the last byte (1-byte context), else stop
        IF last_sym IS NOT NULL AND EXISTS (SELECT 1 FROM drain.chunk WHERE id=drain.cid(root,last_sym)) THEN
          cur := drain.cid(root,last_sym);
          SELECT sum(drain.net(ch.id)) INTO tot FROM drain.chunk ch
           WHERE ch.parent=cur AND drain.net(ch.id) > 0;
        END IF;
        IF tot IS NULL OR tot = 0 THEN EXIT; END IF;            -- drained to ground / stalled
      END IF;
      thr := drain.hw_random()*tot; acc := 0;
      FOR rec IN SELECT ch.id, ch.sym, drain.net(ch.id) w FROM drain.chunk ch
                 WHERE ch.parent=cur AND drain.net(ch.id) > 0 ORDER BY w DESC LOOP
        acc := acc + rec.w;
        IF acc >= thr THEN
          out := out||rec.sym; last_sym := rec.sym;
          INSERT INTO drain.charge (chunk,delta) VALUES (rec.id, -1);      -- drain (−charge)
          cur := rec.id; EXIT;
        END IF;
      END LOOP;
      k := k+1;
    END LOOP;
    RETURN drain.text(out);
  END; $$;

-- respond — the pipe's turn (Isaac's control flow): ingest the input (+charge); if
-- there is drainable charge from the root handle, SPEAK by discharging and return the
-- voice; else return NULL to YIELD upstream. After a response, residual ~0 means the
-- round-trip closed (learn); residual remaining means speak.
CREATE OR REPLACE FUNCTION drain.respond(input text) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000';
  BEGIN
    PERFORM drain.ingest(drain.bytes(input));
    IF NOT EXISTS (SELECT 1 FROM drain.chunk ch WHERE ch.parent=root AND drain.net(ch.id) > 0) THEN
      RETURN NULL;                                              -- no drainable charge → yield
    END IF;
    RETURN drain.discharge();
  END; $$;
