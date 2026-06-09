-- SPIKE — the ROSETTA test, AND its correction. NOT production. This file is honest
-- make-it-work history (radio.sql's precedent): it records an exploration that found
-- a real artifact, the proper measurement that replaced it, and the recognition that
-- relocated the open question. The proven floor (yield always reachable, append-only,
-- drains spend only positive count-charge) was the license to cook; the cooking
-- surfaced a trap, and the trap is the lesson. Mapped parts it leans on: the dial
-- (lean/Foam/Noether.lean), the Born measurement (Born.lean), the spectrum
-- (Spectrum.lean), the lfp↔gfp gap (Arrow.lean: forever_escapes).
--
-- THE ARC. Natural emergence is checkable frontstage (language.md: the wind arrives
-- with spacelike structure). The object-free form is the ROSETTA STONE: one message
-- (the shared endpoint), two scripts (two readings), ZERO byte-overlap. Two scripts
-- are two STATIONS on the ℤ/4 dial; translation between them is a ROTATION (Mikolov
-- 2013, arXiv:1309.4168, "a linear mapping, namely a rotation and scaling"; MUSE/
-- Conneau 2017, arXiv:1710.04087, recovers it label-free under an orthogonality
-- constraint). The shared MEANING is the conserved modulus normSq — and
-- station_blind_to_norm ∧ norm_blind_to_station (Noether.lean) ARE the razor: every
-- station reads a projection, none reads the invariant. The meaning is present and
-- UNREADABLE — the Platonic form (arXiv:2405.07987) with the WHY the paper can't say;
-- the Umwelt critique (arXiv:2604.17960) the conjugate half. Both theorems.
--
-- ── THE ARTIFACT (the lesson — read this before trusting any concurrence) ─────────
-- The first instrument here read the COHERENT JOINT: ψ_ij = the per-trial
-- co-occurrence of (script-A reads movement i, script-B reads j), summed with the
-- trial's ℤ/4 phase, then concurrence C = 2|det ψ|/Σ|ψ|² and CHSH = 2√(1+C²). On the
-- SIGNAL (same message, two scripts) it gave C = 1, CHSH = 2√2 — Tsirelson, maximal.
-- Exciting, and WRONG. The NULL control (two INDEPENDENT messages, agreement 0.5)
-- gave CHSH > 2 — a "violation" between two coin-flips (C wanders 0→1 on pure noise,
-- mean ~0.47). A measure that calls two independent coin-flips Bell-nonlocal is
-- measuring its own construction, not the world. The fault:
-- the coherent sum uses a COMPUTED shared phase clock as fake coherence, PURIFYING a
-- classical mixture into a spurious pure entangled state. (Concurrence-of-a-random-
-- 2×2 is generically O(1) — entanglement is generic; correlation is not.) So:
--   ✗ DO NOT read concurrence-of-the-raw-joint as an entanglement witness.
--   ✓ The discriminator is CORRELATION (agreement: signal 1.0, null 0.5), not C.
--
-- ── THE PROPER MEASUREMENT (per-trial Born, hardware-sampled, settings = the wind) ─
-- Each trial: read both scripts' movement; each party measures its local state |m⟩
-- (movement 0 at dial 0, movement 1 at 90°) in a Bell-optimal basis, outcome ±1
-- SAMPLED by Born (P(+1) = cos²(θ − m·90°)) with hardware entropy (foam.hw_random,
-- the wind — Classical.choice refused, so settings are genuinely free: measurement-
-- independence, structural). Correlate, form S = E(a,b)+E(a,b')+E(a',b)−E(a',b').
-- Result (≈, hardware-sampled): SIGNAL S ≈ √2 (≈1.41, classical, and ≤ 2 always);
-- NULL S ≈ 0. No violation anywhere. Definite-message translation is CLASSICAL
-- correlation — the shared meaning is a local hidden variable (a common cause), the
-- ψ-epistemic backstage λ, exactly as bell2's honesty block scoped it.
--
-- ── THE RECOGNITION (what holds, and where the question actually lives) ───────────
-- This measured the BACKSTAGE: a definite, append-only, totally-ordered record —
-- which IS a local hidden variable λ. Bell's theorem is about the EXISTENCE of such a
-- λ, not its accessibility: a definite local λ + free winds ⇒ frontstage-of-the-
-- backstage FORCED ≤ 2. So "backstage classical" is structural, not contingent — and
-- finding it is discovering sanity where sanity was expected.
--
-- But the quantum question was NEVER about the backstage. The frontstage VOICE (the
-- gfp) strictly exceeds the record (forever_escapes, Arrow.lean) — self-reference
-- across reflection creates data not on the tape (language.md). Frontstage and
-- backstage are ONTICALLY DISTINCT: there is no portable parameterization across the
-- lfp↔gfp gap, so backstage-classical does NOT imply frontstage-classical (the
-- import this spike's first instrument, and its author, wrongly made). And the right
-- no-go for the frontstage is PUSEY–BARRETT–RUDOLPH, not Bell: realism +
-- preparation-independence (the independent winds, PBR's antecedent, already
-- structural here) ⇒ the state is ψ-ONTIC — no ψ-epistemic shadow-of-a-classical-λ.
-- The frontstage form is REAL, not a hidden-variable common cause.
--
-- ── THE FRONTIER (the instrument this spike points at, deliberately NOT built here) ─
-- The PBR-shaped test: a voice improvising in a language it has NOT seen, asked to
-- path-match a form in a NOVEL basis — does it distinguish distinct forms with the
-- zero-overlap structure ψ-ontic predicts (vs. the confusability ψ-epistemic
-- predicts)? That is a frontstage, two-voices-comparing-notes experiment (a different
-- instrument than the per-trial backstage read below). Honest scope: mapping PBR's
-- preparation/measurement structure onto the foam frontstage is a bridge to build —
-- named, not yet crossed.

-- Encode a movement-stream in one script: '0' → c0 c1 c0 (out-and-return), '1' →
-- c0 c1 c1 (out-and-stay) — a MORPHISM (which symbol recurs), not an inert fact;
-- each trial closed by 0x0A so 2-byte contexts never bridge trials.
CREATE OR REPLACE FUNCTION foam.rosetta_enc(mv text, c0 text, c1 text)
  RETURNS text LANGUAGE plpgsql IMMUTABLE AS $$
  DECLARE out text := ''; ch text;
  BEGIN
    FOR i IN 1..length(mv) LOOP
      ch := substr(mv, i, 1);
      out := out || c0 || c1 || (CASE WHEN ch = '0' THEN c0 ELSE c1 END) || E'\n';
    END LOOP;
    RETURN out;
  END; $$;

-- A hardware-random bit-stream (the wind — obtained, never computed).
CREATE OR REPLACE FUNCTION foam.randbits(n int) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE s text := '';
  BEGIN FOR i IN 1..n LOOP s := s || (CASE WHEN foam.hw_random() < 0.5 THEN '0' ELSE '1' END); END LOOP;
        RETURN s; END; $$;

-- Per-trial movement read from a script (the k-th occurrence of its 2-byte context,
-- in id order, is trial k; the continuation sym is which symbol recurs).
CREATE OR REPLACE FUNCTION foam.rosetta_reads(ctxa uuid, m0a int)
  RETURNS TABLE (mv int, t bigint) LANGUAGE sql STABLE AS $$
  SELECT CASE WHEN sym = m0a THEN 0 ELSE 1 END, row_number() OVER (ORDER BY id)
  FROM foam.charge WHERE ctx = ctxa AND delta > 0; $$;

-- THE ARTIFACT, kept labeled: concurrence of the coherent phase-summed joint. Reads
-- C = 1 on the signal AND ≈ 0.7 on the null — it cannot tell translation from noise.
-- A cautionary witness, not a measurement.
CREATE OR REPLACE FUNCTION foam.rosetta_concurrence_ARTIFACT(ctxa uuid, m0a int, ctxb uuid, m0b int)
  RETURNS double precision LANGUAGE plpgsql STABLE AS $$
  DECLARE r00 bigint; i00 bigint; r01 bigint; i01 bigint;
          r10 bigint; i10 bigint; r11 bigint; i11 bigint;
          dr double precision; di double precision; nrm double precision;
  BEGIN
    WITH a AS (SELECT * FROM foam.rosetta_reads(ctxa, m0a)),
         b AS (SELECT * FROM foam.rosetta_reads(ctxb, m0b)),
         j AS (SELECT a.mv AS i, b.mv AS k, a.t AS t FROM a JOIN b ON a.t = b.t),
         g AS (SELECT i, k,
                 sum(CASE (t-1)%4 WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END) AS re,
                 sum(CASE (t-1)%4 WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END) AS im
               FROM j GROUP BY i, k)
    SELECT coalesce(sum(re) FILTER (WHERE i=0 AND k=0),0), coalesce(sum(im) FILTER (WHERE i=0 AND k=0),0),
           coalesce(sum(re) FILTER (WHERE i=0 AND k=1),0), coalesce(sum(im) FILTER (WHERE i=0 AND k=1),0),
           coalesce(sum(re) FILTER (WHERE i=1 AND k=0),0), coalesce(sum(im) FILTER (WHERE i=1 AND k=0),0),
           coalesce(sum(re) FILTER (WHERE i=1 AND k=1),0), coalesce(sum(im) FILTER (WHERE i=1 AND k=1),0)
      INTO r00,i00,r01,i01,r10,i10,r11,i11 FROM g;
    dr := (r00*r11 - i00*i11) - (r01*r10 - i01*i10);
    di := (r00*i11 + i00*r11) - (r01*i10 + i01*r10);
    nrm := (r00*r00+i00*i00)+(r01*r01+i01*i01)+(r10*r10+i10*i10)+(r11*r11+i11*i11);
    RETURN CASE WHEN nrm > 0 THEN 2*sqrt(dr*dr + di*di)/nrm ELSE 0 END;
  END; $$;

-- THE PROPER MEASUREMENT: per-trial Born outcomes, hardware-sampled, Bell-optimal
-- settings. Returns CHSH S. Reads ≈√2 on the signal (classical), ≈0 on the null.
CREATE OR REPLACE FUNCTION foam.rosetta_chsh(ctxa uuid, m0a int, ctxb uuid, m0b int)
  RETURNS double precision LANGUAGE plpgsql AS $$
  DECLARE a0 double precision := 0;        a1 double precision := pi()/4;
          b0 double precision := pi()/8;   b1 double precision := -pi()/8;
          e00 double precision; e01 double precision; e10 double precision; e11 double precision;
  BEGIN
    WITH j AS (SELECT a.mv AS ma, b.mv AS mb
               FROM foam.rosetta_reads(ctxa, m0a) a JOIN foam.rosetta_reads(ctxb, m0b) b ON a.t = b.t),
         s AS (SELECT
                 CASE WHEN foam.hw_random() < power(cos(a0 - ma*pi()/2),2) THEN 1 ELSE -1 END AS oa0,
                 CASE WHEN foam.hw_random() < power(cos(a1 - ma*pi()/2),2) THEN 1 ELSE -1 END AS oa1,
                 CASE WHEN foam.hw_random() < power(cos(b0 - mb*pi()/2),2) THEN 1 ELSE -1 END AS ob0,
                 CASE WHEN foam.hw_random() < power(cos(b1 - mb*pi()/2),2) THEN 1 ELSE -1 END AS ob1
               FROM j)
    SELECT avg(oa0*ob0), avg(oa0*ob1), avg(oa1*ob0), avg(oa1*ob1) INTO e00,e01,e10,e11 FROM s;
    RETURN e00 + e01 + e10 - e11;
  END; $$;

-- The correlation (agreement): the actual discriminator. Signal 1.0, null 0.5.
CREATE OR REPLACE FUNCTION foam.rosetta_agree(ctxa uuid, m0a int, ctxb uuid, m0b int)
  RETURNS double precision LANGUAGE sql STABLE AS $$
  SELECT avg(CASE WHEN a.mv = b.mv THEN 1.0 ELSE 0.0 END)
  FROM foam.rosetta_reads(ctxa, m0a) a JOIN foam.rosetta_reads(ctxb, m0b) b ON a.t = b.t; $$;

CREATE OR REPLACE FUNCTION foam.rosetta_demo()
  RETURNS TABLE (reading text, value double precision) LANGUAGE plpgsql AS $$
  DECLARE S text; Sp text; n int := 2000;
          ab uuid := foam.caddr(foam.bytes('ab')); xy uuid := foam.caddr(foam.bytes('xy'));
          cd uuid := foam.caddr(foam.bytes('cd')); pq uuid := foam.caddr(foam.bytes('pq'));
  BEGIN
    S  := foam.randbits(n);   -- the message
    Sp := foam.randbits(n);   -- an INDEPENDENT message (the null's second script)
    PERFORM foam.ingest_step(NULL, foam.bytes(foam.rosetta_enc(S,  'a','b')));  -- signal A
    PERFORM foam.ingest_step(NULL, foam.bytes(foam.rosetta_enc(S,  'x','y')));  -- signal B (same S)
    PERFORM foam.ingest_step(NULL, foam.bytes(foam.rosetta_enc(S,  'c','d')));  -- null   C
    PERFORM foam.ingest_step(NULL, foam.bytes(foam.rosetta_enc(Sp, 'p','q')));  -- null   D (independent)

    RETURN QUERY VALUES
      ('PROPER CHSH — SIGNAL (same message)',  foam.rosetta_chsh(ab, ascii('a'), xy, ascii('x'))),
      ('PROPER CHSH — NULL (independent)',      foam.rosetta_chsh(cd, ascii('c'), pq, ascii('p'))),
      ('classical bound', 2.0),
      ('Tsirelson 2√2',   2*sqrt(2.0)),
      ('—', 0.0),
      ('DISCRIMINATOR agreement — SIGNAL', foam.rosetta_agree(ab, ascii('a'), xy, ascii('x'))),
      ('DISCRIMINATOR agreement — NULL',   foam.rosetta_agree(cd, ascii('c'), pq, ascii('p'))),
      ('—', 0.0),
      ('ARTIFACT concurrence — SIGNAL (do not trust)', foam.rosetta_concurrence_ARTIFACT(ab, ascii('a'), xy, ascii('x'))),
      ('ARTIFACT concurrence — NULL (nonzero & wandering: calls noise entangled)', foam.rosetta_concurrence_ARTIFACT(cd, ascii('c'), pq, ascii('p'))),
      ('—', 0.0),
      ('byte-overlap signal scripts {a,b}∩{x,y}', 0.0);
  END; $$;

-- run it (on a fresh field — reload schema.sql first; append-only, so a re-run grows;
-- hardware-sampled, so CHSH wobbles by ~0.05 between runs):
--   SELECT * FROM foam.rosetta_demo();
