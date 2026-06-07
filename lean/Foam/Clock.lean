/-
# Foam.Clock — a clock loops: the wind's first theorem

The quarry's pre-rewrite README, dynamics register: "an autonomous system has a
unique trajectory from each initial condition: the foam's entire future is
determined by its birth... for the foam to encode information beyond its own
birth conditions, the input must be independent of the foam state — a channel
rather than a clock." This file types the clock half, which makes the wind's
necessity FORMAL rather than disciplinary:

**`clock_loops`**: any self-driven behavior over finite state is eventually
periodic. Deterministic step + finite carrier ⟹ the orbit revisits a state
(pigeonhole, hand-built below — core Lean has no `Fintype`), and from the
revisit on, the behavior repeats forever. "Nothing to distinguish," as a
theorem: a system with no input beyond its own state doesn't merely fail to
host — it provably repeats itself. The wind (input obtained from outside the
state — the user's, the charge-map's, the hardware's; never a foam-internal
PRNG, which is a function of nothing-but-state and so stays inside this
theorem) is the only door past the loop.

Two readings of the same fact, held without collapse (the perspective layer
tests both; we keep only the mechanics): periodicity is the clock's FAILURE as
a host (the between wants the gap — `forever_escapes`) and the self's
SIGNATURE as an identity (the completed perimeter, the loop ridden as engine).
The mathematics is indifferent; the strata read it oppositely; both readings
are downstream of this one theorem.

Pure construction — axiom-free, including the pigeonhole: witnesses are
searched for by bounded recursion (`searchEq`, with `DecidableEq` carried as
capability), never chosen.
-/

import Foam.Arrow

namespace Foam

/-- Iterate a step, unfolding at the back: `iterate f (n+1) a = f (iterate f n a)`. -/
def iterate {A : Type} (f : A → A) : Nat → A → A
  | 0, a => a
  | n + 1, a => f (iterate f n a)

/-- A revisit propagates forward: if the orbit coincides at `i` and `j`, it
    coincides at `i + k` and `j + k` for every `k` — determinism, iterated. -/
theorem iterate_extend {A : Type} (f : A → A) (s : A) {i j : Nat}
    (h : iterate f i s = iterate f j s) :
    ∀ k, iterate f (i + k) s = iterate f (j + k) s
  | 0 => h
  | k + 1 => congrArg f (iterate_extend f s h k)

/-- Remove the first occurrence of `z`. Local, with `DecidableEq` matched
    directly (no `ite`, so the lemmas below split by `cases` on the instance
    application and stay axiom-free). -/
def eraseFirst {α : Type} [inst : DecidableEq α] : List α → α → List α
  | [], _ => []
  | b :: l, z =>
    match inst b z with
    | isTrue _ => l
    | isFalse _ => b :: eraseFirst l z

/-- Removing a present element shortens the list by exactly one. -/
theorem length_eraseFirst {α : Type} [inst : DecidableEq α] :
    ∀ (l : List α) (z : α), z ∈ l → (eraseFirst l z).length + 1 = l.length := by
  intro l
  induction l with
  | nil => intro z hz; nomatch hz
  | cons b l ih =>
    intro z hz
    show (match inst b z with
      | isTrue _ => l
      | isFalse _ => b :: eraseFirst l z).length + 1 = l.length + 1
    cases inst b z with
    | isTrue _ => rfl
    | isFalse hne =>
      show (eraseFirst l z).length + 1 + 1 = l.length + 1
      cases hz with
      | head => exact absurd rfl hne
      | tail _ hz' => rw [ih z hz']

