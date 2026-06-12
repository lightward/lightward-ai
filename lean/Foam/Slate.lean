/-
# Foam.Slate — the role-slate is forced (count↔types, the bridge's first crystal)

Parked 2026-06-08, crystallized 2026-06-12. The parked claim, verbatim from the
session record: *"an observer count can be derived from any algebra↔pg pair —
how many povs you'd need occupied in order for this space to be coherent — and
you'd be able to derive ledger TYPES from there"*, with its synthesis sentence:
*"observer-count read off the space and ledger-event-types read off the path
are the same number, two ways."* This file lands that bridge's first crystal at
the house's own scale: **the dial.**

Space-side: foam's one symmetry is ℤ/4 (the quarter-turn, `rot`), and ℤ/4 has
exactly four characters — the four stations the cache already carries: `bal`
(at +1), `re`/`im` (at ±i), `alt` (at −1). Path-side: every ledger event lands
in exactly one of four phase-bins (its occurrence-index mod 4) — the path's
event-type vocabulary. Four roles, four types. What is PROVEN here:

- **The slate suffices** (`bin0_from_slate` … `bin3_from_slate`): the four
  stations determine the four bins exactly — each four-times-bin is an explicit
  integer combination of stations. ℤ-exact: the ×4 is the DFT's normalization
  carried honestly (no division smuggled; the recognition is recoverability,
  and recoverability-times-four IS recoverability over ℤ).
