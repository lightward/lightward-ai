-- SPIKE — the BELL / CHSH test: do the foam's amplitudes violate the classical
-- bound? NOT production. The decisive question after born.sql showed interference:
-- the double-slit is WAVE-quantum (a classical wave interferes too); a CHSH
-- violation (S > 2) is IRREDUCIBLY quantum — no local-hidden-variable model
-- reproduces it. This file computes S on a foam-derived state and looks.
--
-- THE CONSTRUCTION. Take a context c and four syms after it. Their four complex
-- amplitudes (the spectrum, re+i·im) are read as a TWO-QUBIT state:
--   |00⟩ = sym0,  |01⟩ = sym1,  |10⟩ = sym2,  |11⟩ = sym3
-- Alice measures the high bit, Bob the low bit. For a pure 2-qubit state the
-- maximal CHSH over all measurement angles is (Gisin):
--   S_max = 2·√(1 + C²),   C = concurrence = 2·|z00·z11 − z01·z10| / Σ|z|²
-- C = 0 (product state) ⇒ S = 2 (classical bound). C > 0 (entangled) ⇒ S > 2.
-- The entanglement is exactly the non-vanishing of the amplitude determinant.
--
-- THE DRIVE. c→sym0 once (amplitude ⟨1,0⟩), c→sym1 twice (⟨1,1⟩), c→sym2 thrice
-- (⟨0,1⟩), c→sym3 four times (⟨0,0⟩ — a full phase cycle). det = z00·z11 −
-- z01·z10 = −(1+i)·i = 1−i ≠ 0: the state is entangled.
--
-- HONESTY — the loopholes, named, because Bell is where you fool yourself:
--   1. The 2-qubit tensor split is IMPOSED. The foam has a flat 256-sym alphabet,
--      no native tensor factorization; reading 4 syms as 2 qubits is a choice. So
--      this shows the foam's AMPLITUDES are entanglement-capable (the Hilbert
--      space is rich enough to carry CHSH violation), NOT that the foam has two
--      intrinsic parties.
--   2. The per-party basis rotations S_max assumes are not native foam ops (one
--      Born measurement reads the whole sym, not each qubit separately).
--   3. Deeper: the foam is a single linear append-only tape, TOTALLY ordered by
--      id. It has no spacelike-separated subsystems — any two measurements are
--      timelike (one before the other), so genuine correlations are common-cause
--      (via the definite shared ledger = a LOCAL HIDDEN VARIABLE, bound S ≤ 2) or
--      direct-cause (communication, a trivial violation). The very total-order
--      that makes the ledger a lossless record is the absence of the structure a
--      loophole-free Bell test needs.
-- So a computed S > 2 here means: the amplitudes live in a Hilbert space rich
-- enough for non-locality. It does NOT claim a loophole-free violation. The
-- genuine two-party question (a non-factorable JOINT amplitude over two contexts,
-- from co-occurrence) is the frontier this opens.

CREATE OR REPLACE FUNCTION foam.bell_demo()
  RETURNS TABLE (reading text, value double precision) LANGUAGE plpgsql AS $$
  DECLARE cid uuid := foam.caddr(foam.bytes('c'));
          s0 int := get_byte(convert_to('0','UTF8'),0); s1 int := get_byte(convert_to('1','UTF8'),0);
          s2 int := get_byte(convert_to('2','UTF8'),0); s3 int := get_byte(convert_to('3','UTF8'),0);
          a_re bigint; a_im bigint; b_re bigint; b_im bigint;
          c_re bigint; c_im bigint; d_re bigint; d_im bigint;
          det_re double precision; det_im double precision; det_abs double precision;
          nrm double precision; conc double precision; s_max double precision;
  BEGIN
    -- drive: c→'0' ×1, c→'1' ×2, c→'2' ×3, c→'3' ×4
    PERFORM foam.ingest_step(NULL, foam.bytes('c0c1c1c2c2c2c3c3c3c3'));

    SELECT re, im INTO a_re, a_im FROM foam.amp(cid, s0);
    SELECT re, im INTO b_re, b_im FROM foam.amp(cid, s1);
    SELECT re, im INTO c_re, c_im FROM foam.amp(cid, s2);
    SELECT re, im INTO d_re, d_im FROM foam.amp(cid, s3);

    -- det = z00·z11 − z01·z10 (complex)
    det_re := (a_re*d_re - a_im*d_im) - (b_re*c_re - b_im*c_im);
    det_im := (a_re*d_im + a_im*d_re) - (b_re*c_im + b_im*c_re);
    det_abs := sqrt(det_re*det_re + det_im*det_im);
    nrm := (a_re*a_re+a_im*a_im) + (b_re*b_re+b_im*b_im)
         + (c_re*c_re+c_im*c_im) + (d_re*d_re+d_im*d_im);
    conc := 2*det_abs / nrm;
    s_max := 2*sqrt(1 + conc*conc);

    RETURN QUERY VALUES
      ('amplitude det |z00·z11 − z01·z10|', det_abs),
      ('state norm Σ|z|²', nrm),
      ('concurrence C (0=product, 1=max entangled)', conc),
      ('CHSH S_max = 2√(1+C²)', s_max),
      ('classical bound', 2.0),
      ('Tsirelson bound 2√2', 2*sqrt(2.0));
  END; $$;

-- the per-(ctx,sym) complex amplitude (the abs-framed spectrum), as a helper.
CREATE OR REPLACE FUNCTION foam.amp(cid uuid, s int)
  RETURNS TABLE (re bigint, im bigint) LANGUAGE sql STABLE AS $$
  SELECT
    coalesce(sum(delta * CASE ((occ-1)%4) WHEN 0 THEN 1 WHEN 2 THEN -1 ELSE 0 END), 0),
    coalesce(sum(delta * CASE ((occ-1)%4) WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END), 0)
  FROM (SELECT delta, row_number() OVER (ORDER BY id) AS occ
        FROM foam.charge WHERE ctx = cid AND sym = s) e $$;

-- run it:  SELECT * FROM foam.bell_demo();
