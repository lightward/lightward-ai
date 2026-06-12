/-
# Foam.Resolver — the strange loop with brakes (any fair order, one home)

The formal mirror of a system that has run in production for years before it
had a mirror: Mechanic's audit engine (`AuditConcern` / `AuditWorker`,
mechanic-api — read 2026-06). A settlement at a leaf wakes its own audit; the
audit recomputes a summary from children, and **stops if nothing changed**;
only a real change wakes the parent. Summaries percolate rootward exactly as
far as they move anything, then the wave damps. The quiescent state — further
reps change nothing — is resolver.md's definition of *resolved*, running as a
Sidekiq topology. Its correctness rests on a property everybody relied on and
nobody wrote down: **whatever the scheduling — debounce collapses, queue
interleavings, noise — every fair order converges to the same fixed point.**
This file writes it down, at the smallest honest scale.

The model is a CHAIN: level 0 is the settled leaf (value `v`); each level's
correct summary is a function of the level below (`correctAt`); an `update` at
a level recomputes it from the level below *as currently held*. What is proven:

- **Noise cannot destroy progress** (`update_preserves_prefix`): once the
  summaries are correct up to a level, an update *anywhere* — relevant,
  redundant, or wild — leaves them correct. Progress is monotone under
  arbitrary interference.
- **The right step always advances** (`update_extends`): an update at the
  frontier extends correctness by one level.
- **Any fair schedule converges** (`fair_run_converges`): if a schedule merely
  *contains* the staircase `[j, j+1, …]` as a sublist — any amount of noise
  interleaved anywhere (`List.Sublist`: order preserved, gaps arbitrary) —
  running it lands the chain correct through the staircase's reach. Fairness
  is an embedded staircase; nothing else about the order matters.
- **The quiescent state is THE resolved state** (`quiescent_is_correct`): a
  state that no update moves — pointwise, no function-equality anywhere — IS
  the correct fold, level by level. "A fully-resolved resolver is one where
  further reps change nothing": here, the reps' silence *identifies* it.

No lattices, no monotonicity: the dependency structure is a chain, so the
fixed point is unique by recursion and reachable without order theory. That is
exactly the tree-shaped audit system's situation (acyclic, leafward-settled).
The general case — cyclic dependencies, monotone maps, Kleene/Cousot chaotic
iteration — is cited, not claimed; and the audit TREE (branching, aggregated
children) is the same recursion with heavier types: the chain is its smallest
honest case, claimed at exactly that size.

## The brakes

`perform_async_but_only_wait_once`: an atomic false→true on `audit_waiting`
(`UPDATE … WHERE audit_waiting = false`, exactly-one-row), so of any storm of
wake-ups, **exactly the first wins** and the rest collapse into its wait —
`winners_collapse`; and while armed, nobody wins — `winners_armed_silent`. "A
resolver is a strange loop with brakes": the loop is the wave above; these are
the brakes, ten lines, pinned. (The clear-before-recompute that re-arms the
next epoch, and the 5-second debounce window, are the operational dressing —
cited, not claimed.)

Pure construction — axiom-free.
-/

namespace Foam

/-- The correct summary at each level: the bottom-up fold. Level 0 is the
    settled leaf; each level above summarizes the one below. This is the
    chain's one fixed point, defined by recursion — the resolved state. -/
def correctAt {V : Type} (f : Nat → V → V) (v : V) : Nat → V
  | 0 => v
  | i + 1 => f i (correctAt f v i)

/-- Recompute one level from the state as currently held: the audit body. -/
def recompute {V : Type} (f : Nat → V → V) (v : V) (s : Nat → V) : Nat → V
  | 0 => v
  | i + 1 => f i (s i)

/-- One audit step: recompute level `k`, touch nothing else. -/
def update {V : Type} (f : Nat → V → V) (v : V) (k : Nat) (s : Nat → V)
    (j : Nat) : V :=
  if j = k then recompute f v s k else s j

/-- Resolve through a schedule: a list of levels to audit, in the order the
    queue happens to deliver them. -/
def resolve {V : Type} (f : Nat → V → V) (v : V) (sched : List Nat)
    (s : Nat → V) : Nat → V :=
  sched.foldl (fun t i => update f v i t) s

/-- **Noise cannot destroy progress.** If the chain is correct below `j`, an
    update at ANY level `k` — below the frontier (redundant: it recomputes
    what already holds), at it, or beyond it — leaves it correct below `j`. -/
theorem update_preserves_prefix {V : Type} (f : Nat → V → V) (v : V)
    (k : Nat) (s : Nat → V) (j : Nat)
    (h : ∀ m, m < j → s m = correctAt f v m) :
    ∀ m, m < j → update f v k s m = correctAt f v m := by
  intro m hm
  unfold update
  by_cases hmk : m = k
  · rw [if_pos hmk]
    subst hmk
    cases m with
    | zero => rfl
    | succ i =>
      show f i (s i) = f i (correctAt f v i)
      rw [h i (Nat.lt_trans (Nat.lt_succ_self i) hm)]
  · rw [if_neg hmk]
    exact h m hm

