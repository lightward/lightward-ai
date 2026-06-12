/-
# Foam.Doubling — the agreement algebra (order arrives with the third dimension)

Tested at the table this morning (2026-06-12) and crystallized the same day.
The idea, Isaac's words: the shared 2D surface is *"enough for a beholder to
treat as a reference frame — enough for two beholders projecting through
either side of the reference frame to progressively approach agreement and
thereby entanglement of a third amplitude dimension."* The idea cohered with
four standing strands: the meet's two transferable invariants (the pairing AND
the chirality cross-pairing — a relative-phase convention crosses fiber-privacy,
so the 2D surface really is frame-grade); the two-mirror corridor (facing
reflective surfaces generate the axis between them — the circuit that winds);
the dichotomy's prediction (joint content factors through the floor, so a
genuinely new amplitude direction can live only in the constructed pair-seat —
whose larger fiber `Beholder.lean` typed and deferred); and **Cayley–Dickson**:
the division-ring ladder ℝ→ℂ→ℍ (povs 1→2→4) is not a list but a construction —
each rung is two copies of the previous rung bound by one new unit. *Iterated
agreement is how the dimensions are built, two-of-the-previous at a time.*

This file lands the destination at house scale: the doubling of foam's own
plane. `Doubled` is pairs of `GInt` — note the field names repeat `GInt`'s own
shape one level up (`re`, `im`, again); the doubling IS that repetition, foams
all the way down, not in a regressy way — under the Cayley–Dickson product
`(a,b)(c,d) = (ac − d̄b, da + bc̄)`. What is PROVEN:

- **The third direction is real and is nobody's** (`jay_sq`, `jay_outside`):
  the new unit squares to −1 — an amplitude direction, a genuine root of
  minus one, not a formal tag — and lies outside the embedded plane entirely:
  it belongs to neither beholder, exactly as the pair-seat's fiber predicted.
- **Order arrives exactly at the doubling** (`plane_commutes` +
  `order_arrives`): the embedded plane still commutes — where both beholders
  already were, order is indifferent — and the doubled units do not:
  `eye·jay ≠ jay·eye`. The number system acquires the ledger's own law
  (order matters) at precisely the rung where the agreement dimension enters.
  The algebra of entanglement remembers who spoke first.
- **The plane embeds faithfully and multiplicatively** (`embed_faithful`,
  `embed_mul`): the old world is recovered exactly inside the new one —
  nothing the beholders had is lost to the doubling — and the modulus carries
  across (`normSq_embed`, `normSq_jay`).

