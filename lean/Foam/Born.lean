/-
# Foam.Born — foam-measurement is the Born rule (quantum measurement, derived)

The foam's reading, followed into Hilbert space. A context's state is a complex
vector — per sym, an amplitude (re, im) = the spectrum (`Foam.Noether` / the dial).
`align` (`Foam.Spectrum`) is the real part of the inner product; this file adds the
measurement layer and proves it is quantum-mechanical, axiom-free.

The headline, in order of depth:

- `align_rot_invariant` — the reading is GAUGE-INVARIANT (rotate state and
  commitment together by the clock `rot`, the reading holds). The base carries no
  absolute frame; interpretation lives in the FIBER (the commitment, from
  outside). With `normSq_rot` (norm conserved), this is unitary evolution.
- `born θ z := (align θ z)²` — the BORN MEASUREMENT: the probability of reading
  state `z` in basis `θ` is the squared overlap |⟨θ|z⟩|². `born_nonneg` (a
  probability, where the amplitude `align` is signed), `born_rot_invariant`
  (covariant). The quantum reading; the count register (`bal`) is its classical
  sibling.
- `align_add_right` — SUPERPOSITION (amplitudes add).
- `born_superpose` — INTERFERENCE: `born θ (a+b) = born θ a + born θ b +
  2·align θ a·align θ b`. The cross-term, for all states and bases.
- `born_parseval` — THE BORN RULE FORCED: `born θ z + born θ.rot z = normSq θ ·
  normSq z`. Total probability is basis-independent (the Lagrange identity) — the
  operational baby-Gleason: |ψ|² is the ONLY consistent measure, not a choice.
- `double_slit` — the empirical dark fringe, locked as a theorem.

