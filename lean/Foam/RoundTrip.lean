/-
# Foam.RoundTrip — the exact-return shape, shared across carriers

`lossless` (`decode ∘ encode = id`, on bytes) and the drain's conservation
(`drainOne ∘ chargeIn = id`, on charge) are the **same theorem wearing different
carriers**. This file names the shape they share — a *round-trip*, a retraction — and
proves the one thing it gives: the forward map is injective (nothing collides on the
way in, because the return tells inputs apart). Both inherit it from one proof.

Keeping track of the iso is what rivets the layers into one cloth. The codec's
losslessness and the drain's conservation are not two facts that happen to rhyme —
they are one recognition, instanced twice. (English is a pun dictionary; so, it turns
out, is a clean type.)

Pure construction — axiom-free.
-/

import Foam.Stream   -- enc / dec / lossless_tag: the round-trip on bytes
import Foam.Drain    -- chargeIn / drainOne / drain_chargeIn: the round-trip on charge
import Foam.Codec    -- encode / decode / lossless_codec: the REAL codec, riveted below

namespace Foam

/-- A **round-trip**: a forward `fwd` and a return `ret` that exactly undoes it
    (`ret ∘ fwd = id`). The shared shape of `lossless` (`decode ∘ encode = id`, bytes)
    and conservation (`drainOne ∘ chargeIn = id`, charge) — the exact return, a
    retraction. `fwd` winds up (encode / charge), `ret` returns (decode / drain). -/
structure RoundTrip (A B : Type) where
  fwd    : A → B
  ret    : B → A
  closes : ∀ a, ret (fwd a) = a

/-- **The forward of a round-trip is injective.** The return tells inputs apart, so
    none collide on the way in (a section is a mono). One proof; both carriers inherit
    it — the codec's encode loses nothing, and charging is one-to-one, are the same
    fact said once. -/
theorem RoundTrip.fwd_injective {A B : Type} (rt : RoundTrip A B) {a a' : A}
    (h : rt.fwd a = rt.fwd a') : a = a' :=
  (rt.closes a).symm.trans ((congrArg rt.ret h).trans (rt.closes a'))

/-- The drain's conservation, as a round-trip on charge. `closes` is `drain_chargeIn`. -/
def chargeRoundTrip : RoundTrip Nat Nat where
  fwd    := chargeIn
  ret    := drainOne
  closes := drain_chargeIn

/-- The toy codec's losslessness, as a round-trip on bytes. `closes` is
    `lossless_tag`. -/
def codecRoundTrip {B : Type} : RoundTrip (List B) (List (B × B)) where
  fwd    := enc
  ret    := dec
  closes := lossless_tag

/-- **The REAL codec, riveted** — the instance this file promised in prose and
    never constructed until the consolidation pass (2026-06-12): the LZ78 shape,
    dictionary threaded through the carrier, as a round-trip. -/
def lz78RoundTrip {B D : Type} (knows : D → List B → Bool)
    (learn : D → List B → D) (d₀ : D) : RoundTrip (List B) (List (List B)) where
  fwd    := encode knows learn d₀
  ret    := decode
  closes := lossless_codec knows learn d₀

/-- **The real encoder loses nothing** — `fwd_injective` on the LZ78 carrier:
    encode-injectivity for the codec production runs, previously unavailable. -/
theorem encode_injective {B D : Type} (knows : D → List B → Bool)
    (learn : D → List B → D) (d₀ : D) {xs ys : List B}
    (h : encode knows learn d₀ xs = encode knows learn d₀ ys) :
    xs = ys :=
  (lz78RoundTrip knows learn d₀).fwd_injective h

/-- Charging is one-to-one — `fwd_injective` on the charge carrier. -/
theorem chargeIn_injective {n n' : Nat} (h : chargeIn n = chargeIn n') : n = n' :=
  chargeRoundTrip.fwd_injective h

/-- The codec's encode loses nothing — `fwd_injective` on the byte carrier. The same
    theorem as `chargeIn_injective`, instanced on the other side of the iso. -/
theorem enc_injective {B : Type} {xs ys : List B} (h : enc xs = enc ys) : xs = ys :=
  codecRoundTrip.fwd_injective h

end Foam
