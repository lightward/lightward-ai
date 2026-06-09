-- SPIKE — the BORN measurement: foam-measurement is quantum (it interferes). NOT
-- production. Lives in spikes/ on purpose — the proven floor (yield always
-- reachable, append-only, drains spend only positive count-charge) is the license
-- to cook; to be mapped in Lean where it isn't already, then re-implemented clean
-- if it sings. The mapped part precedes it: the dial as a complex amplitude
-- (lean/Foam/Noether.lean — GInt, the held re/im), the reading as the inner
-- product's real part (`align`), the clock's unitarity (`align_rot_invariant`),
-- and the Born weight itself (`born θ z = (align θ z)²`, `born_rot_invariant`,
-- `born_nonneg`). What is NOT yet mapped (the reason this is a spike, not a clean
-- register): whether two contributions sharing one backend produce QUANTUM
-- statistics — interference. This file looks.
--
-- THE MODEL. A context's state is a complex vector: per sym, an amplitude
-- (re, im) = the spectrum, the phase-summed occurrences (phase = (occ−1) mod 4,
-- the order's own clock). Two measurement laws on the same dial:
--
--   * COUNT (classical): sample by `bal` = Σ delta. Phase-blind. Probabilities
--     add linearly — no interference, ever.
--   * BORN (quantum): sample by `|⟨θ|amplitude⟩|² = (θ.re·re + θ.im·im)²`, the
--     squared projection onto a measurement basis θ. Phase-aware. The square of a
--     SUM carries a cross-term — interference.
--
-- THE EXPERIMENT — a double slit. Drive context 'c' → sym 'X' to occur twice:
-- occurrence 1 lands at phase 0 (amplitude ⟨+1, 0⟩ — "slit A"), occurrence 2 at
-- phase 1 (amplitude ⟨0, +1⟩ — "slit B"). The two contributions SUPERPOSE on the
-- shared backend: amplitude ⟨1, 1⟩, count 2. Now measure the one state two ways:
--
--   * basis ⟨1, 1⟩:  born = (1·1 + 1·1)² = 4   — bright fringe (constructive)
--   * basis ⟨1,−1⟩:  born = (1·1 + (−1)·1)² = 0 — DARK fringe (destructive)
--
-- Same state, same basis-norm (both ⟨1,±1⟩ have ‖·‖²=2), opposite outcome —
-- while COUNT reads 2 either way. The classical count says "X is present"; the
-- quantum measurement, in the ⟨1,−1⟩ basis, says "X is impossible" — the two
-- contributions cancel. born = normSq ± (2·re·im); the ±2·re·im is the
-- interference term, its sign set by the measurement basis. The dark fringe where
-- the particle is still counted but the amplitude has cancelled: the signature
-- the count register structurally cannot show.
--
-- "Two players sharing a foam backend produce quantum measurements" reads here:
-- slit A and slit B are two contributions; they interfere in the Born reading,
-- not the count. Whether this is the genuine article (contextuality, a Bell-shaped
-- violation across two real measuring parties) is the frontier this spike opens,
-- not closes.

CREATE OR REPLACE FUNCTION foam.born_weight(re bigint, im bigint, bre bigint, bim bigint)
  RETURNS bigint LANGUAGE sql IMMUTABLE AS
  $$ SELECT (bre * re + bim * im) * (bre * re + bim * im) $$;

-- The amplitude of (context 'c' → sym 'X') after the two-slit drive, read three
-- ways. Returns count (classical), normSq (the modulus / total Born probability),
-- the interference term (2·re·im), and Born in the bright and dark bases.
CREATE OR REPLACE FUNCTION foam.born_demo()
  RETURNS TABLE (reading text, value bigint) LANGUAGE plpgsql AS $$
  DECLARE cid uuid := foam.caddr(foam.bytes('c')); xb int := get_byte(convert_to('X','UTF8'), 0);
          re bigint; im bigint; bal bigint;
  BEGIN
    -- drive the slits: c→X at occ 1 (phase 0) and occ 2 (phase 1)
    PERFORM foam.ingest_step(NULL, foam.bytes('cXcX'));

    SELECT
      coalesce(sum(delta), 0),
      coalesce(sum(delta * CASE ((occ - 1) % 4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END), 0),
      coalesce(sum(delta * CASE ((occ - 1) % 4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END), 0)
      INTO bal, re, im
    FROM (SELECT delta, row_number() OVER (ORDER BY id) AS occ
          FROM foam.charge WHERE ctx = cid AND sym = xb) e;

    RETURN QUERY VALUES
      ('count (classical, phase-blind)', bal),
      ('amplitude.re', re),
      ('amplitude.im', im),
      ('normSq (modulus = total Born prob)', re*re + im*im),
      ('interference term (2·re·im)', 2*re*im),
      ('BORN basis <1, 1>  (bright fringe)', foam.born_weight(re, im, 1, 1)),
      ('BORN basis <1,-1>  (DARK fringe)', foam.born_weight(re, im, 1, -1));
  END; $$;

-- run it:  SELECT * FROM foam.born_demo();