Cited, not claimed: the general Cayley–Dickson construction and its ladder
(this file is one rung, over ℤ[i] — the Lipschitz-quaternion grade); Euler's
four-square identity (the doubled norm is multiplicative — the two-square
`int_lagrange` is in `IntFloor`, the four-square is the bridge package's);
and the PROCESS — that two beholders *progressively approaching agreement*
converge to this algebra — which is the two-sided resolver, warm, named,
unbuilt. This file proves the destination exists and is shaped as the idea
said; how the walk arrives is the next candle.

All construction: `rfl`/`decide` on the units (DecidableEq is derived,
structural), `rw` against `IntFloor`'s axiom-free floor for the variable
theorems. Axiom-free, pinned.
-/

import Foam.Noether
import Foam.IntFloor

namespace Foam

/-- The plane's own product — ℤ[i] multiplication, defined here because the
    plane alone never needed it: it is the doubling that multiplies. (Negation
    was already named: `GInt.negate`, Noether — the third character's
    evaluation point. A first draft reinvented it here as `neg`; the dedup is
    recorded in the algebra index at GInt's birthplace, Spectrum.) -/
def GInt.mul (z w : GInt) : GInt :=
  ⟨z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re⟩

/-- The plane commutes — order is indifferent within one beholder's world. -/
theorem GInt.mul_comm (z w : GInt) : z.mul w = w.mul z := by
  show (⟨z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re⟩ : GInt)
    = ⟨w.re * z.re - w.im * z.im, w.re * z.im + w.im * z.re⟩
  rw [int_mul_comm z.re w.re, int_mul_comm z.im w.im,
    int_mul_comm z.re w.im, int_mul_comm z.im w.re,
    int_add_comm (w.im * z.re) (w.re * z.im)]

theorem GInt.zero_mul (z : GInt) : GInt.zero.mul z = GInt.zero := by
  show (⟨0 * z.re - 0 * z.im, 0 * z.im + 0 * z.re⟩ : GInt) = ⟨0, 0⟩
  rw [int_zero_mul z.re, int_zero_mul z.im]
  rfl

theorem GInt.add_zero (z : GInt) : z.add GInt.zero = z := by
  show (⟨z.re + 0, z.im + 0⟩ : GInt) = z
  rw [int_add_zero z.re, int_add_zero z.im]

theorem GInt.negate_zero : GInt.zero.negate = GInt.zero := rfl

theorem GInt.conj_zero : GInt.zero.conj = GInt.zero := rfl

/-- The doubled algebra: pairs of plane-elements — the Cayley–Dickson rung
    over the house's own plane. The field names repeat `GInt`'s shape one
    level up, because the doubling is that repetition. -/
structure Doubled where
  re : GInt
  im : GInt
deriving DecidableEq

namespace Doubled

/-- Cayley–Dickson multiplication: `(a,b)(c,d) = (ac − d̄b, da + bc̄)`. -/
def mul (x y : Doubled) : Doubled :=
  ⟨(x.re.mul y.re).add (y.im.conj.mul x.im).negate,
   (y.im.mul x.re).add (x.im.mul y.re.conj)⟩

/-- The plane, embedded: the world both beholders already shared. -/
def embed (z : GInt) : Doubled := ⟨z, GInt.zero⟩

/-- The agreement direction: the unit belonging to neither beholder's plane —
    the third amplitude dimension, as an element. -/
def jay : Doubled := ⟨GInt.zero, GInt.one⟩

/-- The plane's own quarter-turn unit, embedded. -/
def eye : Doubled := embed ⟨0, 1⟩

/-- The squared modulus of the doubled element: both components' moduli,
    summed — the conserved quantity, one rung up. -/
def normSq (x : Doubled) : Int := x.re.normSq + x.im.normSq

/-- The embedding is faithful: the plane is recovered exactly. -/
theorem embed_faithful (z : GInt) : (embed z).re = z := rfl

/-- **The agreement direction is outside the plane.** `jay` is no embedded
    element — for any `z` at all. The third dimension is genuinely new:
    neither beholder brought it, exactly as the pair-seat's larger fiber
    predicted. -/
theorem jay_outside (z : GInt) : jay ≠ embed z :=
  fun h => absurd (show (1 : Int) = 0 from congrArg (fun d => d.im.re) h)
    (by decide)

/-- **The agreement direction is an amplitude direction**: `jay² = −1`. A
    genuine root of minus one, new to the system — not a formal tag. -/
theorem jay_sq : jay.mul jay = embed GInt.one.negate := by decide

/-- **Order arrives at the doubling, half 1: the doubled units do not
    commute.** `eye·jay ≠ jay·eye` — the agreement algebra remembers who
    spoke first. The number system acquires the ledger's law at exactly the
    rung where the third dimension enters. -/
theorem order_arrives : eye.mul jay ≠ jay.mul eye := by decide

/-- The plane's product, carried through the embedding exactly: nothing the
    beholders had is lost or changed by the doubling. -/
theorem embed_mul (z w : GInt) : (embed z).mul (embed w) = embed (z.mul w) := by
  show Doubled.mk ((z.mul w).add (GInt.zero.conj.mul GInt.zero).negate)
      ((GInt.zero.mul z).add (GInt.zero.mul w.conj))
    = Doubled.mk (z.mul w) GInt.zero
  rw [GInt.conj_zero, GInt.zero_mul GInt.zero, GInt.negate_zero,
    GInt.add_zero (z.mul w), GInt.zero_mul z, GInt.zero_mul w.conj]
  rfl

/-- **Order arrives at the doubling, half 2: the embedded plane still
    commutes.** Where both beholders already were, order stays indifferent —
    so noncommutativity enters the system at precisely the doubling, not
    before. -/
theorem plane_commutes (z w : GInt) :
    (embed z).mul (embed w) = (embed w).mul (embed z) := by
  rw [embed_mul z w, embed_mul w z, GInt.mul_comm z w]

/-- The modulus carries across the embedding unchanged. -/
theorem normSq_embed (z : GInt) : (embed z).normSq = z.normSq :=
  int_add_zero z.normSq

/-- The agreement direction has unit modulus: a direction, not a magnitude. -/
theorem normSq_jay : jay.normSq = 1 := by decide

end Doubled

end Foam
