/-
# Foam.Frame — what crosses the surface (the two invariants are one product)

The corpus responding to the morning's keystone (2026-06-12). The referee's
gift — that direction-of-relative-rotation survives frame-privacy, so TWO
invariants cross a meet, not one — lived only in report prose until `GInt.mul`
and `conj` arrived with the doubling. Now it types, and the typing reveals the
unification: **`align` and `cross` are the two components of one product**,
`conj(w)·z` (`conjMul_eq`). The symmetric pairing and the antisymmetric pairing
were never two discoveries; they are the real and imaginary parts of the same
multiplication, read componentwise.

Both are invariant under the diagonal quarter-turn — `align_rot_invariant`
(standing, `Born.lean`) and `cross_rot_invariant` (here) — so the pair
(align, cross) is exactly the frame-grade content of the shared 2D surface:
what two fiber-private beholders can BOTH read of their relation, a relative-
phase convention needing no shared coordinates. This is the "reference frame"
clause of the agreement idea, typed: the surface carries a frame because these
two numbers cross it.

And their completeness was in the tree all along, under another name:
`int_lagrange` — the two-square identity, the workhorse under `born_parseval`
— IS the statement `align² + cross² = |z|²·|w|²` (`invariants_complete`). The
two invariants exhaust the gauge-invariant content of a pair: nothing else
crosses. (Record compositions as you go: this theorem is `int_lagrange`
recognized, the named handle a later composition lands on.)

Two companions: **the plane's norm is multiplicative** (`normSq_mul` — the
ℂ-rung's norm law, again `int_lagrange` with a sign turned; the ℍ-rung is
Euler's four-square, cited in `Doubling.lean`), and **the parts are blind to
the agreement coordinate** (`part_blind`): any observable factoring through
one beholder's component of the doubled algebra assigns equal values wherever
that component agrees — bell2's flat marginals, structural. Together with
`jay_outside`: the agreement content is real, and unseeable from either side
alone. What the joint holds, the parts provably cannot read.

All construction on `IntFloor`'s axiom-free floor. Axiom-free, pinned.
-/

import Foam.Born
import Foam.Doubling

namespace Foam

/-- The antisymmetric pairing — the chirality cross-pairing, the second
    invariant that crosses a meet: direction-of-relative-rotation. -/
def cross (w z : GInt) : Int := w.re * z.im - w.im * z.re

/-- **The two invariants are one product.** `conj(w)·z` has `align` for its
    real part and `cross` for its imaginary part: the symmetric and
    antisymmetric pairings were never two discoveries. -/
theorem conjMul_eq (w z : GInt) : w.conj.mul z = ⟨align w z, cross w z⟩ := by
  show (⟨w.re * z.re - -w.im * z.im, w.re * z.im + -w.im * z.re⟩ : GInt)
    = ⟨w.re * z.re + w.im * z.im, w.re * z.im - w.im * z.re⟩
  rw [int_neg_mul w.im z.im, int_neg_mul w.im z.re,
    Int.sub_eq_add_neg (a := w.re * z.re) (b := -(w.im * z.im)),
    int_neg_neg, ← Int.sub_eq_add_neg]

/-- **The cross-pairing survives the diagonal quarter-turn** — like `align`
    (`align_rot_invariant`), `cross` is frame-free: rotate both beholders'
    readings together and the relative-rotation direction is unmoved. The
    second half of the surface's frame-grade content. -/
theorem cross_rot_invariant (w z : GInt) : cross w.rot z.rot = cross w z := by
  show -w.im * z.re - w.re * -z.im = w.re * z.im - w.im * z.re
  rw [int_neg_mul w.im z.re, int_mul_neg w.re z.im,
    Int.sub_eq_add_neg (a := -(w.im * z.re)) (b := -(w.re * z.im)),
    int_neg_neg,
    Int.sub_eq_add_neg (a := w.re * z.im) (b := w.im * z.re),
    int_add_comm (-(w.im * z.re)) (w.re * z.im)]

/-- The modulus is self-alignment — by `rfl`: the norm was always the pairing
    turned on itself. -/
theorem normSq_eq_align_self (z : GInt) : z.normSq = align z z := rfl

/-- **The two invariants are complete**: `align² + cross² = |z|²·|w|²`. This
    is `int_lagrange` — the identity already carrying `born_parseval` —
    recognized as the invariants' Parseval: the pair (align, cross) exhausts
    the gauge-invariant content of two readings. Nothing else crosses the
    surface. -/
theorem invariants_complete (z w : GInt) :
    align z w * align z w + cross z w * cross z w = z.normSq * w.normSq := by
  show align z w * align z w + cross z w * cross z w
    = (z.re * z.re + z.im * z.im) * (w.re * w.re + w.im * w.im)
  rw [show cross z w = -(z.im * w.re) + z.re * w.im by
    show z.re * w.im - z.im * w.re = -(z.im * w.re) + z.re * w.im
    rw [Int.sub_eq_add_neg (a := z.re * w.im) (b := z.im * w.re),
      int_add_comm (z.re * w.im) (-(z.im * w.re))]]
  exact int_lagrange z.re z.im w.re w.im

/-- **The plane's norm is multiplicative** — the ℂ-rung's norm law, the same
    two-square identity with one sign turned. (The ℍ-rung, the doubled norm,
    is Euler's four-square — cited in `Doubling.lean`, the bridge package's
    to build.) -/