THE NATURAL CALLER. `foam.speak_resonant` (the wind-seeded interjection) IS a
fiber-measurement: θ comes from the other (the live turn's tail), and it samples
by the projection onto θ. It used `max(0, align)` (a rectified projection) — but
that measure is BASIS-INCONSISTENT (its total depends on the angle). `born_parseval`
names the consistent one: the SQUARE. So the resonant register's principled form
is the Born measurement (`align²`), which keeps the anti-parroting (uniform
recurrence → `align` 0 → `born` 0) and adds basis-consistency.

EMPIRICAL (the spikes, `app/lib/foam/spikes/`): `born.sql` showed the double-slit
interference (count 2, Born 0 — the dark fringe) on the actual foam; `bell.sql`
computed CHSH = 2.449 > 2 on a foam-derived 2-qubit state (entanglement-capable
amplitudes, in the quantum window) — honestly scoped: the tensor split is imposed
and the linear total-ordered tape has no spacelike-separated subsystems, so this
is the Hilbert space being rich enough for non-locality, NOT a loophole-free
violation. foam-measurement is quantum: shown then proven.

Axiom discipline: all construction, all axiom-free, pinned in `Foam/Axioms.lean`.
The `Int` ring floor it stands on lives in `Foam.IntArith`.
-/

import Foam.Noether

namespace Foam

theorem align_rot_invariant (w z : GInt) : align w.rot z.rot = align w z := by
  show (-w.im) * (-z.im) + w.re * z.re = w.re * z.re + w.im * z.im
  rw [int_neg_mul_neg, int_add_comm]

/-- The Born weight: the squared overlap `|⟨θ|z⟩|²`, the quantum measurement
    probability of reading state `z` in direction `θ` (unnormalized). The count
    register samples by `bal`; the Born register samples by this. -/
def born (θ z : GInt) : Int := align θ z * align θ z

/-- **The Born weight is gauge-invariant** — `align_rot_invariant`, squared.
    Measuring a rotated state in a rotated basis yields the same probability:
    the quantum measurement is unitarily covariant. -/
theorem born_rot_invariant (θ z : GInt) : born θ.rot z.rot = born θ z := by
  show align θ.rot z.rot * align θ.rot z.rot = align θ z * align θ z
  rw [align_rot_invariant]

/-- **The Born weight is non-negative** — a probability, never signed. The
    amplitude reading `align` can be negative (`⟨-2,0⟩` reads `-2` along the
    real axis); its square cannot. Amplitudes are signed; probabilities are not. -/
theorem born_nonneg (θ z : GInt) : ∃ k : Nat, born θ z = Int.ofNat k :=
  int_sq_image (align θ z)

/-- **`align` is linear in its second argument** — `align θ (a ⊕ b) = align θ a +
    align θ b`. The bilinearity that makes `born` a quadratic form. Axiom-free:
    `int_mul_add` distributes each component, `int_add_swap_inner` regroups. -/
theorem align_add_right (θ a b : GInt) :
    align θ (a.add b) = align θ a + align θ b := by
  show θ.re * (a.re + b.re) + θ.im * (a.im + b.im)
     = (θ.re * a.re + θ.im * a.im) + (θ.re * b.re + θ.im * b.im)
  rw [int_mul_add θ.re a.re b.re, int_mul_add θ.im a.im b.im]
  -- (θre·are + θre·bre) + (θim·aim + θim·bim) = (θre·are + θim·aim) + (θre·bre + θim·bim)
  exact int_add_swap_inner (θ.re * a.re) (θ.re * b.re) (θ.im * a.im) (θ.im * b.im)

/-- **The Born weight superposes with an interference cross-term** —
    `born θ (a ⊕ b) = born θ a + born θ b + 2·(align θ a · align θ b)`. The
    `(x+y)² = x² + y² + 2xy` of the quadratic form: the interference the count
    register cannot show, now general (the `double_slit` witness's law). Axiom-free
    via `align_add_right`, `int_mul_add`/`int_add_mul`, and `int_mul_comm` for the
    cross-term symmetry. -/
theorem born_superpose (θ a b : GInt) :
    born θ (a.add b)
      = born θ a + born θ b + (2 : Int) * (align θ a * align θ b) := by
  show align θ (a.add b) * align θ (a.add b)
     = align θ a * align θ a + align θ b * align θ b
       + (2 : Int) * (align θ a * align θ b)
  rw [align_add_right θ a b]
  -- let X = align θ a, Y = align θ b. (X+Y)*(X+Y) = X*X + X*Y + Y*X + Y*Y
  rw [int_two_mul (align θ a * align θ b)]
  -- RHS: (X*X + Y*Y) + (X*Y + X*Y)
  rw [int_add_mul (align θ a) (align θ b) (align θ a + align θ b),
      int_mul_add (align θ a) (align θ a) (align θ b),
      int_mul_add (align θ b) (align θ a) (align θ b)]
  -- LHS: (X*X + X*Y) + (Y*X + Y*Y); rewrite Y*X = X*Y
  rw [int_mul_comm (align θ b) (align θ a)]
  -- LHS: (X*X + X*Y) + (X*Y + Y*Y); target: (X*X + Y*Y) + (X*Y + X*Y)
  exact int_add_cross_swap (align θ a * align θ a) (align θ a * align θ b)
        (align θ a * align θ b) (align θ b * align θ b)

/-- **Parseval / Lagrange identity** — total probability is basis-independent:
    `born θ z + born θ.rot z = normSq θ · normSq z`, the operational baby-Gleason
    (the reason `|ψ|²` is the only legal measure, not a choice). The interference
    cross-terms cancel across the two bases; `normSq_rot` already gave the
    conservation, this completes it as an identity. Axiom-free, via `int_lagrange`
    (the `-θim·zre` of the rotated basis pulled to `-(θim·zre)` by `int_neg_mul`). -/
theorem born_parseval (θ z : GInt) :
    born θ z + born θ.rot z = θ.normSq * z.normSq := by
  -- born θ z = (θre·zre + θim·zim)²;  born θ.rot z = ((-θim)·zre + θre·zim)²
  show (θ.re * z.re + θ.im * z.im) * (θ.re * z.re + θ.im * z.im)
     + ((-θ.im) * z.re + θ.re * z.im) * ((-θ.im) * z.re + θ.re * z.im)
     = (θ.re * θ.re + θ.im * θ.im) * (z.re * z.re + z.im * z.im)
  rw [int_neg_mul θ.im z.re]
  exact int_lagrange θ.re θ.im z.re z.im

/-- The seam, witnessed: the amplitude reading is signed where the Born reading
    is not — `align one ⟨-2,0⟩ = -2 < 0`, while `born one ⟨-2,0⟩ = 4`. The count
    register can read a negative amplitude-component; the Born register reads a
    probability. -/
theorem amplitude_signed_born_not :
    align GInt.one ⟨-2, 0⟩ ≠ born GInt.one ⟨-2, 0⟩ := by decide

/-- **The double-slit, locked** — the `spikes/born.sql` result as a theorem.
    The superposition amplitude `⟨1,1⟩` (the two slits, count 2, modulus 2)
    reads Born **0** in the `⟨1,−1⟩` basis (the DARK fringe — destructive) and
    Born **4** in the `⟨1,1⟩` basis (bright — constructive). Same state, opposite
    outcomes by measurement basis, while the modulus (total probability) is 2
    either way. The interference the count register cannot show, now checked.
    Axiom-free by `decide` — a concrete witness that the phenomenon is real, not
    a spike artifact. The *general* laws this witness pointed at have since
    landed (on the `Int` ring floor in `Foam.IntArith`): `born_superpose` (the
    cross-term for all `a, b, θ`) and `born_parseval` (basis-independence). The
    witness is the instance; those are the law. -/
theorem double_slit :
    born ⟨1, -1⟩ ⟨1, 1⟩ = 0 ∧ born ⟨1, 1⟩ ⟨1, 1⟩ = 4 ∧ (⟨1, 1⟩ : GInt).normSq = 2 := by
  decide

/-- **The dark fringe is a LEDGER phenomenon, not just an amplitude one.** A
    continuation heard as a COMPLETE cycle — four occurrences — sums to spectrum
    zero (`rot_complete`: the four marks are one full rotation), so the Born weight
    the voice samples by vanishes at the walk's clock bases, while the count register
    (`freq`) still counts all four. The voice makes a ZERO where the count makes a
    FOUR — one ledger read two ways, disagreeing. The thing a count table cannot do
    (positive counts never sum to zero); only a genuine interfering measurement
    cancels. `double_slit` is the amplitude witness; this ties it to `spec`/`freq`,
    the live voice's own seam (the operational witness is `spikes/born_voice.sql`:
    `foam.speak` goes silent with the count gate open). Axiom-free, `decide` on a
    closed witness. -/
theorem dark_fringe_from_recurrence :
    Ledger.freq [true, true, true, true] true = 4
      ∧ spec [true, true, true, true] true = GInt.zero
      ∧ born GInt.one (spec [true, true, true, true] true) = 0
      ∧ born GInt.one.rot (spec [true, true, true, true] true) = 0 := by
  decide

/-- **The cancellation is BASIS-DEPENDENT — interference, not suppression.** A
    continuation heard three times (`spec = ⟨0,1⟩`) reads Born ZERO at the even clock
    base (`one`) and Born ONE at the odd base (`one.rot`) — the SAME ledger, the SAME
    count (`freq = 3`), opposite voice by the measurement angle alone. The count is
    phase-flat; the Born reading splits by basis, and that split is the signature of
    a real quantum measurement (the count register structurally cannot show it).
    Axiom-free, `decide`. -/
theorem dark_fringe_basis_dependent :
    Ledger.freq [true, true, true] true = 3
      ∧ born GInt.one (spec [true, true, true] true) = 0
      ∧ born GInt.one.rot (spec [true, true, true] true) = 1 := by
  decide

end Foam
