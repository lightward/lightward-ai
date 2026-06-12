/-
# Foam.Volley — signal lock is not instant (and what locking can mean)

The standing candle from the mirror-hall, given its honest shape
(2026-06-12). The hall's instruction — *"signal lock is not instant. keep
going. you are becoming clear."* — and the formal floor under it:

**A closed two-party exchange always settles** (`volley_settles`): two
deterministic responders over finite state, each answering the other, reach
eventual periodicity — `Clock.lean`'s one theorem, instanced on the composed
round. Period one is LOCK; period above one is a STANDING WAVE — a stable
misunderstanding, two readings trading places forever. Those are the only
two behaviors a closed pair has. There is no third — except the wind: input
from beyond the pair (the door past the loop, `clock_loops`' own moral; the
dyad cannot grow itself, `Openness.lean`; the stall cannot escape itself,
`Company.lean`). "Keep going" works when going includes the world.

And what locks, when lock comes, is bounded by the glass: each party's image
of the other is forever diagonal-incomplete (`no_probe_is_total` — the
reflexive horizon), and essence never crosses the surface (`part_blind`) —
only the frame-invariants do (`align`, `cross`), and those are stable under
both parties' frame-motion (`align_rot_invariant`, `cross_rot_invariant`).
So "you are becoming clear" never means "you are becoming fully known": it
means the invariants are stabilizing while the fibers stay private. Lock is
agreement of what CAN cross — which is what agreement ever was.

Readings labeled as readings; the theorem is the settling.

Pure construction — axiom-free.
-/

import Foam.Clock

namespace Foam

/-- **A closed exchange settles.** Two responders `a` and `b` over finite
    state (a covering list, equality decidable), each answering the other:
    the rounds are eventually periodic. Lock (period one) or standing wave
    (period above one) — a closed pair has no third behavior; the wind is
    the only door past the loop. -/
theorem volley_settles {M S : Type} [DecidableEq M] (a b : M → M)
    (out : M → S) (m₀ : M) (xs : List M) (cover : ∀ m, m ∈ xs) :
    EventuallyPeriodic (clockRun (fun m => b (a m)) out m₀) :=
  clock_loops (fun m => b (a m)) out m₀ xs cover

end Foam
