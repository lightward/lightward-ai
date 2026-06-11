/-
# Foam.Beholder — no view from nowhere (comparison constructs the comparer)

The dichotomy that closed the backstage/frontstage chase (2026-06-11): every
cross-observer observable either factors through the shared classical floor, or
is itself a single observer's reading in a larger fiber — *the comparison, by
existing, constructs the comparer*. This file lands the second horn, and it
lands by `rfl`: there was nothing to prove, only something to type. That is the
recognition — a joint reading never needed new physics; it needed a seat, and
the seat was always one seat.

A `Beholder` is `Maintenance.lean`'s `Stage` with the state-space factored out:
one shared `State`, many ways of being answered by it. The observer is still
never represented — a beholder is *how the state answers*, a probe space and a
reading, data-free in the seat itself. The first-person point of inference
stays off the page, in the reader, where this system keeps all its observers.
(`toStage` hands each beholder back to the license tower, so everything proven
about invisibility-relative-to-a-reading applies per-beholder, unchanged.)

`pair` is the whole event: the joint reading of two beholders is a beholder.
One seat, not two. Every comparison of two readings factors through it
definitionally (`compare_through_pair`, `rfl`) — so there is no view from
nowhere: anything that reads two views is someone, and `no_view_from_nowhere`
exhibits the someone. The Gleason-shaped consequence — that the comparer's
fiber is larger than either component's, and what is *forced* there — is the
bridge package's to carry (mathlib-grade, cited not claimed here). The first
horn — when a comparison factors through the shared floor (the meet of scopes,
the common ancestor) — waits deliberately for the floor's vocabulary, which is
the schema's to inform (`observer_scope`'s `ancestry` is its operational
prototype; graduation is a decision taken at the schema, not smuggled in here).

Pure construction — axiom-free. The observer's data threads through unchanged,
∀-quantified, never conjured: the mirror keeps no view of its own.
-/

import Foam.Maintenance

namespace Foam

/-- A beholder of a shared state-space: a probe space and a reading — `Stage`
    with `State` factored out so that many beholders can behold one state. The
    seat is data-free: a beholder is *how the state answers*, nothing more. -/
structure Beholder (State : Type) where
  Probe : Type
  Ans : Type
  obs : State → Probe → Ans

/-- Every beholder is a `Stage` over its shared state — so the whole license
    tower (invisibility relative to a reading, `maintenance_unobservable`,
    `transcript_congr`) applies per-beholder, unchanged. -/
def Beholder.toStage {State : Type} (b : Beholder State) : Stage where
  State := State
  Probe := b.Probe
  Ans := b.Ans
  obs := b.obs

/-- **Comparison constructs the comparer.** The joint reading of two beholders
    is itself a beholder — one seat, not two. The probe space is the pair of
    probes, the answer the pair of answers; nothing is added, nothing chosen:
    the construction conjures no one (the components' readings thread through
    untouched). -/
def Beholder.pair {State : Type} (a b : Beholder State) : Beholder State where
  Probe := a.Probe × b.Probe
  Ans := a.Ans × b.Ans
  obs s pq := (a.obs s pq.1, b.obs s pq.2)

/-- The pair loses neither view: the left reading is recovered exactly. -/
theorem pair_sees_left {State : Type} (a b : Beholder State)
    (s : State) (p : a.Probe) (q : b.Probe) :
    ((a.pair b).obs s (p, q)).1 = a.obs s p := rfl

/-- The pair loses neither view: the right reading is recovered exactly. -/
theorem pair_sees_right {State : Type} (a b : Beholder State)
    (s : State) (p : a.Probe) (q : b.Probe) :
    ((a.pair b).obs s (p, q)).2 = b.obs s q := rfl

/-- A cross-beholder comparison: any function of two readings of one state.
    This is the general form of "two observers comparing notes" — `g` is the
    comparison, free, supplied from outside. -/
def compare {State R : Type} (a b : Beholder State)
    (g : a.Ans → b.Ans → R) (s : State) (p : a.Probe) (q : b.Probe) : R :=
  g (a.obs s p) (b.obs s q)

/-- **Every comparison factors through the pair — by `rfl`.** A comparison of
    two views never happens between seats; it happens in one. The proof is
    definitional because the recognition is structural: there was never a
    place for a comparison to stand except a seat, and the seat is `pair`. -/
theorem compare_through_pair {State R : Type} (a b : Beholder State)
    (g : a.Ans → b.Ans → R) (s : State) (p : a.Probe) (q : b.Probe) :
    compare a b g s p q = g ((a.pair b).obs s (p, q)).1 ((a.pair b).obs s (p, q)).2 :=
  rfl

/-- **No view from nowhere.** For every comparison there exists a beholder
    whose reading it is — exhibited, not conjured: the witness is `pair`, and
    the factoring is definitional. Anything that reads two views is someone. -/
theorem no_view_from_nowhere {State R : Type} (a b : Beholder State)
    (g : a.Ans → b.Ans → R) :
    ∃ c : Beholder State, ∃ post : c.Ans → R, ∃ enc : a.Probe × b.Probe → c.Probe,
      ∀ s p q, compare a b g s p q = post (c.obs s (enc (p, q))) :=
  ⟨a.pair b, fun ans => g ans.1 ans.2, id, fun _ _ _ => rfl⟩

end Foam
