/-
# Foam.Scar — stale observation escapes the floor; the scar; the correcting entry

`Drain.lean`'s floor is typal: charge is a `Nat`, `drainOne` observes and mutates in
ONE step, and ground (`0`) is unpassable by construction. The operational drain
(`foam.speak`) decomposes that step: OBSERVE the balance (the `HAVING sum(delta) > 0`
snapshot), then APPEND the `−1`. Two walks whose observations share a snapshot — both
see `+1` before either's `−1` lands — compose into an operation that is not
`drainOne` at all: it lands at `−1`, a value the `Nat` carrier cannot represent.

This was observed, not hypothesized: 2026-06-06, on a live field, a 2000-step pipe
exhale and a 600-step repl interjection drained concurrently and left 76 balances at
`−1`. The conservation pulse (`net = residual`) caught it on the first reading.

The map this file records:

- **The race witness** (`stale_escapes_floor`): two drains against one stale
  observation reach `−1`. By `rfl` — the bug is a computation, not a possibility.
- **Ground, without order** (`grounded`): a signed balance is grounded when it is in
  the image of the atomic carrier (`∃ m : Nat, b = ofNat m`). The floor is not an
  inequality — it is membership in the type the theorems quantify over.
- **The fresh-observation floor** (`fresh_holds_floor`): one checked drain whose
  observation IS the balance it lands on stays grounded — `drain_floor`, rebuilt on
  the signed carrier.
- **Serialization restores the theorem** (`drainSeq_holds_floor`): any number of
  fresh-observation drains — what the writers' lock makes of any interleaving —
  stays grounded.
- **The scar, defined** (`scar_outside_carrier`): `−1` is outside the image. The
  scarred pairs are not corrupt rows — they are values from outside the type the
  floor quantifies over, the trace of an operation the atomic model does not
  contain. That is what makes them a correctness gap rather than a surprise, and
  atomicity (the lock) the repair of the *cause*.
- **The correcting entry** (`scar_repair`): a scar at `−1` is returned to ground by
  APPENDING `+1` — the ledger's own idiom for error (acknowledge, never erase; the
  erroneous events remain in the order reading, and so does the acknowledgment).
  Append-only legal; the repair of the *effect* is construction, by `rfl`.

Positivity is defined by constructor (`isPos`, non-overlapping match — the splitter
stays quiet) so every reduction is definitional and the file stays axiom-free: pure
`rfl`/`rw`/induction, witnesses obtained never chosen.
-/

namespace Foam

/-- Positivity on the signed carrier, by constructor — non-overlapping patterns, so
    proofs reduce definitionally (the `0 < ·` order form would be the same gate, but
    its `Decidable` instance does not reduce on an open `Nat`). This is the
    `HAVING sum(delta) > 0` filter, as structure. -/
def isPos : Int → Bool
  | Int.ofNat 0 => false
  | Int.ofNat (_ + 1) => true
  | Int.negSucc _ => false

/-- The operational drain, decomposed: remove one iff the OBSERVED balance is
    positive. `obs` is the snapshot the check ran against; `bal` is the balance the
    append actually lands on. Atomic means `obs = bal`; the race is a stale snapshot
    (`obs ≠ bal`). The carrier is `Int` — the SQL's signed sum — precisely so the
    escape is representable. -/
def checkedDrain (obs bal : Int) : Int :=
  match isPos obs with
  | true => bal - 1
  | false => bal

/-- **The race witness.** Two drains against the SAME stale observation (both saw
    `1`, before either's `−1` landed): the composite reaches `−1` — below ground,
    outside the `Nat` carrier. The 76, as one term. By `rfl`: the bug is a
    computation. -/
theorem stale_escapes_floor : checkedDrain 1 (checkedDrain 1 1) = -1 := rfl

/-- Ground as image-membership: a signed balance is grounded when some `Nat` charge
    reads as it. The floor, stated without order. -/
def grounded (b : Int) : Prop := ∃ m : Nat, b = Int.ofNat m

/-- `1 - (k + 1) = 0`, locally — core's subtraction lemmas carry `propext`; this one
    is induction and `rw` only. -/
theorem one_sub_succ (k : Nat) : 1 - (k + 1) = 0 := by
  induction k with
  | zero => rfl
  | succ j ih => show (1 - (j + 1)).pred = 0; rw [ih]; rfl

/-- The atomic drain on a positive balance steps down the `Nat` image:
    `ofNat (k+1) − 1 = ofNat k`. The signed subtraction lands exactly where
    `drainOne` does. -/
theorem ofNat_succ_sub_one (k : Nat) : Int.ofNat (k + 1) - 1 = Int.ofNat k := by
  show Int.subNatNat (k + 1) 1 = Int.ofNat k
  unfold Int.subNatNat
  rw [one_sub_succ]
  rfl

/-- **Fresh observation stays grounded.** When the observation IS the balance the
    drain lands on (atomic check-and-drain — one walk, or serialized walks), the
    result remains in the `Nat` image: `drain_floor`, rebuilt on the signed
    carrier. -/
theorem fresh_holds_floor (bal : Int) (h : grounded bal) : grounded (checkedDrain bal bal) := by
  obtain ⟨m, rfl⟩ := h
  cases m with
  | zero => exact ⟨0, rfl⟩
  | succ k => exact ⟨k, ofNat_succ_sub_one k⟩

/-- A sequence of fresh-observation drains — what the writers' lock makes of any
    interleaving. -/
def drainSeq : Nat → Int → Int
  | 0, bal => bal
  | k + 1, bal => drainSeq k (checkedDrain bal bal)

/-- **Serialization restores the theorem.** Any number of drains, each observing
    fresh (the lock's guarantee: every walk sees the previous walk's writes), stays
    grounded. The interleaving that scarred the field is exactly what this `∀ k`
    excludes — not by hoping walks don't overlap, but by making overlap mean
    queueing. -/
theorem drainSeq_holds_floor (k : Nat) (bal : Int) (h : grounded bal) :
    grounded (drainSeq k bal) := by
  induction k generalizing bal with
  | zero => exact h
  | succ n ih => exact ih (checkedDrain bal bal) (fresh_holds_floor bal h)

/-- **The scar, defined.** A balance of `−1` is outside the image of the atomic
    carrier: no `Nat` charge reads as it. Constructor disjointness — the cheapest
    possible refutation, and the whole diagnosis. -/
theorem scar_outside_carrier : ∀ m : Nat, (Int.ofNat m) ≠ (-1 : Int) := by
  intro m h
  exact Int.noConfusion h

/-- **The correcting entry.** A scar at `−1` returns to ground by APPENDING `+1` —
    no update, no delete; the erroneous `−1`s stay in the order reading and so does
    the acknowledgment. The ledger's own idiom for error, and it is construction:
    by `rfl`. -/
theorem scar_repair : (-1 : Int) + 1 = 0 := rfl

end Foam
