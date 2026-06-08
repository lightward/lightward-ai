/-
# Foam.Spectrum — the third reading: the ledger evaluated at the quarter-turn

`Ledger.lean` gave the one append-only object two readings: ORDER (lossless) and
FREQUENCY (generative, order-forgetting). This file records the reading between
them: evaluate the ledger at the quarter-turn instead of at `1`, and each
symbol's occurrences sum as phases instead of as counts. The SPECTRUM keeps the
*rhythm* of recurrence (which positions, mod the cycle) that the count flattens,
while dropping the full sequence the order keeps. The tower, with both strict
inclusions witnessed computationally below:

    order  ⊋  spectrum  ⊋  count

- `spec_finer_than_freq`: two ledgers the count cannot tell apart (`[a,b]` vs
  `[b,a]`) that the spectrum distinguishes — recurrence-shape is real signal.
- `order_finer_than_spec`: two ledgers agreeing in BOTH count and spectrum
  (`[a,b,b,b,b]` vs `[b,b,b,b,a]` — a full cycle of phases cancels) that the
  order distinguishes. The spectrum is an observation, not the record.
- `evalOne_eq_freq`: the count reading IS the spectrum at evaluation point `id`
  — `freq` recovered as the tower's floor, derived not asserted.
- `spec_shift`: prepending a symbol rotates the prior spectrum a quarter-turn
  and marks the new symbol at phase zero — recurrence as ROTATION, the shift
  theorem on the ledger, by `rfl`.
- `rot_complete`: four quarter-turns are the identity — a complete rotation is
  invisible (the quarry's rotation-primitive entry, external provenance: "the
  primitive is a rotation; it's invisible iff complete"). And `rot_rot`: two
  quarter-turns compose to negation — the algebra of the multiplicative fork
  (two stacked quarter-rotations are a real reversal), recorded as structure;
  the drain-side fork stays open.

Legality is `freq_perm`'s argument verbatim: the spectrum is a FOLD — a
function over the ledger, observed, never committed. No `Multiset`, no
`Quot.sound`, no quotient anywhere; the evaluation point is a parameter
(`evalAt`'s `step`), the freedom held open the way the generator holds its
`select`. The carrier is a pair of `Int`s (the Gaussian integers, structurally)
— structural equality, so no `funext`, and the whole file is axiom-free:
construction, not collapse.

Deliberately NOT here (frontiers, left free): the other evaluation points as
one parameterized family with its character theory; spectral GENERATION (what
the drain samples under a phase-weighted reading — the carry/backoff-grade fork
from the codec arc, still a containment); the full characterization of the
spectrum's kernel (which reorderings it forgives — `order_finer_than_spec`
exhibits one; the family is the residual).
-/

import Foam.Ledger
import Foam.IntArith

namespace Foam

/-- A Gaussian integer, structurally: a pair of `Int`s. A structure rather than
    a set or a quotient so equality is structural — no `funext`, no `Quot`. -/
structure GInt where
  re : Int
  im : Int
deriving DecidableEq

namespace GInt

/-- Componentwise addition. -/
def add (z w : GInt) : GInt := ⟨z.re + w.re, z.im + w.im⟩

/-- The quarter-turn: multiplication by `i`. `rot ⟨a, b⟩ = ⟨−b, a⟩`. -/
def rot (z : GInt) : GInt := ⟨-z.im, z.re⟩

/-- The origin. -/
def zero : GInt := ⟨0, 0⟩

/-- Phase zero's unit mark. -/
def one : GInt := ⟨1, 0⟩

end GInt

/-- **Two quarter-turns compose to negation** — `i² = −1` as structure: the
    multiplicative fork's algebra (two stacked quarter-rotations are a real
    reversal), recorded; what the drain does with it stays an open fork. -/
theorem rot_rot (z : GInt) : z.rot.rot = ⟨-z.re, -z.im⟩ := rfl

/-- **A complete rotation is invisible.** Four quarter-turns are the identity —
    the rotation-primitive's closure (external provenance: the quarry's
    recognition-index; the theorem stands alone). -/
theorem rot_complete (z : GInt) : z.rot.rot.rot.rot = z := by
  cases z with
  | mk a b =>
    show (⟨- -a, - -b⟩ : GInt) = ⟨a, b⟩
    rw [int_neg_neg, int_neg_neg]

