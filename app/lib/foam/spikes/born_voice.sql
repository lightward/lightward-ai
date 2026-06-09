-- SPIKE — the DARK FRINGE in the live voice: voice-via-Born genuinely interferes.
-- NOT production. Honest make-it-work record (radio.sql's precedent). This validates,
-- at its own seam, the discharge that landed in foam.speak (schema.sql lines 281-283):
-- the voice weights each continuation by the BORN measurement — the SQUARED recency-
-- pairing against the walk's clock, |⟨tk|recency⟩|² = (align tk z)² — not a rectified
-- count. The claim under test: a Born voice can make a ZERO where the count register
-- makes a one. A count table cannot (positive counts never sum to zero); only a
-- genuine interfering measurement cancels. This file instruments BOTH readings of the
-- one ledger and shows them disagree — and the voice follows Born.
--
-- THE INSTRUMENT (foam.born_breakdown). Per continuation of a context, expose the
-- count (bal) AND the Born weight at even/odd clock phase. The recency math is copied
-- verbatim from foam.speak (recency = rot^((N−1)%4)·conj(abs), Chirality.lean's
-- specR_bridge; the squared pairing, Born.lean). No sampling — exact integer
-- arithmetic, a direct readout of the discharge's own weights.
--
-- WHAT IT SHOWS (run foam.born_voice_demo()):
--   1. THE ZERO. context a→Z four times (a complete ℤ/4 cycle, rot_complete). The
--      recency spectrum sums to (0,0): born = 0 at EVERY clock phase, while count
--      bal = 4. The count gate (foam.depth, reads bal) is OPEN — it says "the field
--      can carry the turn." The Born voice (foam.speak) emits ZERO bytes. The voice
--      makes a zero where count makes a four, on the same ledger. (bar_invisible /
--      rot_complete: a complete cycle is invisible to the spectrum, hence to Born.)
--   2. THE LIFT. Hear ONE more aZ (N=4→5): the cycle is broken, born goes nonzero,
--      the voice turns ON. Count-gate unchanged at 1 throughout — blind to the whole
--      event. The fringe lifts only through NEW hearing (self_generation: the field
--      cannot unstick what it cannot see; speaking can't release a complete cycle).
--   3. THE INTERFERENCE (basis-dependence). context b→Y three times: the SAME
--      continuation, the SAME count (bal = 3), reads DARK at even clock-phase
--      (born 0) and BRIGHT at odd (born 1). Count is phase-flat; Born is not. The
--      basis-dependence IS interference — the signature of a real quantum measurement,
--      not a suppression heuristic.
--
-- WHY IT'S TRUSTWORTHY (the controls, learned the hard way on rosetta.sql): the
-- silence is not a dead field (the same field, +1 byte, speaks 26); the mechanism is
-- exposed (born 0 because recency = (0,0), not because bal = 0); the gate is open
-- (depth ≥ 1, charge present). It is a direct behavioral readout of the actual
-- discharge, exact arithmetic, with its own bright control — no sampled statistic to
-- fool us.
--
-- SCOPE (watching the layer-conflation): this is the n=1 ROOT — the voice is a
-- genuine Born measurement (it cancels, basis-dependently). It is NOT yet the
-- ψ-ontology claim (PBR): that is the n=2 lift (the anti-distinguisher — point this
-- same cancellation at two forms in an unseen basis), and it now has a proven
-- interference floor to stand on. The fringe here is a CONSTRUCTED witness (like
-- born.sql's double-slit); the wild-caught version is the anti-parroting already on
-- the dev field. Mirror: Born.lean (double_slit, born_parseval), Spectrum.lean /
-- Noether.lean (rot_complete, bar_invisible — the complete cycle is the dark fringe).

CREATE OR REPLACE FUNCTION foam.born_breakdown(ctxbytes int[])
  RETURNS TABLE (sym int, count_bal bigint, rec_re bigint, rec_im bigint, born_even bigint, born_odd bigint)
  LANGUAGE sql STABLE AS $$
    WITH absf AS (
      SELECT z.sym,
             coalesce(h.bal,0)+coalesce(z.bal,0) AS bal,
             coalesce(h.re,0) +coalesce(z.re,0)  AS re,
             coalesce(h.im,0) +coalesce(z.im,0)  AS im,
             coalesce(h.n,0)  +coalesce(z.tn,0)  AS nn
      FROM (SELECT e.sym, count(*) tn, sum(e.delta) bal,
                   sum(e.delta*CASE ((coalesce(h2.n,0)+e.k2)%4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END) re,
                   sum(e.delta*CASE ((coalesce(h2.n,0)+e.k2)%4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END) im
            FROM (SELECT sym, delta, row_number() OVER (PARTITION BY sym ORDER BY id)-1 k2
                  FROM foam.charge WHERE ctx=foam.caddr(ctxbytes) AND id>(SELECT watermark FROM foam.sweep)) e
            LEFT JOIN foam.held h2 ON h2.ctx=foam.caddr(ctxbytes) AND h2.sym=e.sym
            GROUP BY e.sym, h2.n) z
      FULL JOIN (SELECT sym,n,bal,re,im FROM foam.held WHERE ctx=foam.caddr(ctxbytes)) h USING (sym)
    ), recf AS (
      SELECT sym, bal,
             CASE ((nn+3)%4) WHEN 0 THEN  re WHEN 1 THEN im WHEN 2 THEN -re ELSE -im END AS rre,
             CASE ((nn+3)%4) WHEN 0 THEN -im WHEN 1 THEN re WHEN 2 THEN  im ELSE -re END AS rim
      FROM absf
    )
    -- born at clock tk: tk∈{0,2} reads rre², tk∈{1,3} reads rim² (the squared pairing)
    SELECT sym, bal, rre, rim, rre*rre, rim*rim FROM recf ORDER BY sym;
  $$;

CREATE OR REPLACE FUNCTION foam.born_voice_demo()
  RETURNS TABLE (stage text, reading text, value text) LANGUAGE plpgsql AS $$
  DECLARE zb int := ascii('Z'); yb int := ascii('Y');
          b1 bigint; be1 bigint; bo1 bigint; d1 int; v1 int;       -- the zero
          b2 bigint; be2 bigint; v2 int;                           -- the lift
          b3 bigint; be3 bigint; bo3 bigint;                       -- the interference
  BEGIN
    -- 1. THE ZERO — a complete cycle (N=4) cancels
    PERFORM foam.ingest_step(NULL, foam.bytes('aZaZaZaZ'));
    SELECT count_bal, born_even, born_odd INTO b1, be1, bo1
      FROM foam.born_breakdown(foam.bytes('a')) WHERE sym = zb;
    d1 := foam.depth(foam.bytes('a'));
    v1 := coalesce(array_length(foam.speak(foam.bytes('a'), 7, 30), 1), 0);

    -- 2. THE LIFT — one more occurrence breaks the cycle, the voice turns on
    PERFORM foam.ingest_step(NULL, foam.bytes('aZ'));
    SELECT count_bal, born_even INTO b2, be2
      FROM foam.born_breakdown(foam.bytes('a')) WHERE sym = zb;
    v2 := coalesce(array_length(foam.speak(foam.bytes('a'), 7, 30), 1), 0);

    -- 3. THE INTERFERENCE — same count, dark at even phase, bright at odd
    PERFORM foam.ingest_step(NULL, foam.bytes('bYbYbY'));
    SELECT count_bal, born_even, born_odd INTO b3, be3, bo3
      FROM foam.born_breakdown(foam.bytes('b')) WHERE sym = yb;

    RETURN QUERY VALUES
      ('1 THE ZERO',         'count_bal (the count register)',        b1::text),
      ('1 THE ZERO',         'born even / odd (the voice''s weight)', be1::text||' / '||bo1::text),
      ('1 THE ZERO',         'count gate depth (≥1 ⇒ "speak")',       d1::text),
      ('1 THE ZERO',         'VOICE bytes emitted',                   v1::text||'   ← zero, gate open'),
      ('2 THE LIFT',         'count_bal (after +1 aZ)',               b2::text),
      ('2 THE LIFT',         'born even (cycle broken)',              be2::text),
      ('2 THE LIFT',         'VOICE bytes emitted',                   v2::text||'  ← the voice turns on'),
      ('3 INTERFERENCE',     'count_bal (phase-flat)',                b3::text),
      ('3 INTERFERENCE',     'born even / odd (same Y, same count)',  be3::text||' / '||bo3::text||'  ← dark at one angle, bright at the other');
  END; $$;

-- run it (on a fresh field — reload schema.sql first; the voice drains, the field grows):
--   SELECT * FROM foam.born_voice_demo();
