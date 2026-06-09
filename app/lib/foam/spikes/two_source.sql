-- SPIKE — TWO SOURCES into the shared foam: interference is communication, and it
-- has a decoherence off-switch. NOT production. Honest make-it-work record. This is
-- step 2 of the frontstage lift (after spikes/born_voice.sql's n=1 dark fringe): two
-- players speaking into one medium. Built on born_superpose (lean/Foam/Born.lean,
-- already proven) — no imposed tensor, real foam amplitudes.
--
-- THE FRAME (foam as the relativistic vacuum, not the disproven mechanical aether —
-- a medium with NO preferred frame, which the foam is by construction: align_rot_-
-- invariant, observerless backstage, scale-is-the-beholder's). Two frontstage players
-- are two LIGHT SOURCES emitting into the foam. The count register is the PARTICLE
-- reading (discrete events); the Born register is the WAVE reading (the carrier,
-- interference). Each player emits an amplitude (its spectrum) onto a shared
-- continuation X; the foam's joint reading is born(a ⊕ rot^φ·b) — born_superpose:
--   born θ (a ⊕ b) = born θ a + born θ b + 2·(align θ a · align θ b)
-- the cross-term 2·align(a)·align(b) is two-source INTERFERENCE.
--
-- WHAT IT SHOWS (foam.two_source / foam.two_source_demo). A and B both speak X
-- (A through context c, B through d), real amplitudes a = b = ⟨1,1⟩. Hold A fixed,
-- rotate B's RELATIVE PHASE φ by the quarter-turn:
--   φ0 (in phase):   joint 4  — CONSTRUCTIVE, brighter than either source (each = 1)
--   φ1, φ2:          joint 0  — the TWO-SOURCE DARK FRINGE: both players speak X, out
--                              of phase, and the foam hears SILENCE (communication
--                              producing a null — the cross-term, destructive)
--   φ3:              joint 4  — constructive again
-- The joint SWINGS with relative phase: fringes, the wave. born_a, born_b constant.
--
-- COMMUNICATION = COHERENCE. A fixed relative phase is phase-LOCK: two players sharing
-- a form (talking to each other) hold φ, and interfere. INDEPENDENT winds randomize φ
-- — and averaged over a full cycle of relative phase the cross-terms CANCEL (rot² is
-- the antipode; each phase pairs with its half-turn): the phase-averaged joint equals
-- born_a + born_b (INTENSITIES ADD). That is DECOHERENCE — the interference's own
-- off-switch, and the independent-winds NULL. The decohered average == born_a+born_b
-- is the column to watch.
--
-- WHY IT'S TRUSTWORTHY (the controls): the amplitudes are real foam spectra (read,
-- not constructed); the combination is the proven born_superpose; and the interference
-- HAS ITS NULL (randomize relative phase → it vanishes → intensities add). An effect
-- with a working off-switch is not an artifact.
--
-- SCOPE (the discipline line). This is the WAVE FLOOR — and wave interference is
-- classically modelable (Young's fringes work with classical light). It establishes
-- communication=coherence and the two-source dark fringe; it is NOT yet the quantum
-- (ψ-ontic) win. That is the next lift: the PARTICLE-level correlations (the count
-- statistics no classical wave reproduces — the PBR anti-distinguisher / Bell), now
-- standing on this floor. Mirror: born_superpose, two_source_fringe, decoherence_-
-- cancels_cross (lean/Foam/Born.lean).

-- per-continuation recency spectrum (re, im) — copied from foam.speak's read
CREATE OR REPLACE FUNCTION foam.born_breakdown(ctxbytes int[])
  RETURNS TABLE (sym int, count_bal bigint, rec_re bigint, rec_im bigint) LANGUAGE sql STABLE AS $$
    WITH absf AS (
      SELECT z.sym, coalesce(h.bal,0)+coalesce(z.bal,0) AS bal, coalesce(h.re,0)+coalesce(z.re,0) AS re,
             coalesce(h.im,0)+coalesce(z.im,0) AS im, coalesce(h.n,0)+coalesce(z.tn,0) AS nn
      FROM (SELECT e.sym, count(*) tn, sum(e.delta) bal,
                   sum(e.delta*CASE ((coalesce(h2.n,0)+e.k2)%4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END) re,
                   sum(e.delta*CASE ((coalesce(h2.n,0)+e.k2)%4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END) im
            FROM (SELECT sym, delta, row_number() OVER (PARTITION BY sym ORDER BY id)-1 k2
                  FROM foam.charge WHERE ctx=foam.caddr(ctxbytes) AND id>(SELECT watermark FROM foam.sweep)) e
            LEFT JOIN foam.held h2 ON h2.ctx=foam.caddr(ctxbytes) AND h2.sym=e.sym GROUP BY e.sym,h2.n) z
      FULL JOIN (SELECT sym,n,bal,re,im FROM foam.held WHERE ctx=foam.caddr(ctxbytes)) h USING (sym)
    ), recf AS (
      SELECT sym, CASE ((nn+3)%4) WHEN 0 THEN re WHEN 1 THEN im WHEN 2 THEN -re ELSE -im END AS rre,
             CASE ((nn+3)%4) WHEN 0 THEN -im WHEN 1 THEN re WHEN 2 THEN im ELSE -re END AS rim, bal FROM absf)
    SELECT sym, bal, rre, rim FROM recf; $$;

-- the two-source fringe (basis tk=0 reads the real component; align(0,z)=z.re).
-- rot^φ b:  φ0=(bre,bim) φ1=(-bim,bre) φ2=(-bre,-bim) φ3=(bim,-bre)
CREATE OR REPLACE FUNCTION foam.two_source(cb int[], db int[], xb int)
  RETURNS TABLE (born_a bigint, born_b bigint,
                 joint_phi0 bigint, joint_phi1 bigint, joint_phi2 bigint, joint_phi3 bigint,
                 decohered_avg numeric, intensities_add bigint) LANGUAGE plpgsql STABLE AS $$
  DECLARE are bigint; aim bigint; bre bigint; bim bigint;
  BEGIN
    SELECT rec_re, rec_im INTO are, aim FROM foam.born_breakdown(cb) WHERE sym = xb;
    SELECT rec_re, rec_im INTO bre, bim FROM foam.born_breakdown(db) WHERE sym = xb;
    RETURN QUERY SELECT
      are*are, bre*bre,
      (are+bre)*(are+bre), (are-bim)*(are-bim), (are-bre)*(are-bre), (are+bim)*(are+bim),
      ((are+bre)*(are+bre)+(are-bim)*(are-bim)+(are-bre)*(are-bre)+(are+bim)*(are+bim))::numeric/4,
      are*are + bre*bre;
  END; $$;

CREATE OR REPLACE FUNCTION foam.two_source_demo()
  RETURNS TABLE (born_a bigint, born_b bigint,
                 joint_phi0 bigint, joint_phi1 bigint, joint_phi2 bigint, joint_phi3 bigint,
                 decohered_avg numeric, intensities_add bigint) LANGUAGE plpgsql AS $$
  BEGIN
    PERFORM foam.ingest_step(NULL, foam.bytes('cXcX'));   -- player A → amplitude a
    PERFORM foam.ingest_step(NULL, foam.bytes('dXdX'));   -- player B → amplitude b
    RETURN QUERY SELECT * FROM foam.two_source(foam.bytes('c'), foam.bytes('d'), ascii('X'));
  END; $$;

-- run it (on a fresh field — reload schema.sql first):
--   SELECT * FROM foam.two_source_demo();
-- read: joint SWINGS 4/0/0/4 across relative phase (fringes); decohered_avg == intensities_add
-- (the cross-term cancels over a full cycle — decoherence, the independent-winds null).
