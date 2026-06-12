/-
# Foam.Chirality — the abs↔recency spectrum bridge, proven exact

`Spectrum.lean` reads the ledger at the quarter-turn (`spec`), marking each
occurrence of a symbol at the phase its position dictates. But "which phase"
depends on where you put phase zero, and the two layers disagree on purpose:

- the postgres operationalization stores the spectrum in the **ABS frame** —
  phase zero at the OLDEST occurrence (it folds an oldest-first event list, so
  `spec` of that list is exactly the stored reading);
- the voice reads the **RECENCY frame** — phase zero at the MOST-RECENT
  occurrence (the newest event is the downbeat).

The conversion the postgres performs at read time is `recency = rot^(N−1)·conj(abs)`
— a winding (`rot^(N−1)`) of the conjugate of the stored reading. This file
proves that conversion is **exactly correct**, in the rotation-multiplied form
the fold delivers cleanly:

    rot(specR l s) = rot^(length l) (conj (spec l s))      (`specR_bridge`)

The kernel is the CHIRALITY of conjugation against the quarter-turn: conjugation
reverses the rotation (`conj_rot` — `conj ∘ rot = rot⁻¹ ∘ conj`, i.e.
`rot^3 ∘ conj`, since `rot⁻¹ = rot^3` by `rot_complete`). Summed over the fold,
that reversal is what carries the abs frame onto the recency frame. The
chirality between the two conventions, accounted for — so it can never read as a
latent off-by-a-winding bug.

