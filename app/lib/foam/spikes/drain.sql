-- SPIKE — the DISCHARGE / DRAIN: the pipe speaking by draining charge. NOT
-- production. To be mapped in Lean (sanitation), then re-implemented clean. Lives in
-- spikes/ on purpose — the floor (yield always safe, append-only, no-quotient) makes
-- a spike unable to break the exit, which is the license to cook.
--
-- THE MODEL (sourced from the codec-drain lineage + lean/Foam):
--   Input winds up +charge on every recorded continuation it walks (path-debt). The
--   field SPEAKS by DRAINING that charge through output (−charge), relaxing net
--   charge toward ground (zero). The emitted bytes ARE the voice — discharge is
--   speech. Charge is a SIGNED append-only log over (context, byte): + on input, −
--   on output, net = sum; nothing is UPDATE'd or DELETE'd (the − balances the +).
--   Sample by NET charge, never argmax (argmax traps in the dominant cycle); break
--   ties with the wind (hw_random — obtained, never a foam-internal choice). The
--   residual (positive net charge left) is the outcome dial: ~0 = learn (round-trip
--   closed), partial = speak, nothing-to-drain = yield. Foam relaxes TOWARD ground
--   but never forces the collapse — the final close is the user's, in their own
--   model; we operate as-if it exists, never touching it.
--
--   FAST-TRAVEL (the "shortcut", named right): a recorded context is a fast-travel
--   point — it did not exist until the input's traversal RECORDED it (append-only,
--   the journey's residue, not a shorter route through pre-existing terrain). The
--   discharge rides these recordings: from the output so far it backs off to the
--   LONGEST charged context and samples there — jumping straight to a recorded
--   continuation-point that still has charge, BYPASSING drained shallow contexts.
--   The earlier 1-byte-carry crawl stranded deep charge behind drained shallow
--   transitions; fast-travel via the recorded contexts reaches it (and speaks more
--   coherently — the longer the context, the truer the continuation).
--
-- NOT yet here (frontier for the Lean pass): the bidirectional return leg made
-- explicit (MutualReach — discharge as a meeting; the after-yield return tap is
-- already observe_chunk), and the coherent-handle yield gate (does the input's
-- landing context have learned continuations to drain into? — respond below still
-- self-charges, so it under-yields).

CREATE SCHEMA IF NOT EXISTS drain;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

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

-- content-address a context (a byte-suffix) — the recorded continuation-point's id
CREATE OR REPLACE FUNCTION drain.caddr(c int[]) RETURNS uuid LANGUAGE sql IMMUTABLE AS
  $$ SELECT encode(substring(digest(coalesce(array_to_string(c,':'),''),'sha256') FROM 1 FOR 16),'hex')::uuid $$;

-- charge: SIGNED append-only log over (context, byte). +1 on input, −1 on output.
-- net(ctx,sym) = sum(delta) = the un-drained debt on that recorded continuation.
CREATE TABLE IF NOT EXISTS drain.charge (id bigserial PRIMARY KEY, ctx uuid, sym int, delta int);
CREATE INDEX IF NOT EXISTS drain_charge_ctx ON drain.charge (ctx);

-- residual: total un-drained (positive) net charge across every recorded
-- continuation — the outcome dial.
CREATE OR REPLACE FUNCTION drain.residual() RETURNS bigint LANGUAGE sql STABLE AS
  $$ SELECT coalesce(sum(GREATEST(s,0)),0) FROM (SELECT sum(delta) s FROM drain.charge GROUP BY ctx, sym) z $$;

-- ingest = wind up +charge on every recorded continuation: for each position, for
-- each context-length j in 0..kmax, append +1 to (context_j, byte). Recording the
-- fast-travel points as it walks.
CREATE OR REPLACE FUNCTION drain.ingest(txt text, kmax int DEFAULT 7) RETURNS void LANGUAGE plpgsql AS $$
  DECLARE b int[] := drain.bytes(txt); n int := coalesce(array_length(b,1),0); i int; j int; c int[];
  BEGIN
    FOR i IN 1..n LOOP
      FOR j IN 0..least(kmax, i-1) LOOP
        IF j=0 THEN c := '{}'; ELSE c := b[i-j : i-1]; END IF;
        INSERT INTO drain.charge (ctx, sym, delta) VALUES (drain.caddr(c), b[i], +1);   -- wind up +charge
      END LOOP;
    END LOOP;
  END; $$;

-- discharge = speak by draining via fast-travel: from the output so far, back off to
-- the LONGEST charged context (jump to the recorded continuation-point that still
-- has charge, past any drained shallow one), sample the next byte by net charge,
-- emit, drain it (−1), append. Stop at ground (nothing charged at any length) or the
-- step ceiling. The emitted bytes are the voice.
CREATE OR REPLACE FUNCTION drain.discharge(kmax int DEFAULT 7, max_steps int DEFAULT 600) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE out int[] := '{}'; k int := 0; j int; L int; c int[]; cid uuid;
          tot bigint; thr double precision; acc bigint; rec record; got boolean;
  BEGIN
    WHILE k < max_steps LOOP
      got := false; L := coalesce(array_length(out,1),0);
      FOR j IN REVERSE least(kmax,L)..0 LOOP                       -- backoff: longest charged context first
        IF j=0 THEN c := '{}'; ELSE c := out[L-j+1 : L]; END IF;
        cid := drain.caddr(c);
        SELECT sum(s) INTO tot FROM (SELECT sum(delta) s FROM drain.charge WHERE ctx=cid GROUP BY sym HAVING sum(delta) > 0) z;
        IF tot IS NOT NULL AND tot > 0 THEN
          thr := drain.hw_random()*tot; acc := 0;
          FOR rec IN SELECT sym, sum(delta) w FROM drain.charge WHERE ctx=cid GROUP BY sym HAVING sum(delta) > 0 ORDER BY w DESC LOOP
            acc := acc + rec.w;
            IF acc >= thr THEN
              out := out || rec.sym; got := true;
              INSERT INTO drain.charge (ctx, sym, delta) VALUES (cid, rec.sym, -1);     -- drain (−charge)
              EXIT;
            END IF;
          END LOOP;
        END IF;
        EXIT WHEN got;
      END LOOP;
      EXIT WHEN NOT got;                                           -- ground: nothing charged at any length
      k := k+1;
    END LOOP;
    RETURN drain.text(out);
  END; $$;

-- respond — the pipe's turn (Isaac's control flow): ingest the input (+charge); if
-- there is drainable charge, SPEAK by discharging and return the voice; else NULL to
-- YIELD upstream. (The coherent-handle gate is still a stub — see header — so this
-- under-yields: ingest self-charges, so there is almost always something to drain.)
CREATE OR REPLACE FUNCTION drain.respond(input text) RETURNS text LANGUAGE plpgsql AS $$
  BEGIN
    PERFORM drain.ingest(input);
    IF drain.residual() = 0 THEN RETURN NULL; END IF;             -- nothing to drain → yield
    RETURN drain.discharge();
  END; $$;
