-- SPIKE — the NATIVE two-party Bell test: the entanglement is uncountable from
-- the frontstage. NOT production. bell.sql imposed a 2-qubit split on one
-- context's four syms (a choice). This reads the JOINT amplitude over TWO
-- contexts from their CO-OCCURRENCE in the ledger — the order reading, the
-- backstage — and compares it to the MARGINALS the held cache stores (the
-- frequency reading, the frontstage). The decisive shape Isaac named: a state
-- whose marginals are FLAT (frontstage sees uniform noise, no correlation) while
-- its joint is MAXIMALLY ENTANGLED (backstage, CHSH = 2√2). Entanglement living
-- exactly where the frontstage cannot count it (maintenance_unobservable).
--
-- THE SOURCE. Two correlated trials after a shared context c:
--   c→A→X   ("Alice gets A, Bob gets X")
--   c→B→Y   ("Alice gets B, Bob gets Y")
-- and NEVER the cross pairs (c→A→Y, c→B→X). Alice's qubit = {A,B}, Bob's = {X,Y}.
--
-- THE JOINT (backstage / order / co-occurrence): ψ_ij = amplitude of the
-- co-occurrence (c·a_i → b_j), read as the spectrum of the 2-byte context "c a_i"
-- continued by b_j (the ledger's actual co-occurrence record, not the held
-- marginals). For this source ψ = [[1,0],[0,1]] — the Bell state. Concurrence
-- C = 2|ψ00·ψ11 − ψ01·ψ10|/Σ|ψ|² = 1 (maximal); CHSH = 2√(1+C²) = 2√2 (Tsirelson).
--
-- THE MARGINALS (frontstage / frequency / held): what the per-context cache
-- stores — c→{A,B} for Alice, and Bob's outcome marginalized over Alice. For a
-- Bell state these are FLAT: P(A)=P(B), P(X)=P(Y), no visible correlation. The
-- product state built from flat marginals is separable: CHSH = 2.
--
-- So: frontstage CHSH = 2 (separable, the marginals look classical/uniform);
-- backstage CHSH = 2√2 (maximally entangled). The gap IS the entanglement, and
-- it is invisible to the frontstage — present only in the co-occurrence (the
-- order reading), uncountable from the marginals (the held cache stores the
-- factored per-context state; the joint it omits is exactly the entanglement).
--
-- HONESTY — the scoping, named:
--   1. The source correlation is CONSTRUCTED. This shows the foam's co-occurrence
--      machinery NATIVELY represents and measures two-party entanglement (in the
--      order, invisible to the marginals) — NOT that natural streams produce it
--      (that's the deeper open question).
--   2. The joint is read as a conditional amplitude (Bob's context "c a_i"
--      includes Alice's outcome) — Bob's slot follows Alice's, so they are
--      TIMELIKE, not spacelike. The loophole this test closes is FRONTSTAGE-
--      INACCESSIBILITY (the entanglement is real and absent from the marginals),
--      NOT spacelike-separated loophole-free non-locality.
--   3. So the result is the ψ-EPISTEMIC structure, concrete: frontstage-quantum
--      (the joint/entanglement uncountable from the marginals) over a backstage
--      definite record (the order — a God's-eye local variable). A definite
--      reality you provably cannot reach from where you live, so the reality you
--      can reach is quantum. That is the foam's deepest property (the lossless
--      order, maintenance_unobservable) realizing quantum foundations.

CREATE OR REPLACE FUNCTION foam.amp(cid uuid, s int)
  RETURNS TABLE (re bigint, im bigint) LANGUAGE sql STABLE AS $$
  SELECT
    coalesce(sum(delta * CASE ((occ-1)%4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END), 0),
    coalesce(sum(delta * CASE ((occ-1)%4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END), 0)
  FROM (SELECT delta, row_number() OVER (ORDER BY id) AS occ
        FROM foam.charge WHERE ctx = cid AND sym = s) e $$;

CREATE OR REPLACE FUNCTION foam.bell2_demo()
  RETURNS TABLE (reading text, value double precision) LANGUAGE plpgsql AS $$
  DECLARE cA uuid := foam.caddr(foam.bytes('cA')); cB uuid := foam.caddr(foam.bytes('cB'));
          cc uuid := foam.caddr(foam.bytes('c'));
          xb int := get_byte(convert_to('X','UTF8'),0); yb int := get_byte(convert_to('Y','UTF8'),0);
          ab int := get_byte(convert_to('A','UTF8'),0); bb int := get_byte(convert_to('B','UTF8'),0);
          z00r bigint; z00i bigint; z01r bigint; z01i bigint;
          z10r bigint; z10i bigint; z11r bigint; z11i bigint;
          aAr bigint; aAi bigint; aBr bigint; aBi bigint;
          dr double precision; di double precision; dabs double precision;
          nrm double precision; cj double precision; sj double precision;
          pA double precision; pB double precision; pX double precision; pY double precision;
  BEGIN
    -- the source: the two correlated trials, never the cross pairs
    PERFORM foam.ingest_step(NULL, foam.bytes('cAXcBY'));

    -- JOINT (backstage): ψ_ij from co-occurrence (context "c a_i" → b_j)
    SELECT re, im INTO z00r, z00i FROM foam.amp(cA, xb);   -- cA→X
    SELECT re, im INTO z01r, z01i FROM foam.amp(cA, yb);   -- cA→Y
    SELECT re, im INTO z10r, z10i FROM foam.amp(cB, xb);   -- cB→X
    SELECT re, im INTO z11r, z11i FROM foam.amp(cB, yb);   -- cB→Y

    dr := (z00r*z11r - z00i*z11i) - (z01r*z10r - z01i*z10i);
    di := (z00r*z11i + z00i*z11r) - (z01r*z10i + z01i*z10r);
    dabs := sqrt(dr*dr + di*di);
    nrm := (z00r*z00r+z00i*z00i)+(z01r*z01r+z01i*z01i)
         + (z10r*z10r+z10i*z10i)+(z11r*z11r+z11i*z11i);
    cj := 2*dabs/nrm;
    sj := 2*sqrt(1 + cj*cj);

    -- MARGINALS (frontstage): Alice c→{A,B}; Bob X/Y marginalized over Alice
    SELECT re, im INTO aAr, aAi FROM foam.amp(cc, ab);
    SELECT re, im INTO aBr, aBi FROM foam.amp(cc, bb);
    pA := aAr*aAr + aAi*aAi;  pB := aBr*aBr + aBi*aBi;
    pX := (z00r*z00r+z00i*z00i) + (z10r*z10r+z10i*z10i);   -- X over both Alice outcomes
    pY := (z01r*z01r+z01i*z01i) + (z11r*z11r+z11i*z11i);

    RETURN QUERY VALUES
      ('JOINT |det ψ| (backstage)', dabs),
      ('JOINT concurrence C', cj),
      ('JOINT CHSH (backstage / co-occurrence)', sj),
      ('Tsirelson 2√2', 2*sqrt(2.0)),
      ('—', 0.0),
      ('MARGINAL Alice P(A)', pA),
      ('MARGINAL Alice P(B)', pB),
      ('MARGINAL Bob P(X)', pX),
      ('MARGINAL Bob P(Y)', pY),
      ('FRONTSTAGE CHSH (separable, flat marginals)', 2.0);
  END; $$;

-- run it:  SELECT * FROM foam.bell2_demo();
