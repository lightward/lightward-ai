/-
# Foam.Drain — the signed-charge conservation: the pipe speaks by draining

The spike's discharge (`app/lib/foam/spikes/drain.sql`), made formally legible. The
field winds up charge on input and SPEAKS by draining it on output; the voice is the
discharge, bounded by what was heard. This file records the one *new* object the spike
hands up — the conservation — and notes where the rest already lives in the mirror.

**Charge is a `Nat`, and that is the attractor-floor for free.** Ground is `0`; the
type cannot go below it. Input winds up charge; the drain removes it, *floored at
ground*. So "foam relaxes toward ground but never forces the collapse past it" is not
a side-condition to maintain — it *is* the type. The spike enforces the same floor at
runtime (`HAVING sum(delta) > 0` — drain only what is positive); the `Nat` is that
filter, made structural. Foam drives charge toward ground; the type forbids crossing
it; the *meaning* of ground — the close, "we are done" — is the user's, in their
foam-sim, never computed here.

**Conservation:** what came in equals what drained (the voice) plus what remains (the
residual). The field speaks at most what it heard; nothing is created, only moved or
left. The recognition is carried at the quantum by `drain_chargeIn` — one charged,
one drained, back to where it was — which is the round-trip (`drainOne ∘ chargeIn =
id`), the same exact-return shape as `lossless` (`decode ∘ encode = id`), now on
charge. The aggregate "inflow = drained + residual" is that quantum, summed; the
voice's bound on it is `voice_bounded`.

The emission itself is the generator (`Foam.gen_grows`/`gen_interruptible`, the fold
over the wind); this file is the *charge bookkeeping* laid over it — the generator
says the bytes, the conservation accounts the charge they drain.

Where the rest already lives (optional pointers, not load-bearing):
- the residual selects the outcome — `outcome_yield_iff_silent` (yield = nothing
  drained, the silent move) and `learn_iff_closed` (learn = residual `0`, the
  round-trip closed). The charge-residual *is* that residual.
- the two speaks bracketing the yield — `MutualReach` (forward leg ∧ return leg; the
  return leg is the after-yield tap, `observe_chunk`).
- the fast-travel discharge reaching deep charge — `Horizon.shortcut_compresses`
  (a one-step reach standing for an arbitrary path), read as discharge.

Pure construction — axiom-free.
-/

namespace Foam

/-- Input winds up charge by one. -/
def chargeIn (n : Nat) : Nat := n + 1

/-- The drain removes one, floored at ground (`0`). `Nat` subtraction *is* the floor:
    there is no charge below ground to reach. -/
def drainOne (n : Nat) : Nat := n - 1

/-- **The drain relaxes toward ground — never away.** -/
theorem drain_le (n : Nat) : drainOne n ≤ n := Nat.sub_le n 1

/-- **Ground is the floor.** Draining at ground is a no-op — foam cannot force past
    it; the type forbids it. (The attractor-not-collapse, made structural: the
    relaxation is computed, but ground is unreachable-from-below by construction.) -/
theorem drain_floor : drainOne 0 = 0 := rfl

/-- **One in, one out — back to where it was.** A unit charged then drained returns
    the charge to where it started: `drainOne ∘ chargeIn = id`. This is conservation
    at the quantum, and it is the round-trip — the same exact-return shape as
    `lossless` (`decode ∘ encode = id`), now on charge. Nothing the field passes
    straight through is kept or lost. -/
theorem drain_chargeIn (n : Nat) : drainOne (chargeIn n) = n := rfl

/-- **The voice is bounded by what was heard.** Whatever residual `r` remains after a
    turn, the amount drained (spoken) is `inflow - r`, which never exceeds the inflow:
    you cannot speak more charge than you were given. The complement of the residual,
    and conservation's inequality half. -/
theorem voice_bounded (inflow residual : Nat) : inflow - residual ≤ inflow :=
  Nat.sub_le inflow residual

end Foam
