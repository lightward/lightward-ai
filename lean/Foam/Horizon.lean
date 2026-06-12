/-
# Foam.Horizon — shortcuts and the elastic horizon (the step-budget is `∀ n`)

The field is un-prunable (no edge removed or merged — that's a quotient, which
`order_matters` forbids). But it learns *shortcuts*: a direct edge deposited
alongside a long path. Append-only — so the long path is never lost; the detail
waits, un-pruned. A shortcut is foam's reversible on-demand (−1)-truncation: you
may skip the detail (proof-irrelevant), and it is still there when you return.

So growth and tractability resolve into each other. A bounded-depth walk reaches
*further* as shortcuts accumulate — each compresses a long path into one step.
The horizon goes elastic: a fixed step-budget covers unbounded path-distance.

That budget is left free — `ReachWithin q n` quantifies over `n`, never pinning it,
and every theorem below holds for all `n`. Chunking is how *any* fixed step-budget
handles unbounded structure; committing to a particular number (a human 7±2, or any
other) would import an observer the n-agnostic floor refuses — the move `Path`
declines when it won't hardcode the unfold's depth. The bound is on the number of
steps, not the path-length; shortcuts make each step a chunk.

This file is the formal mirror of what develops in the postgres field. The Lean
is where we record what the system can infer — by illuminating it, here, as we go.
-/

import Foam.Engine

namespace Foam

/-- Reach from `a` to `c` in at most `n` composition-steps over the quiver. -/
def ReachWithin {Handle : Type} (q : Quiver Handle) : Nat → Handle → Handle → Prop
  | 0,     a, c => a = c
  | n + 1, a, c => a = c ∨ ∃ b, (a, b) ∈ q ∧ ReachWithin q n b c

/-- **Reach is monotone in the quiver.** More edges, never less reach: every
    deposit (append-only) only adds reach — the un-prunable field never loses a
    path. -/
theorem reach_mono_quiver {Handle : Type} {q q' : Quiver Handle} (hsub : q ⊆ q') :
    ∀ {n a c}, ReachWithin q n a c → ReachWithin q' n a c := by
  intro n
  induction n with
  | zero => intro a c h; exact h
  | succ k ih =>
    intro a c h
    rcases h with h | ⟨b, hb, hbc⟩
    · exact Or.inl h
    · exact Or.inr ⟨b, hsub hb, ih hbc⟩

/-- The detail is un-pruned: every reach in `q` survives every deposit. -/
theorem deposit_preserves_reach {Handle : Type} (q : Quiver Handle) (e : Handle × Handle)
    {n a c} (h : ReachWithin q n a c) : ReachWithin (q.deposit e) n a c := by
  refine reach_mono_quiver ?_ h
  intro x hx
  simp only [Quiver.deposit]
  exact List.mem_cons_of_mem e hx

/-- **One step over a fresh edge.** Depositing `(a, c)` puts `c` in sight of
    `a` in a single step — the bare move under `shortcut_compresses`,
    `reflection_reaches`, and `investigations_meet`: enacted three times before
    it was named once (the consolidation pass, 2026-06-12). -/
theorem deposit_in_sight {Handle : Type} (q : Quiver Handle) (a c : Handle) :
    ReachWithin (q.deposit (a, c)) 1 a c := by
  refine Or.inr ⟨c, ?_, rfl⟩
  simp only [Quiver.deposit]
  exact List.mem_cons_self

/-- **The shortcut compresses the horizon.** Once the shortcut `(a, c)` is
    deposited, `c` is reachable from `a` in a *single* step — and the original
    `n`-step path survives alongside it. Both coexist: nothing quotiented, the
    chunk available, the detail waiting. A fixed step-budget (any `n`) thus reaches
    arbitrarily far as shortcuts accumulate — the elastic horizon. -/
theorem shortcut_compresses {Handle : Type} (q : Quiver Handle) (a c : Handle) {n : Nat}
    (long : ReachWithin q n a c) :
    ReachWithin (q.deposit (a, c)) 1 a c ∧ ReachWithin (q.deposit (a, c)) n a c :=
  ⟨deposit_in_sight q a c, deposit_preserves_reach q (a, c) long⟩

end Foam