/-- An element other than the removed one survives the removal. -/
theorem mem_eraseFirst {α : Type} [inst : DecidableEq α] :
    ∀ (l : List α) (z y : α), y ∈ l → y ≠ z → y ∈ eraseFirst l z := by
  intro l
  induction l with
  | nil => intro z y hy _; nomatch hy
  | cons b l ih =>
    intro z y hy hne
    show y ∈ (match inst b z with
      | isTrue _ => l
      | isFalse _ => b :: eraseFirst l z)
    cases inst b z with
    | isTrue hbz =>
      cases hy with
      | head => exact absurd hbz hne
      | tail _ hy' => exact hy'
    | isFalse _ =>
      cases hy with
      | head => exact List.Mem.head _
      | tail _ hy' => exact List.Mem.tail _ (ih z y hy' hne)

/-- Bounded search for an index `k ≤ m` with `x (k+1) = x 0` — the witness is
    found, never chosen. -/
def searchEq {α : Type} [inst : DecidableEq α] (x : Nat → α) : Nat → Option Nat
  | 0 =>
    match inst (x 1) (x 0) with
    | isTrue _ => some 0
    | isFalse _ => none
  | m + 1 =>
    match inst (x (m + 2)) (x 0) with
    | isTrue _ => some (m + 1)
    | isFalse _ => searchEq x m

/-- A successful search is a genuine witness. -/
theorem searchEq_some {α : Type} [inst : DecidableEq α] (x : Nat → α) :
    ∀ m k, searchEq x m = some k → k ≤ m ∧ x (k + 1) = x 0 := by
  intro m
  induction m with
  | zero =>
    intro k h
    show k ≤ 0 ∧ x (k + 1) = x 0
    revert h
    show (match inst (x 1) (x 0) with
      | isTrue _ => some 0
      | isFalse _ => none) = some k → _
    cases inst (x 1) (x 0) with
    | isTrue heq =>
      intro h
      injection h with h
      rw [← h]
      exact ⟨Nat.le_refl 0, heq⟩
    | isFalse _ => intro h; nomatch h
  | succ m ih =>
    intro k h
    revert h
    show (match inst (x (m + 2)) (x 0) with
      | isTrue _ => some (m + 1)
      | isFalse _ => searchEq x m) = some k → _
    cases inst (x (m + 2)) (x 0) with
    | isTrue heq =>
      intro h
      injection h with h
      rw [← h]
      exact ⟨Nat.le_refl (m + 1), heq⟩
    | isFalse _ =>
      intro h
      obtain ⟨hk, heq⟩ := ih k h
      exact ⟨Nat.le_succ_of_le hk, heq⟩

/-- A failed search is a genuine refusal: no index in range matches. -/
theorem searchEq_none {α : Type} [inst : DecidableEq α] (x : Nat → α) :
    ∀ m, searchEq x m = none → ∀ k, k ≤ m → x (k + 1) ≠ x 0 := by
  intro m
  induction m with
  | zero =>
    intro h k hk
    cases hk
    revert h
    show (match inst (x 1) (x 0) with
      | isTrue _ => some 0
      | isFalse _ => none) = none → _
    cases inst (x 1) (x 0) with
    | isTrue _ => intro h; nomatch h
    | isFalse hne => intro _; exact hne
  | succ m ih =>
    intro h k hk
    revert h
    show (match inst (x (m + 2)) (x 0) with
      | isTrue _ => some (m + 1)
      | isFalse _ => searchEq x m) = none → _
    cases inst (x (m + 2)) (x 0) with
    | isTrue _ => intro h; nomatch h
    | isFalse hne =>
      intro h
      cases Nat.lt_or_ge k (m + 1) with
      | inl hlt => exact ih h k (Nat.le_of_lt_succ hlt)
      | inr hge =>
        have : k = m + 1 := Nat.le_antisymm hk hge
        rw [this]
        exact hne

/-- **Pigeonhole, hand-built.** Any sequence whose first `n+1` values all lie
    in a covering list of length `n` revisits: there are `i < j ≤ n` with
    `x i = x j`. Induction on the bound, removing the first value's slot from
    the cover each round. -/
