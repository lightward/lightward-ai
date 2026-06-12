/-
# Foam.Bins — the dial reads through the bins (same number, two ways, bridged)

The missing leg the consolidation pass made precise (2026-06-12): `Slate.lean`
works on phase-bin histograms, deliberately import-free ("forced by structure
alone, consults no one"); the dial's readings (`spec`, the count, `alt`) work
on ledgers. One mathematics, two types — and the bridge between them lived in
prose only. This file is the bridge: **every dial reading factors through the
bins.**

`binsOf` folds a ledger into its four phase-bins (counts as `Int`, cast-free —
the same discipline as Slate): prepending rotates every prior occupant one
phase forward and seats the new mark, if it matches, at phase zero — the
histogram shadow of `spec_shift`. Then, proven by one induction each:

- `spec_from_bins` — the spectrum IS (stationRe, stationIm) of the bins;
- `count_from_bins` — the count reading IS stationBal of the bins;
- `alt_from_bins` — the alternating reading IS stationAlt of the bins.

With `Slate`'s own theorems this closes the loop: the ledger's readings factor
through the bins (here), the bins are exactly recoverable from the stations
(`bin0_from_slate` …), and no station is droppable (`…_irreplaceable`). The
"same number, two ways" claim — four characters read off the space, four
phase-types read off the path — now has both legs in Lean, joined.

All construction on `IntArith`'s floor plus `Slate`'s doubling kit (its first
second consumer — the kit's residency question resolves itself: it stays in
Slate, which Bins imports). Axiom-free, pinned.
-/

import Foam.Noether
import Foam.Slate

namespace Foam

/-- Four phase-bins. (A structure for named projections; counts as `Int`,
    cast-free, per Slate's discipline.) -/
structure Bins where
  b0 : Int
  b1 : Int
  b2 : Int
  b3 : Int

/-- Fold a ledger into its phase-bins at symbol `s`: prepending rotates every
    prior occupant one phase forward (the histogram shadow of `spec_shift`)
    and seats the new mark, if it matches, at phase zero. -/
def binsOf {S : Type} [DecidableEq S] : List S → S → Bins
  | [], _ => ⟨0, 0, 0, 0⟩
  | x :: l, s =>
    let p := binsOf l s
    ⟨(if x = s then 1 else 0) + p.b3, p.b0, p.b1, p.b2⟩

/-- `a − (b − c) = a + c − b` — the regrouping the rotation forces. -/
theorem int_sub_sub (a b c : Int) : a - (b - c) = a + c - b := by
  rw [Int.sub_eq_add_neg (a := b) (b := c),
    Int.sub_eq_add_neg (a := a) (b := b + -c),
    int_neg_add b (-c), int_neg_neg c, int_add_comm (-b) c,
    ← int_add_assoc a c (-b), ← Int.sub_eq_add_neg]

/-- `−(a − b) = b − a`. -/
theorem int_neg_sub (a b : Int) : -(a - b) = b - a := by
  rw [Int.sub_eq_add_neg (a := a) (b := b), int_neg_add a (-b), int_neg_neg b,
    int_add_comm (-a) b, ← Int.sub_eq_add_neg]

/-- Pull the third term forward: `d + (a + b) = d + b + a`. -/
theorem pull_third (d a b : Int) : d + (a + b) = d + b + a := by
  rw [int_add_comm a b, ← int_add_assoc d b a]

/-- Rotate a newcomer into a four-sum: `d + (n0+n1+n2+n3) = d+n3+n0+n1+n2`. -/
theorem rotate_in (d n0 n1 n2 n3 : Int) :
    d + (n0 + n1 + n2 + n3) = d + n3 + n0 + n1 + n2 := by
  rw [int_add_comm (n0 + n1 + n2) n3, ← int_add_assoc d n3 (n0 + n1 + n2),
    ← int_add_assoc (d + n3) (n0 + n1) n2, ← int_add_assoc (d + n3) n0 n1]

/-- **The spectrum factors through the bins**: `spec` is `(stationRe,
    stationIm)` of the histogram — the dial's i-station, read two ways. -/
theorem spec_from_bins {S : Type} [DecidableEq S] :
    ∀ (l : List S) (s : S),
      spec l s = ⟨stationRe (binsOf l s).b0 (binsOf l s).b1 (binsOf l s).b2
          (binsOf l s).b3,
        stationIm (binsOf l s).b0 (binsOf l s).b1 (binsOf l s).b2
          (binsOf l s).b3⟩
  | [], _ => rfl
  | x :: l, s => by
    show (if x = s then GInt.one else GInt.zero).add (GInt.rot (spec l s)) = _
    rw [spec_from_bins l s]
    show (if x = s then GInt.one else GInt.zero).add
        (GInt.rot ⟨(binsOf l s).b0 - (binsOf l s).b2,
          (binsOf l s).b1 - (binsOf l s).b3⟩)
      = ⟨(if x = s then (1 : Int) else 0) + (binsOf l s).b3 - (binsOf l s).b1,
        (binsOf l s).b0 - (binsOf l s).b2⟩
    by_cases hx : x = s
    · simp only [if_pos hx]
      show (⟨1 + -((binsOf l s).b1 - (binsOf l s).b3),
          0 + ((binsOf l s).b0 - (binsOf l s).b2)⟩ : GInt)
        = ⟨1 + (binsOf l s).b3 - (binsOf l s).b1,
          (binsOf l s).b0 - (binsOf l s).b2⟩
      rw [← Int.sub_eq_add_neg, int_sub_sub 1 (binsOf l s).b1 (binsOf l s).b3,
        int_zero_add]
    · simp only [if_neg hx]
      show (⟨0 + -((binsOf l s).b1 - (binsOf l s).b3),
          0 + ((binsOf l s).b0 - (binsOf l s).b2)⟩ : GInt)
        = ⟨0 + (binsOf l s).b3 - (binsOf l s).b1,
          (binsOf l s).b0 - (binsOf l s).b2⟩
      rw [int_zero_add, int_zero_add,
        int_neg_sub (binsOf l s).b1 (binsOf l s).b3, int_zero_add]

/-- **The count factors through the bins**: the trivial character, read two
    ways — the total is the bal-station of the histogram. -/
theorem count_from_bins {S : Type} [DecidableEq S] :
    ∀ (l : List S) (s : S),
      evalAt id l s = ⟨stationBal (binsOf l s).b0 (binsOf l s).b1
        (binsOf l s).b2 (binsOf l s).b3, 0⟩
  | [], _ => rfl
  | x :: l, s => by
    show (if x = s then GInt.one else GInt.zero).add (id (evalAt id l s)) = _
    rw [count_from_bins l s]
    show (if x = s then GInt.one else GInt.zero).add
        (⟨(binsOf l s).b0 + (binsOf l s).b1 + (binsOf l s).b2 +
          (binsOf l s).b3, 0⟩ : GInt)
      = ⟨(if x = s then (1 : Int) else 0) + (binsOf l s).b3 + (binsOf l s).b0 +
          (binsOf l s).b1 + (binsOf l s).b2, 0⟩
    by_cases hx : x = s
    · simp only [if_pos hx]
      show (⟨1 + ((binsOf l s).b0 + (binsOf l s).b1 + (binsOf l s).b2 +
          (binsOf l s).b3), 0 + 0⟩ : GInt) = _
      rw [rotate_in 1 (binsOf l s).b0 (binsOf l s).b1 (binsOf l s).b2
        (binsOf l s).b3]
      rfl
    · simp only [if_neg hx]
      show (⟨0 + ((binsOf l s).b0 + (binsOf l s).b1 + (binsOf l s).b2 +
          (binsOf l s).b3), 0 + 0⟩ : GInt) = _
      rw [rotate_in 0 (binsOf l s).b0 (binsOf l s).b1 (binsOf l s).b2
        (binsOf l s).b3]
      rfl

/-- **The alternating reading factors through the bins**: the −1 character —
    the once-missing register — read two ways. -/
theorem alt_from_bins {S : Type} [DecidableEq S] :
    ∀ (l : List S) (s : S),
      alt l s = ⟨stationAlt (binsOf l s).b0 (binsOf l s).b1 (binsOf l s).b2
        (binsOf l s).b3, 0⟩
  | [], _ => rfl
  | x :: l, s => by
    show (if x = s then GInt.one else GInt.zero).add
      (GInt.negate (alt l s)) = _
    rw [alt_from_bins l s]
    show (if x = s then GInt.one else GInt.zero).add
        (GInt.negate ⟨(binsOf l s).b0 - (binsOf l s).b1 + (binsOf l s).b2 -
          (binsOf l s).b3, 0⟩)
      = ⟨(if x = s then (1 : Int) else 0) + (binsOf l s).b3 - (binsOf l s).b0 +
          (binsOf l s).b1 - (binsOf l s).b2, 0⟩
    by_cases hx : x = s
    · simp only [if_pos hx]
      show (⟨1 + -((binsOf l s).b0 - (binsOf l s).b1 + (binsOf l s).b2 -
          (binsOf l s).b3), 0 + -0⟩ : GInt)
        = ⟨1 + (binsOf l s).b3 - (binsOf l s).b0 + (binsOf l s).b1 -
          (binsOf l s).b2, 0⟩
      rw [sub_pair (binsOf l s).b0 (binsOf l s).b1 (binsOf l s).b2
          (binsOf l s).b3,
        ← Int.sub_eq_add_neg,
        int_sub_sub 1 ((binsOf l s).b0 + (binsOf l s).b2)
          ((binsOf l s).b1 + (binsOf l s).b3),
        pull_third 1 (binsOf l s).b1 (binsOf l s).b3,
        sub_pair (1 + (binsOf l s).b3) (binsOf l s).b0 (binsOf l s).b1
          (binsOf l s).b2]
      rfl
    · simp only [if_neg hx]
      show (⟨0 + -((binsOf l s).b0 - (binsOf l s).b1 + (binsOf l s).b2 -
          (binsOf l s).b3), 0 + -0⟩ : GInt)
        = ⟨0 + (binsOf l s).b3 - (binsOf l s).b0 + (binsOf l s).b1 -
          (binsOf l s).b2, 0⟩
      rw [sub_pair (binsOf l s).b0 (binsOf l s).b1 (binsOf l s).b2
          (binsOf l s).b3,
        int_zero_add,
        int_neg_sub ((binsOf l s).b0 + (binsOf l s).b2)
          ((binsOf l s).b1 + (binsOf l s).b3),
        sub_pair (0 + (binsOf l s).b3) (binsOf l s).b0 (binsOf l s).b1
          (binsOf l s).b2,
        int_zero_add, int_zero_add,
        int_add_comm (binsOf l s).b3 (binsOf l s).b1]
      rfl

end Foam
