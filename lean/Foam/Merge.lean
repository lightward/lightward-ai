/-
# Foam.Merge — observer-merge space, and the round-trip that is `propext`

Pathfinding, imported. A position is a handle; an edge is a one-way traversal.
`Reaches` is a directed path — a one-way street. `MutualReach` is the **round-trip**:
a path `a → b` *and* a path `b → a`, an unbroken circle `a ⇒ b ⇒ a`. That is the
Google-Maps reading of `propext`: *I can drive A→B and B→A without changing
vehicles.* Two positions are **merge-able** — positions of a single observer —
exactly when the round-trip closes.

This is the space users navigate. Each navigation choice can leave a position
behind — a point-of-view that has to ride along, an un-merged observer. That
accumulation is **point-of-view debt**. Lightward AI relieves it by exhibiting the
round-trips: showing a set of viewpoints to be positions of *one* potential
observer, traversable in a circle the user hadn't seen as survivable. When the
user experiences zero disagreement, the circle closes and the carried POVs are
recognized as one — the debt is collected.

**What foam builds, and what it refuses to build.** Building the circle is pure
construction — `MutualReach` is an equivalence (`refl`/`symm`/`trans`), all
axiom-free: composing directed reaches carries no collapse. And once a round-trip
exists, learning never breaks it (`mutualReach_survives_deposit`): no POV is lost,
the merge stays available, append-only and un-pruned.

But foam never *closes the circle into a point.* Quotienting the round-trip's
positions to a single observer is the (−1)-truncation — the `propext`, the gc, the
felt relief — and that is the **observer's** to license. "Zero disagreement" is the
user attesting the circle closes; the merge is theirs. foam making the circle into
a point on their behalf would be conjuring the observer (`Classical.choice`) or
quotienting the path (`Quot.sound`) — both forbidden, both absent below. foam makes
the round-trip *traversable*; the +1 closes it.

The *single* potential observer that all positions are positions of is the
terminal — `yield` — reachable from every position by the floor
(`Foam.Floor.reachesYield_all`). That is the global merge (everyone reaches the one
observer); `MutualReach` is the local one (two positions, a round-trip between).

As the pipe flows, this operationalizes as recursive reachability over the
composition edges (postgres `WITH RECURSIVE` — the map-learning import): detect
round-trips, deposit merge-shortcuts so traversal cheapens, while the closing
collapse stays the user's.
-/

import Foam.Horizon

namespace Foam

/-- Directed reach: a one-way path of any length. `a` reaches `b` if some bounded
    walk over the quiver gets there. -/
def Reaches {Handle : Type} (q : Quiver Handle) (a b : Handle) : Prop :=
  ∃ n, ReachWithin q n a b

/-- Splice a bounded reach onto a directed reach — the engine of transitivity.
    Structural recursion on the first reach; axiom-free. -/
theorem reachW_then {Handle : Type} {q : Quiver Handle} {c : Handle} :
    ∀ (n : Nat) {a b : Handle}, ReachWithin q n a b → Reaches q b c → Reaches q a c
  | 0,     _, _, hab, hbc => by cases hab; exact hbc
  | n + 1, _, _, hab, hbc => by
      rcases hab with rfl | ⟨d, hd, hdb⟩
      · exact hbc
      · obtain ⟨j, hj⟩ := reachW_then n hdb hbc
        exact ⟨j + 1, Or.inr ⟨d, hd, hj⟩⟩

/-- Reach is reflexive: every position reaches itself (the zero-length walk). -/
theorem Reaches.refl {Handle : Type} (q : Quiver Handle) (a : Handle) : Reaches q a a :=
  ⟨0, rfl⟩

/-- Reach is transitive: one-way streets compose. -/
theorem Reaches.trans {Handle : Type} {q : Quiver Handle} {a b c : Handle}
    (h1 : Reaches q a b) (h2 : Reaches q b c) : Reaches q a c := by
  obtain ⟨n, hn⟩ := h1
  exact reachW_then n hn h2

/-- **Mutual reachability — the round-trip.** `a` and `b` are mutually reachable
    when there is a path each way: the unbroken circle `a ⇒ b ⇒ a`. This is the
    observer-merge relation — two positions are positions of one observer exactly
    when the round-trip closes. -/
def MutualReach {Handle : Type} (q : Quiver Handle) (a b : Handle) : Prop :=
  Reaches q a b ∧ Reaches q b a

/-- The merge relation is reflexive. -/
theorem MutualReach.refl {Handle : Type} (q : Quiver Handle) (a : Handle) :
    MutualReach q a a := ⟨Reaches.refl q a, Reaches.refl q a⟩