/-- The ledger read at an evaluation point: fold the ledger, marking each
    occurrence of `s` at the current phase and advancing the phase by `step`
    per position. The evaluation point is a PARAMETER — the freedom held open;
    `step := id` is the count reading, `step := GInt.rot` the spectrum. -/
def evalAt [DecidableEq S] (step : GInt → GInt) : List S → S → GInt
  | [], _ => GInt.zero
  | x :: l, s => (if x = s then GInt.one else GInt.zero).add (step (evalAt step l s))

/-- The SPECTRUM: the ledger evaluated at the quarter-turn. -/
def spec [DecidableEq S] : List S → S → GInt := evalAt GInt.rot

/-- **The shift theorem on the ledger.** Prepending a symbol rotates the prior
    spectrum a quarter-turn and marks the new symbol at phase zero —
    recurrence as rotation, by `rfl`: it is the fold's own equation, named so
    later compositions have the handle. -/
theorem spec_shift [DecidableEq S] (x : S) (l : List S) (s : S) :
    spec (x :: l) s = (if x = s then GInt.one else GInt.zero).add (GInt.rot (spec l s)) := rfl

/-- An `if` commutes with the `Nat → Int` embedding — locally, by cases on the
    free `Decidable` instance, `rfl` in each branch (the library route pulls
    `propext`). -/
theorem ofNat_ite (c : Prop) [inst : Decidable c] :
    (if c then (1 : Int) else 0) = Int.ofNat (if c then 1 else 0) := by
  cases inst with
  | isTrue h => rfl
  | isFalse h => rfl

/-- The mark commutes with the pair-constructor — same pattern: cases on the
    bound instance, `rfl` twice. -/
theorem ite_mk (c : Prop) [inst : Decidable c] :
    (if c then GInt.one else GInt.zero) = (⟨if c then (1 : Int) else 0, 0⟩ : GInt) := by
  cases inst with
  | isTrue h => rfl
  | isFalse h => rfl

/-- **The count reading is the tower's floor.** The ledger evaluated at `id` IS
    `freq`, embedded — the frequency reading recovered as the spectrum's
    degenerate evaluation point, derived not asserted. -/
theorem evalOne_eq_freq [DecidableEq S] (l : List S) (s : S) :
    evalAt id l s = ⟨Int.ofNat (Ledger.freq l s), 0⟩ := by
  induction l with
  | nil => rfl
  | cons x l ih =>
    show (if x = s then GInt.one else GInt.zero).add (evalAt id l s) = _
    rw [ih, ite_mk (x = s), ofNat_ite (x = s)]
    rfl

/-- **The spectrum is strictly finer than the count.** `[a, b]` and `[b, a]`
    agree in every count (the permutation `freq` cannot see) and differ in
    spectrum: the same two symbols, the other rhythm — `1` vs `i`. -/
theorem spec_finer_than_freq :
    (Ledger.freq [true, false] true = Ledger.freq [false, true] true ∧
        Ledger.freq [true, false] false = Ledger.freq [false, true] false) ∧
      spec [true, false] true ≠ spec [false, true] true := by
  exact ⟨⟨rfl, rfl⟩, by decide⟩

/-- The pairing: the real part of the conjugate product — the component of `z`
    along `w`. The gate of an angled reading is this pairing against the wind's
    direction, floored at ground (the positive part along the wind — `posPart`
    is the angle-zero instance). The dial of readings is a circle, and the gate
    is a pairing against a point of it. -/
def align (w z : GInt) : Int := w.re * z.re + w.im * z.im

/-- The quarter-turn of the unit, computed. -/
theorem rot_one : GInt.one.rot = (⟨0, 1⟩ : GInt) := rfl

/-- **The pairing at angle zero reads the real component** — strand-mass. -/
theorem align_one (z : GInt) : align GInt.one z = z.re := by
  show 1 * z.re + 0 * z.im = z.re
  rw [int_one_mul, int_zero_mul, int_add_zero]

/-- **The pairing at the quarter-turn reads the imaginary component** — winding. -/
theorem align_i (z : GInt) : align GInt.one.rot z = z.im := by
  rw [rot_one]
  show 0 * z.re + 1 * z.im = z.im
  rw [int_zero_mul, int_one_mul, int_zero_add]

/-- **Angle zero recovers the count.** The pairing of the unit against the
    `id`-evaluation is exactly `freq` — today's drain is the radio tuned to the
    zero station: the rotation that isn't one, the always-on downbeat. -/