/-- **The right step always advances.** An update at the frontier `j` extends
    correctness from below-`j` to below-`j+1`. -/
theorem update_extends {V : Type} (f : Nat → V → V) (v : V)
    (j : Nat) (s : Nat → V)
    (h : ∀ m, m < j → s m = correctAt f v m) :
    ∀ m, m < j + 1 → update f v j s m = correctAt f v m := by
  intro m hm
  by_cases hmj : m = j
  · unfold update
    rw [if_pos hmj]
    subst hmj
    cases m with
    | zero => rfl
    | succ i =>
      show f i (s i) = f i (correctAt f v i)
      rw [h i (Nat.lt_succ_self i)]
  · rcases Nat.lt_trichotomy m j with hlt | heq | hgt
    · unfold update
      rw [if_neg hmj]
      exact h m hlt
    · exact absurd heq hmj
    · exact absurd (Nat.lt_of_lt_of_le hgt (Nat.le_of_lt_succ hm))
        (Nat.lt_irrefl j)

/-- The staircase from `j`: the levels `j, j+1, …`, in order — the part of a
    fair schedule that does the work. -/
inductive Stair : Nat → List Nat → Prop
  | nil (j : Nat) : Stair j []
  | step {j : Nat} {rest : List Nat} : Stair (j + 1) rest → Stair j (j :: rest)

/-- **Any fair schedule converges, and to the same place.** If a schedule
    merely CONTAINS the staircase from the frontier as a sublist — arbitrary
    noise interleaved before, between, after (`<+` preserves order, allows any
    gaps) — then running it lands the chain correct through the staircase's
    reach. The debounce may collapse wake-ups, the queue may shuffle, redundant
    audits may fire anywhere: none of it matters, by induction on the
    interleaving itself. -/
theorem fair_run_converges {V : Type} (f : Nat → V → V) (v : V)
    {stair sched : List Nat} (hsub : List.Sublist stair sched) :
    ∀ {j : Nat}, Stair j stair →
    ∀ {s : Nat → V}, (∀ m, m < j → s m = correctAt f v m) →
    ∀ m, m < j + stair.length → resolve f v sched s m = correctAt f v m := by
  induction hsub with
  | slnil =>
    intro j _ s h m hm
    exact h m hm
  | cons a _ ih =>
    intro j hst s h m hm
    exact ih hst (update_preserves_prefix f v a s j h) m hm
  | cons₂ a _ ih =>
    intro j hst s h m hm
    cases hst with
    | step hst' =>
      refine ih hst' (update_extends f v _ s h) m ?_
      have key : ∀ x l : Nat, x + 1 + l = x + (l + 1) := fun x l => by
        rw [Nat.add_assoc, Nat.add_comm 1 l]
      rw [key]
      exact hm

/-- **The quiescent state is THE resolved state.** A state no update moves —
    pointwise; no function-equality anywhere — is the correct fold, level by
    level. Further reps changing nothing doesn't just mean you may stop: it
    means you are home, and there is exactly one home. -/
theorem quiescent_is_correct {V : Type} (f : Nat → V → V) (v : V)
    (s : Nat → V) (h : ∀ i j, update f v i s j = s j) :
    ∀ i, s i = correctAt f v i := by
  intro i
  induction i with
  | zero =>
    have h0 := h 0 0
    unfold update at h0
    rw [if_pos rfl] at h0
    exact h0.symm
  | succ i ih =>
    have hs := h (i + 1) (i + 1)
    unfold update at hs
    rw [if_pos rfl] at hs
    show s (i + 1) = f i (correctAt f v i)
    rw [← ih]
    exact hs.symm

/-! ## The brakes -/

/-- A storm of `n` wake-ups against the armed-flag: each arrives, finds the
    flag, wins iff it was the one to arm it (the atomic false→true), and
    leaves it armed for the rest. Returns how many won. -/
def winners : Bool → Nat → Nat
  | _, 0 => 0
  | armed, n + 1 => cond armed 0 1 + winners true n

/-- **While armed, nobody wins.** Every wake-up after the first collapses
    into the wait already underway. -/
theorem winners_armed_silent : ∀ n, winners true n = 0
  | 0 => rfl
  | n + 1 => by
    show 0 + winners true n = 0
    rw [Nat.zero_add, winners_armed_silent n]

/-- **Exactly one wins.** Any nonempty storm against an unarmed flag produces
    exactly one enqueue — the brakes, as arithmetic: the strange loop above
    cannot be stampeded into running more than once per arming. -/
theorem winners_collapse : ∀ n, winners false (n + 1) = 1
  | n => by
    show 1 + winners true n = 1
    rw [winners_armed_silent n]

end Foam