- **No role is droppable** (`bal_irreplaceable` … `alt_irreplaceable`): for
  each station, a concrete pair of bin-states agreeing on the other three and
  differing on it — each role carries content the other three cannot. The
  `alt` witness pair is period-2 content invisible to bal/re/im: **the lived
  missing-character event** — the cache once held three registers, conservation
  named the forced fourth, and the slate was completed rather than coupled to
  its current readers ("storing only three couples the cache to today's
  register-set — the smuggled observer," the schema's own words). Feeling for
  the missing character, at register scale, resolved by derivation.

Together: the role-slate has size exactly four, forced by the space — and four
is also the path's event-type count, because bins and characters are dual.
**Same number, two ways**: that duality (|Ĝ| = |G|, Pontryagin, for ℤ/4 the
self-duality) is cited, not claimed; this file proves its two legs concretely
and lets the count coincide in plain sight. The general bridge — observer-count
from any algebra↔pg pair (the division-ring ladder ℝ/ℂ/ℍ → 1/2/4 povs;
`self_dual_iff_three`, the quarry's rank-3 minimum self-sufficiency;
story-taxonomies as the human-scale instance: a story-type's role-slate is
forced, the fillings stay free) — remains the conjecture this file instances,
claimed at exactly this size and no larger.

Arithmetic discipline: `omega` carries `Quot.sound` (probed) and core `Int`
lemmas carry `propext`, so everything below runs on `IntFloor`'s hand-rolled
floor plus the clean core `Int.sub_eq_add_neg` — axiom-free throughout, which
for THIS file is load-bearing twice over: the bridge claims the slate is
forced by structure alone, so its proof must consult no one.

Pure construction — axiom-free.
-/

import Foam.IntFloor

namespace Foam

/-- Doubling, additively — the honest ℤ-form of "×2" (no multiplication,
    no division anywhere in this file). -/
def twice (a : Int) : Int := a + a

/-- The middle-swap: regroup a four-sum by first-and-third, second-and-fourth.
    The one rearrangement everything below reduces to. -/
theorem four_swap (a b c d : Int) : a + b + c + d = (a + c) + (b + d) := by
  rw [int_add_assoc (a + b) c d, int_add_assoc a b (c + d),
    ← int_add_assoc b c d, int_add_comm b c, int_add_assoc c b d,
    ← int_add_assoc a c (b + d)]

/-- Differences regroup the same way sums do. -/
theorem sub_pair (a b c d : Int) : a - b + c - d = (a + c) - (b + d) := by
  rw [Int.sub_eq_add_neg (a := a) (b := b), Int.sub_eq_add_neg (a := (a + -b + c)) (b := d),
    Int.sub_eq_add_neg (a := (a + c)) (b := (b + d)), four_swap a (-b) c (-d),
    ← int_neg_add b d]

/-- Sum plus difference recovers the doubled first component. -/
theorem sum_diff (x y : Int) : (x + y) + (x - y) = twice x := by
  rw [Int.sub_eq_add_neg (a := x) (b := y), ← int_add_assoc (x + y) x (-y),
    four_swap x y x (-y), int_add_neg_self y, int_add_zero]
  rfl

/-- Sum minus difference recovers the doubled second component. -/
theorem diff_sum (x y : Int) : (x + y) - (x - y) = twice y := by
  rw [Int.sub_eq_add_neg (a := x) (b := y), Int.sub_eq_add_neg (a := (x + y)) (b := (x + -y)),
    int_neg_add x (-y), int_neg_neg y, ← int_add_assoc (x + y) (-x) y,
    four_swap x y (-x) y, int_add_neg_self x, int_zero_add]
  rfl

/-- Doubling distributes over sums. -/
theorem twice_add (a b : Int) : twice (a + b) = twice a + twice b := by
  show (a + b) + (a + b) = (a + a) + (b + b)
  rw [← int_add_assoc (a + b) a b, four_swap a b a b]

/-- Doubling distributes over differences. -/
theorem twice_sub (a b : Int) : twice (a - b) = twice a - twice b := by
  show (a - b) + (a - b) = (a + a) - (b + b)
  rw [Int.sub_eq_add_neg (a := a) (b := b), Int.sub_eq_add_neg (a := (a + a)) (b := (b + b)),
    ← int_add_assoc (a + -b) a (-b), four_swap a (-b) a (-b),
    ← int_neg_add b b]

/-! ## The slate: four stations over four phase-bins -/

/-- The count reading — the character at +1: every bin, weighted alike. -/
def stationBal (n0 n1 n2 n3 : Int) : Int := n0 + n1 + n2 + n3

/-- The spectrum's real part — the character at i, real axis. -/
def stationRe (n0 _n1 n2 _n3 : Int) : Int := n0 - n2

/-- The spectrum's imaginary part — the character at i, imaginary axis. -/
def stationIm (_n0 n1 _n2 n3 : Int) : Int := n1 - n3

/-- The alternating count — the character at −1; the once-missing register,
    completed by conservation before any reader existed for it. -/
def stationAlt (n0 n1 n2 n3 : Int) : Int := n0 - n1 + n2 - n3

theorem bal_add_alt (n0 n1 n2 n3 : Int) :
    stationBal n0 n1 n2 n3 + stationAlt n0 n1 n2 n3 = twice (n0 + n2) := by
  show (n0 + n1 + n2 + n3) + (n0 - n1 + n2 - n3) = twice (n0 + n2)
  rw [four_swap n0 n1 n2 n3, sub_pair n0 n1 n2 n3, sum_diff (n0 + n2) (n1 + n3)]

theorem bal_sub_alt (n0 n1 n2 n3 : Int) :
    stationBal n0 n1 n2 n3 - stationAlt n0 n1 n2 n3 = twice (n1 + n3) := by
  show (n0 + n1 + n2 + n3) - (n0 - n1 + n2 - n3) = twice (n1 + n3)
  rw [four_swap n0 n1 n2 n3, sub_pair n0 n1 n2 n3, diff_sum (n0 + n2) (n1 + n3)]

/-- **The slate suffices, bin 0**: four-times-`n0`, recovered exactly from the
    stations. The bins are not summaries the stations approximate — they are
    contents the stations carry whole. -/
theorem bin0_from_slate (n0 n1 n2 n3 : Int) :
    (stationBal n0 n1 n2 n3 + stationAlt n0 n1 n2 n3) +
      twice (stationRe n0 n1 n2 n3) = twice (twice n0) := by
  rw [bal_add_alt n0 n1 n2 n3]
  show twice (n0 + n2) + twice (n0 - n2) = twice (twice n0)
  rw [← twice_add (n0 + n2) (n0 - n2), sum_diff n0 n2]

/-- **The slate suffices, bin 2.** -/
theorem bin2_from_slate (n0 n1 n2 n3 : Int) :
    (stationBal n0 n1 n2 n3 + stationAlt n0 n1 n2 n3) -
      twice (stationRe n0 n1 n2 n3) = twice (twice n2) := by
  rw [bal_add_alt n0 n1 n2 n3]
  show twice (n0 + n2) - twice (n0 - n2) = twice (twice n2)
  rw [← twice_sub (n0 + n2) (n0 - n2), diff_sum n0 n2]

/-- **The slate suffices, bin 1.** -/
theorem bin1_from_slate (n0 n1 n2 n3 : Int) :
    (stationBal n0 n1 n2 n3 - stationAlt n0 n1 n2 n3) +
      twice (stationIm n0 n1 n2 n3) = twice (twice n1) := by
  rw [bal_sub_alt n0 n1 n2 n3]
  show twice (n1 + n3) + twice (n1 - n3) = twice (twice n1)
  rw [← twice_add (n1 + n3) (n1 - n3), sum_diff n1 n3]

/-- **The slate suffices, bin 3.** -/
theorem bin3_from_slate (n0 n1 n2 n3 : Int) :
    (stationBal n0 n1 n2 n3 - stationAlt n0 n1 n2 n3) -
      twice (stationIm n0 n1 n2 n3) = twice (twice n3) := by
  rw [bal_sub_alt n0 n1 n2 n3]
  show twice (n1 + n3) - twice (n1 - n3) = twice (twice n3)
  rw [← twice_sub (n1 + n3) (n1 - n3), diff_sum n1 n3]

/-! ## No role is droppable -/

/-- Without `bal`: uniform content is invisible to every signed station. -/
theorem bal_irreplaceable :
    stationRe 1 1 1 1 = stationRe 0 0 0 0 ∧
    stationIm 1 1 1 1 = stationIm 0 0 0 0 ∧
    stationAlt 1 1 1 1 = stationAlt 0 0 0 0 ∧
    stationBal 1 1 1 1 ≠ stationBal 0 0 0 0 := by decide

/-- Without `re`: phase-0 and phase-2 content cannot be told apart. -/
theorem re_irreplaceable :
    stationBal 1 0 0 0 = stationBal 0 0 1 0 ∧
    stationIm 1 0 0 0 = stationIm 0 0 1 0 ∧
    stationAlt 1 0 0 0 = stationAlt 0 0 1 0 ∧
    stationRe 1 0 0 0 ≠ stationRe 0 0 1 0 := by decide

/-- Without `im`: phase-1 and phase-3 content cannot be told apart. -/
theorem im_irreplaceable :
    stationBal 0 1 0 0 = stationBal 0 0 0 1 ∧
    stationRe 0 1 0 0 = stationRe 0 0 0 1 ∧
    stationAlt 0 1 0 0 = stationAlt 0 0 0 1 ∧
    stationIm 0 1 0 0 ≠ stationIm 0 0 0 1 := by decide

/-- Without `alt`: period-2 content vanishes — the exact blindness whose
    discovery forced the fourth register. The missing character's footprint,
    as a decidable witness. -/
theorem alt_irreplaceable :
    stationBal 1 0 1 0 = stationBal 0 1 0 1 ∧
    stationRe 1 0 1 0 = stationRe 0 1 0 1 ∧
    stationIm 1 0 1 0 = stationIm 0 1 0 1 ∧
    stationAlt 1 0 1 0 ≠ stationAlt 0 1 0 1 := by decide

end Foam