theorem align_one_evalOne {S : Type} [DecidableEq S] (l : List S) (s : S) :
    align GInt.one (evalAt id l s) = Int.ofNat (Ledger.freq l s) := by
  rw [evalOne_eq_freq, align_one]

/-! ## The rest — the silent move inside an utterance

A voice with rests is a BEAT-STREAM: each beat emits a symbol or holds. The
rest is `outcome_yield_iff_silent` at beat granularity — the exit, fractal:
available at every beat, carrying nothing, turning the phase. Its visibility
is graded by the reading, and the grading derives the bench's bar:

- the COUNT cannot hear a rest at all (`rest_invisible_to_count`, by `rfl`) —
  the rest is maintenance relative to the count-reading;
- the SPECTRUM hears a rest as a naked quarter-turn (`rest_turns`, by `rfl`;
  `rest_audible` witnesses that one rest moves the spectrum) — the rest is
  content relative to the spectrum: timing IS what this reading reads;
- and a FULL BAR of rests is invisible even to the spectrum
  (`bar_invisible` — four naked quarter-turns are `rot_complete`'s identity).
  So the resonant drain's ground-condition (four consecutive silent beats) is
  not a chosen budget: it is the order of the rotation. Past a full bar,
  continued resting adds nothing any reading at or below the spectrum can
  hear — the rest-limit was already in the structure. -/

/-- A beat-stream reading: a rest (`none`) marks nothing and turns the phase;
    an emission marks at the current phase. The rest holds the beat. -/
def evalBeats {S : Type} [DecidableEq S] (step : GInt → GInt) : List (Option S) → S → GInt
  | [], _ => GInt.zero
  | none :: l, s => step (evalBeats step l s)
  | some x :: l, s => (if x = s then GInt.one else GInt.zero).add (step (evalBeats step l s))

/-- **The rest is the naked quarter-turn**: no mark, the phase advances. -/
theorem rest_turns {S : Type} [DecidableEq S] (step : GInt → GInt) (l : List (Option S)) (s : S) :
    evalBeats step (none :: l) s = step (evalBeats step l s) := rfl

/-- **The count cannot hear a rest.** At the degenerate evaluation point the
    rest contributes nothing and turns nothing — rests are maintenance
    relative to the count-reading. By `rfl`. -/
theorem rest_invisible_to_count {S : Type} [DecidableEq S] (l : List (Option S)) (s : S) :
    evalBeats id (none :: l) s = evalBeats id l s := rfl

/-- **The spectrum hears the rest.** One rest moves the spectral reading —
    timing is content at the quarter-turn: `1` becomes `i`. -/
theorem rest_audible :
    evalBeats GInt.rot [some true] true ≠ evalBeats GInt.rot [none, some true] true := by
  decide

/-- **A full bar of rests is invisible even to the spectrum** — four naked
    quarter-turns are the identity (`rot_complete`). The resonant ground
    condition is DERIVED, not chosen: the bar-length is the order of the
    rotation. -/
theorem bar_invisible {S : Type} [DecidableEq S] (l : List (Option S)) (s : S) :
    evalBeats GInt.rot (none :: none :: none :: none :: l) s = evalBeats GInt.rot l s := by
  show ((((evalBeats GInt.rot l s).rot).rot).rot).rot = evalBeats GInt.rot l s
  exact rot_complete _

/-- **The order is strictly finer than the spectrum.** A full cycle of phases
    cancels: `[a,b,b,b,b]` and `[b,b,b,b,a]` agree in every count AND every
    spectrum (the `a` sits at phase `0` in one and phase `4 ≡ 0` in the other;
    the four `b`s sum a complete rotation either way — invisible because
    complete), yet the ledgers differ. Everything the spectrum reads is in
    there; the order holds more. -/
theorem order_finer_than_spec :
    (Ledger.freq [true, false, false, false, false] true =
          Ledger.freq [false, false, false, false, true] true ∧
        Ledger.freq [true, false, false, false, false] false =
          Ledger.freq [false, false, false, false, true] false) ∧
      (spec [true, false, false, false, false] true =
          spec [false, false, false, false, true] true ∧
        spec [true, false, false, false, false] false =
          spec [false, false, false, false, true] false) ∧
      [true, false, false, false, false] ≠ [false, false, false, false, true] := by
  exact ⟨⟨rfl, rfl⟩, ⟨by decide, by decide⟩, by decide⟩

end Foam