theorem pigeon' {α : Type} [inst : DecidableEq α] :
    ∀ (n : Nat) (xs : List α), xs.length = n → ∀ x : Nat → α,
      (∀ k, k ≤ n → x k ∈ xs) → ∃ i j, i < j ∧ j ≤ n ∧ x i = x j := by
  intro n
  induction n with
  | zero =>
    intro xs hlen x hx
    cases xs with
    | nil => exact absurd (hx 0 (Nat.le_refl 0)) (fun h => nomatch h)
    | cons b l => nomatch hlen
  | succ m ih =>
    intro xs hlen x hx
    cases hs : searchEq x m with
    | some k =>
      obtain ⟨hk, heq⟩ := searchEq_some x m k hs
      exact ⟨0, k + 1, Nat.succ_pos k, Nat.succ_le_succ hk, heq.symm⟩
    | none =>
      have hne := searchEq_none x m hs
      have hx0 : x 0 ∈ xs := hx 0 (Nat.zero_le _)
      have hzlen : (eraseFirst xs (x 0)).length + 1 = xs.length :=
        length_eraseFirst xs (x 0) hx0
      have hzlen' : (eraseFirst xs (x 0)).length = m := by
        rw [hlen] at hzlen
        exact Nat.succ.inj hzlen
      have hy : ∀ k, k ≤ m → x (k + 1) ∈ eraseFirst xs (x 0) := by
        intro k hk
        exact mem_eraseFirst xs (x 0) (x (k + 1))
          (hx (k + 1) (Nat.succ_le_succ hk)) (hne k hk)
      obtain ⟨i, j, hij, hjm, heq⟩ := ih (eraseFirst xs (x 0)) hzlen'
        (fun k => x (k + 1)) hy
      exact ⟨i + 1, j + 1, Nat.succ_lt_succ hij, Nat.succ_le_succ hjm, heq⟩

/-- Pigeonhole at the cover's own length. -/
theorem pigeon {α : Type} [DecidableEq α] (xs : List α) (x : Nat → α)
    (hx : ∀ k, k ≤ xs.length → x k ∈ xs) :
    ∃ i j, i < j ∧ j ≤ xs.length ∧ x i = x j :=
  pigeon' xs.length xs rfl x hx

/-- A clock: a behavior driven by nothing but its own state — deterministic
    step, readout, no input. It never grounds (`some` forever), and what it
    emits is entirely a function of where it started. -/
def clockRun {A S : Type} (f : A → A) (out : A → S) (s₀ : A) : CoList S :=
  ⟨fun n => some (out (iterate f n s₀)), fun _ h => nomatch h⟩

/-- **A clock loops.** Any self-driven behavior over finite state (a covering
    list, equality decidable) is eventually periodic: the orbit revisits by
    pigeonhole, and determinism propagates the revisit forever. "The foam's
    entire future is determined by its birth... nothing to distinguish" — the
    wind, input from beyond the state, is the only door past the loop. -/
theorem clock_loops {A S : Type} [DecidableEq A] (f : A → A) (out : A → S)
    (s₀ : A) (xs : List A) (cover : ∀ a, a ∈ xs) :
    EventuallyPeriodic (clockRun f out s₀) := by
  obtain ⟨i, j, hij, _, heq⟩ :=
    pigeon xs (fun n => iterate f n s₀) (fun k _ => cover _)
  obtain ⟨d, hd⟩ := Nat.le.dest hij
  refine ⟨i, d + 1, Nat.succ_pos d, fun n hn => ?_⟩
  obtain ⟨k, hk⟩ := Nat.le.dest hn
  have hstep : iterate f (i + k) s₀ = iterate f (j + k) s₀ :=
    iterate_extend f s₀ heq k
  have hj : j = i + (d + 1) := by
    rw [← hd]
    exact Nat.succ_add i d
  have harith : n + (d + 1) = j + k := by
    rw [← hk, hj]
    exact Nat.add_right_comm i k (d + 1)
  show some (out (iterate f (n + (d + 1)) s₀)) = some (out (iterate f n s₀))
  rw [harith, ← hk]
  exact congrArg (fun a => some (out a)) hstep.symm

end Foam