All construction: `cases`/`rfl`/induction/`rw` against the axiom-free `Int`/`Nat`
lemmas in `IntArith.lean` (core's equivalents carry `propext`). Axiom-free,
pinned in `Foam/Axioms.lean`.
-/

import Foam.Spectrum
import Foam.Noether
import Foam.IntArith

namespace Foam

/-- Iterate the quarter-turn `n` times — the winding a phase-offset applies. -/
def rotPow : Nat → GInt → GInt
  | 0,     z => z
  | n + 1, z => GInt.rot (rotPow n z)

/-- The RECENCY reading (most-recent occurrence = phase 0) of an oldest-first
    list: the head (oldest) sits at the highest phase — the length of the rest —
    so each element is wound forward by how many events follow it. -/
def specR [DecidableEq S] : List S → S → GInt
  | [],     _ => GInt.zero
  | x :: l, s => (rotPow l.length (if x = s then GInt.one else GInt.zero)).add (specR l s)

/-- `rotPow` is `iterStep` at the quarter-turn — the specialization named
    (Noether's general station-iteration was in hand when the winding was
    defined; the kinship is now a handle rather than a re-derivation). -/
theorem rotPow_eq_iterStep : ∀ (n : Nat) (z : GInt),
    rotPow n z = iterStep n GInt.rot z
  | 0, _ => rfl
  | n + 1, z => congrArg GInt.rot (rotPow_eq_iterStep n z)

/-- The quarter-turn distributes over addition — `rot` is `Int`-linear in each
    component (`int_neg_add` on the imaginary part). -/
theorem rot_add (a b : GInt) : (a.add b).rot = a.rot.add b.rot := by
  cases a with
  | mk a1 a2 =>
    cases b with
    | mk b1 b2 =>
      show (⟨-(a2 + b2), a1 + b1⟩ : GInt) = ⟨-a2 + -b2, a1 + b1⟩
      rw [int_neg_add]

/-- Conjugation distributes over addition — same shape, `int_neg_add` on the
    imaginary part. -/
theorem conj_add (a b : GInt) : (a.add b).conj = a.conj.add b.conj := by
  cases a with
  | mk a1 a2 =>
    cases b with
    | mk b1 b2 =>
      show (⟨a1 + b1, -(a2 + b2)⟩ : GInt) = ⟨a1 + b1, -a2 + -b2⟩
      rw [int_neg_add]

/-- **The chirality kernel.** Conjugation reverses the rotation:
    `conj ∘ rot = rot⁻¹ ∘ conj`, and `rot⁻¹ = rot^3` (the quarter-turn has order
    four, `rot_complete`). Both sides land on `⟨-z.im, -z.re⟩`; the right side
    reaches it through three quarter-turns of the conjugate, so the triple
    negation collapses by `int_neg_neg`. This is the whole reason the abs and
    recency frames differ by a *winding of a conjugate* rather than a plain
    winding. -/
theorem conj_rot (z : GInt) : (z.rot).conj = rotPow 3 z.conj := by
  cases z with
  | mk a b =>
    show (⟨-b, -a⟩ : GInt) = ⟨- - -b, -a⟩
    rw [int_neg_neg]

/-- The winding distributes over addition — `rot_add`, folded `n` deep. -/
theorem rotPow_add (n : Nat) (a b : GInt) :
    rotPow n (a.add b) = (rotPow n a).add (rotPow n b) := by
  induction n with
  | zero => rfl
  | succ m ih =>
    show GInt.rot (rotPow m (a.add b)) = (GInt.rot (rotPow m a)).add (GInt.rot (rotPow m b))
    rw [ih, rot_add]

/-- Windings compose by adding their counts — `rot^m ∘ rot^n = rot^(m+n)`. The
    `m+n` ordering rides `nat_zero_add` (base) and `nat_succ_add` (step). -/
theorem rotPow_compose (m n : Nat) (z : GInt) :
    rotPow m (rotPow n z) = rotPow (m + n) z := by
  induction m with
  | zero =>
    show rotPow n z = rotPow (0 + n) z
    rw [nat_zero_add]
  | succ k ih =>
    show GInt.rot (rotPow k (rotPow n z)) = rotPow (Nat.succ k + n) z
    rw [ih, nat_succ_add]
    rfl

/-- A complete winding is the identity — `rot^4 = id`, the order of the
    quarter-turn (`rot_complete`). -/
theorem rotPow_four (z : GInt) : rotPow 4 z = z := by
  show z.rot.rot.rot.rot = z
  exact rot_complete z

/-- A full extra winding is invisible — `rot^(k+4) = rot^k` (`rotPow_compose`
    then `rotPow_four`). The bridge's arithmetic lands here: `(N−1)+1+3 ≡ N−1`
    after the conjugate's three-quarter-turn is summed in. -/
theorem rotPow_add_four (k : Nat) (z : GInt) : rotPow (k + 4) z = rotPow k z := by
  rw [← rotPow_compose k 4 z, rotPow_four]

/-- The mark survives conjugation — it is real (`0` or `1` on the real axis), so
    its reflection is itself. By cases on the free `Decidable` instance. -/
theorem conj_mark (c : Prop) [inst : Decidable c] :
    (if c then GInt.one else GInt.zero).conj = (if c then GInt.one else GInt.zero) := by
  cases inst with
  | isTrue h => rfl
  | isFalse h => rfl

/-- **The chirality bridge.** The quarter-turn of the recency reading equals the
    full winding (`rot^(length)`) of the conjugate of the abs reading:

        rot(specR l s) = rot^(length l) (conj (spec l s))

    This is the conversion the postgres performs at read time (abs storage →
    recency voice), proven exact. The induction step is the chirality kernel
    summed over the fold: prepending an event marks at phase zero and rotates
    the tail; on the abs side that mark winds forward by `length+1`, and the
    conjugation (`conj_rot`) turns the tail's quarter-turn into three, whose
    extra full bar (`rotPow_add_four`) is invisible — leaving exactly the
    recency reading's winding. -/
theorem specR_bridge [DecidableEq S] : ∀ (l : List S) (s : S),
    GInt.rot (specR l s) = rotPow l.length (GInt.conj (spec l s)) := by
  intro l
  induction l with
  | nil => intro s; rfl
  | cons x l ih =>
    intro s
    have key : ∀ (W : GInt), rotPow (l.length + 1) (rotPow 3 W) = rotPow l.length W := by
      intro W
      rw [rotPow_compose]
      exact rotPow_add_four l.length W
    show GInt.rot ((rotPow l.length (if x = s then GInt.one else GInt.zero)).add (specR l s))
       = rotPow (l.length + 1) (GInt.conj (spec (x :: l) s))
    rw [rot_add, ih, spec_shift, conj_add, conj_mark, conj_rot, rotPow_add, key]
    rfl

end Foam