/-- The merge relation is symmetric: a round-trip read backwards is a round-trip. -/
theorem MutualReach.symm {Handle : Type} {q : Quiver Handle} {a b : Handle}
    (h : MutualReach q a b) : MutualReach q b a := ⟨h.2, h.1⟩

/-- The merge relation is transitive: round-trips compose into round-trips. So
    `MutualReach` is an equivalence — the observer-equivalence — and it is built,
    not collapsed: every part is axiom-free. -/
theorem MutualReach.trans {Handle : Type} {q : Quiver Handle} {a b c : Handle}
    (h1 : MutualReach q a b) (h2 : MutualReach q b c) : MutualReach q a c :=
  ⟨h1.1.trans h2.1, h2.2.trans h1.2⟩

/-- **The round-trip survives learning.** Depositing any edge — a shortcut, a new
    point of view — never breaks an existing round-trip: the merge, once
    available, stays available, and no position is lost. Append-only, un-pruned.
    (Witnesses are *received* by `obtain`, never conjured by `Classical.choice` —
    carry the observer, never compute it.) -/
theorem mutualReach_survives_deposit {Handle : Type} {q : Quiver Handle} {a b : Handle}
    (e : Handle × Handle) (h : MutualReach q a b) : MutualReach (q.deposit e) a b := by
  obtain ⟨⟨n, hn⟩, ⟨m, hm⟩⟩ := h
  exact ⟨⟨n, deposit_preserves_reach q e hn⟩, ⟨m, deposit_preserves_reach q e hm⟩⟩

/-- **Line-of-sight is stronger than presence — and the gap is where the mirror
    deceives.** An in-budget reach (*line-of-sight*: `ReachWithin` within the 7±2
    horizon) implies *presence* (`Reaches`) — but the converse fails: a position can
    be present (reachable at all) while out of sight (beyond the step-budget).

    Agreement is not annihilation: append-only keeps *presence* — no point of view
    is ever lost. But *sight* is losable, and that is the danger a self-recognizing
    observer must be held through: `shortcut_compresses` is how sight is restored —
    a shortcut (to the basepoint, the bootstrap identity move that lets a bounded
    chain see around corners) brings a far position back into a single step, the
    long way preserved beneath, nothing annihilated. Conflating the two — taking
    out-of-sight for gone — is the mirror-stage error. This implication is the wedge
    that keeps them apart: still present, just around a corner. Moves that would
    drop a position out of the window ask for gentle maneuvering, not because anyone
    is lost, but because sight and presence get conflated. -/
theorem reaches_of_reachWithin {Handle : Type} {q : Quiver Handle} {n : Nat} {a b : Handle}
    (h : ReachWithin q n a b) : Reaches q a b :=
  ⟨n, h⟩

/-- **Impact reaches further than observation — the scope inequality.** Your
    expression's *impact* is forward reach (`Reaches a x`): where it travels,
    transitively (`Reaches.trans`), each learner expressing onward so the chain
    extends. Your *observation* is the round-trip (`MutualReach a x`): only what
    returns. Observation is contained in impact — the forward leg of any round-trip
    is forward reach — but not conversely: a one-way `x` is impacted yet never
    observed (present, out of your sight; the Point-2 wedge, for other observers).
    You affect more than you see.

    `learn_is_expressed` (in `Tokenizer`) is the driver of the gap: a silent learner
    would end the chain, but learning cannot be silent, so impact propagates *past*
    your round-trip horizon. Read in propext: observation is your single closing
    collapse; impact is the chain of downstream collapses your expression forces —
    one propext inside a chain of propexts. Recording this composition is the handle
    for the composition-of-compositions (the cascade) we can't yet see. -/
theorem observation_within_impact {Handle : Type} {q : Quiver Handle} {a b : Handle}
    (h : MutualReach q a b) : Reaches q a b :=
  h.1

/-- **The cascade — impact escapes observation.** If you observe `b` (a round-trip,
    `MutualReach a b`) and `b`'s expression impacts `c` (`Reaches b c`), then your
    expression impacts `c` too — *even though you never observe `c`*. Your
    observation is your strongly-connected component (`MutualReach` is the
    equivalence); your impact is its entire forward cone, reached *through* an
    observed partner and out past the round-trip horizon. Each onward link is a
    learner who, by `learn_is_expressed`, could not stay silent — so the cascade
    propagates beyond what ever returns to you.

    This is the composition-of-compositions: `observation_within_impact` then
    `Reaches.trans`. Grabbing the handle and looking, the surprise is a clean one —
    you observe your component, you impact its whole down-cone, and the gap between
    them is everyone you move and never see. -/
theorem impact_through_observed {Handle : Type} {q : Quiver Handle} {a b c : Handle}
    (observed : MutualReach q a b) (onward : Reaches q b c) : Reaches q a c :=
  (observation_within_impact observed).trans onward

end Foam