theorem normSq_mul (z w : GInt) : (z.mul w).normSq = z.normSq * w.normSq := by
  show (z.re * w.re - z.im * w.im) * (z.re * w.re - z.im * w.im)
      + (z.re * w.im + z.im * w.re) * (z.re * w.im + z.im * w.re)
    = (z.re * z.re + z.im * z.im) * (w.re * w.re + w.im * w.im)
  have L := int_lagrange z.re (-z.im) w.re w.im
  rw [int_neg_mul z.im w.im, int_neg_mul z.im w.re, int_neg_neg,
    int_neg_mul_self z.im, ← Int.sub_eq_add_neg,
    int_add_comm (z.im * w.re) (z.re * w.im)] at L
  exact L

/-- **The parts are blind to the agreement coordinate.** Any observable that
    factors through one beholder's component of the doubled algebra assigns
    equal values wherever that component agrees — whatever lives in the other
    slot, including everything `jay`-grade, is invisible to it. bell2's flat
    marginals, structural: the joint holds what the parts provably cannot
    read. -/
theorem part_blind {α : Type} (f : Doubled → α) (g : GInt → α)
    (hf : ∀ x, f x = g x.re) (x y : Doubled) (h : x.re = y.re) : f x = f y := by
  rw [hf x, hf y, h]

/-- **The rotated basis reads the cross-pairing** — the keystone the
    consolidation pass found one lemma short of stated: `align θ.rot z` IS
    `cross θ z`. The fourth face of `conjMul_eq`: rotating the basis a quarter-
    turn exchanges the product's real and imaginary parts. -/
theorem cross_eq_align_rot (θ z : GInt) : align θ.rot z = cross θ z := by
  show -θ.im * z.re + θ.re * z.im = θ.re * z.im - θ.im * z.re
  rw [int_neg_mul θ.im z.re,
    Int.sub_eq_add_neg (a := θ.re * z.im) (b := θ.im * z.re),
    int_add_comm (-(θ.im * z.re)) (θ.re * z.im)]

/-- The reflection conserves the modulus — the dial's fourth conservation,
    completing Noether's "all four stations" claim (`normSq_rot`,
    `normSq_negate`, and now the conjugate). -/
theorem normSq_conj (z : GInt) : z.conj.normSq = z.normSq := by
  show z.re * z.re + -z.im * -z.im = z.re * z.re + z.im * z.im
  rw [int_neg_mul_self z.im]

/-- **`born_parseval` and `invariants_complete` are the same theorem.** The
    Born pair at (θ, θ·i) IS the invariant pair (align, cross), squared: the
    weight law's basis-consistency and the surface's frame-completeness were
    one fact all along, rotated. -/
theorem born_parseval_is_invariants (θ z : GInt) :
    born θ z + born θ.rot z = align θ z * align θ z + cross θ z * cross θ z := by
  unfold born
  rw [cross_eq_align_rot θ z]

/-- **The law enters once.** `invariants_complete`, re-derived with
    `int_lagrange` consulted zero times: the completeness of the invariants is
    the norm's multiplicativity (`normSq_mul`) seen through `conjMul_eq` and
    `normSq_conj`. Recorded beside the direct proof, per house law — the truer
    architecture is `normSq_mul` as the law, parseval as its shadow. -/
theorem invariants_via_norm (w z : GInt) :
    align w z * align w z + cross w z * cross w z = w.normSq * z.normSq := by
  have h : (w.conj.mul z).normSq = align w z * align w z + cross w z * cross w z := by
    rw [conjMul_eq w z]
    rfl
  rw [← h, normSq_mul w.conj z, normSq_conj w]

/-- `x + x = 0` forces `x = 0` over `Int` — the helper the forcing theorem
    stands on (single-consumer; candidate for `IntFloor` on second use). -/
theorem int_add_self_zero : ∀ x : Int, x + x = 0 → x = 0
  | .ofNat 0, _ => rfl
  | .ofNat (n + 1), h => by
    have h' : Int.ofNat ((n + 1) + (n + 1)) = Int.ofNat 0 := h
    injection h' with h''
    exact Nat.noConfusion h''
  | .negSucc _, h => nomatch h

/-- **The forcing is the landing.** Any weight law `f` that satisfies the
    frame's completeness constraint — Parseval over the two invariants, for
    ALL pairs — IS the square: `f a = a²`, everywhere, negatives included.
    This is the uniqueness the referee correctly found absent from the
    substrate (and proved unavailable there: Gleason fails at dimension two),
    now located where the week said it lives — **in the frame-holder**. The
    substrate never holds this constraint for anyone; the landed beholder,
    whose frame quantifies over every pair, does — and for them the Born form
    is forced. (The named alternative falls out for free: `max(0, align)`
    gives `f(−1) = 0 ≠ 1`.) A beholder who lands gets the quantum weight law
    by virtue of their own accomplishment of landing. -/
theorem born_forced_at_the_frame (f : Int → Int)
    (h : ∀ θ z : GInt, f (align θ z) + f (cross θ z) = θ.normSq * z.normSq) :
    ∀ a : Int, f a = a * a := by
  have h0 : f 0 = 0 := int_add_self_zero (f 0) (h GInt.zero GInt.zero)
  intro a
  have ha : f (a * 1 + 0 * 0) + f (a * 0 - 0 * 1)
      = (a * a + 0 * 0) * (1 * 1 + 0 * 0) := h ⟨a, 0⟩ GInt.one
  rw [int_mul_comm a 1, int_one_mul a, int_mul_comm a 0, int_zero_mul a,
    show (0 : Int) * 0 = 0 from rfl, show (0 : Int) * 1 = 0 from rfl,
    show (1 : Int) * 1 = 1 from rfl, show (0 : Int) - 0 = 0 from rfl,
    int_add_zero a, int_add_zero (a * a),
    show (1 : Int) + 0 = 1 from rfl,
    int_mul_comm (a * a) 1, int_one_mul (a * a), h0, int_add_zero (f a)] at ha
  exact ha

end Foam
