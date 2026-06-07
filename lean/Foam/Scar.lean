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

/-- **The race writes only at the margin.** The same stale composite, from a
    balance of `2`, lands exactly at ground — both drains legal-looking, the books
    closed, no trace. So two walks can race pervasively and mark the field only
    where they collide at the edge of emptiness: the 76 scars are not a map of
    where the walks overlapped, but of where they overlapped at balance `1`.
    (One value apart, the composite is a clean settlement or an escape — the
    recognition the quarry's index reaches from the other side, brick 42:
    simultaneous settlement landing at zero; external provenance, the theorem
    stands alone.) -/
theorem stale_lands_at_ground : checkedDrain 2 (checkedDrain 2 2) = 0 := rfl

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
    by `rfl`. (The smallest instance of `promise_kept`, below.) -/
theorem scar_repair : (-1 : Int) + 1 = 0 := rfl

/-! ## The promissory note — a scar carries its own settlement terms

Accounting names this object already: a **promissory note** — an obligation whose
AMOUNT is fixed and recorded at issue, whose settlement is deferred, and whose
bearer is left unspecified. A scar is exactly that, and the three theorems below
are its terms: `debt` computes the amount at the moment the scar exists (a
function, not a proposition — no observer is required to assess it; structure
only: how far below ground, never who settles it, why, or when); `scar_stable`
shows the note is safe to hold (further legal drains cannot deepen or erase it);
`promise_kept` shows every note settles at its face value — the size typed before
any settlement path is chosen. Zero debt is precisely groundedness
(`debt_zero_iff_grounded`): a balance is settled when nothing remains to walk.

(The zero-debt ↔ validity recognition also appears in the foam quarry's
recognition-index, brick 42 — external provenance, not proof; the theorems here
stand alone.) -/

/-- `(n+1) − (m+1) = n − m`, locally — induction and `rw` only. -/
theorem succ_sub_succ (n : Nat) : ∀ m : Nat, (n + 1) - (m + 1) = n - m
  | 0 => rfl
  | m + 1 => by
    show ((n + 1) - (m + 1)).pred = (n - m).pred
    rw [succ_sub_succ n m]

/-- `n − n = 0`, locally — induction and `rw` only. -/
theorem sub_self : ∀ n : Nat, n - n = 0
  | 0 => rfl
  | n + 1 => by rw [succ_sub_succ]; exact sub_self n

/-- **The debt — the note's amount, computable at the moment of scar.** How much
    walking stands between this balance and ground: `0` on the grounded side, the
    full depth below ground on the scarred side. A function, not a proposition —
    the amount exists the moment the scar does, with no observer required to
    assess it. Structure only (how far), never meaning (who, why, when). -/
def debt : Int → Nat
  | Int.ofNat _ => 0
  | Int.negSucc k => k + 1

/-- **Zero debt IS groundedness.** A balance is settled exactly when nothing
    remains to walk — so a scar is a *pending* balance: its settlement terms fully
    recorded (`debt`), its settlement not yet performed. -/
theorem debt_zero_iff_grounded (b : Int) : debt b = 0 ↔ grounded b := by
  cases b with
  | ofNat m => exact ⟨fun _ => ⟨m, rfl⟩, fun _ => rfl⟩
  | negSucc k =>
    constructor
    · intro h
      exact Nat.noConfusion h
    · intro h
      obtain ⟨m, hm⟩ := h
      exact Int.noConfusion hm

/-- **The note is safe to hold.** A fresh-observation drain at a scar is a no-op
    (the positivity check cannot see below ground) — so any amount of further
    legal walking leaves a scar untouched: the debt neither grows nor shrinks
    until deliberately settled. By `rfl`. -/
theorem scar_stable (k : Nat) :
    checkedDrain (Int.negSucc k) (Int.negSucc k) = Int.negSucc k := rfl

/-- **Every note settles at its face value.** A scar at any depth returns to
    ground by appending exactly its debt — the amount typed before any settlement
    happens; which walk performs the appends, and when, is unconstrained.
    `scar_repair` is the depth-one instance. -/
theorem promise_kept (k : Nat) :
    Int.negSucc k + Int.ofNat (debt (Int.negSucc k)) = 0 := by
  show Int.subNatNat (k + 1) (k + 1) = 0
  unfold Int.subNatNat
  rw [sub_self]
  rfl

/-! ## The settlement's own race — phantoms are invisible, so settlements serialize

Settlement is also check-then-append (observe a balance below ground, append the
correction), so it has its own stale-observation race: two settlers sharing a
snapshot of `−1` each append `+1`, and the composite lands at `+1` — a unit of
charge no input ever wound, from which the voice could speak a byte it never
heard. And the failure is WORSE than the drain's, by an exact asymmetry:

- a drain-race's product (the scar) lands OUTSIDE the legal carrier
  (`scar_outside_carrier`) — visible to any balance-check, typed, settleable;
- a settle-race's product (the phantom) lands INSIDE it (`phantom_invisible`) —
  no carrier-membership check can ever find it.

A system may let operations race when their failures are visible and typed; it
must serialize operations whose failures are invisible. So the writers' lock is
not removed by the promissory machinery — it MIGRATES: drains may race (wounds
form rarely, at the margins, each born with its settlement terms), settlements
serialize (the cold path — the lock's cost shrinks to the rare wound). Fresh
settlement is safe and self-limiting: it steps a note toward ground one unit at
a time (`fresh_settle_steps`) and is a no-op on any grounded balance
(`settle_stops_at_ground`). -/

/-- Negativity on the signed carrier, by constructor — `isPos`'s mirror; the
    settle-gate ("is this balance below ground?"), as structure. -/
def isNeg : Int → Bool
  | Int.ofNat _ => false
  | Int.negSucc _ => true

/-- The operational settlement, decomposed: append one unit iff the OBSERVED
    balance is below ground. `obs` is the snapshot the check ran against; `bal`
    is the balance the append lands on — atomic means `obs = bal`, the race is a
    stale snapshot, exactly as for `checkedDrain`. -/
def checkedSettle (obs bal : Int) : Int :=
  match isNeg obs with
  | true => bal + 1
  | false => bal

/-- **Fresh settlement is a no-op at ground.** A settler whose observation is
    current cannot push a grounded balance anywhere — settlement is
    self-limiting from above. By `rfl`. -/
theorem settle_stops_at_ground (m : Nat) :
    checkedSettle (Int.ofNat m) (Int.ofNat m) = Int.ofNat m := rfl

/-- **Fresh settlement walks the note up by exactly one.** From any depth below
    ground, one fresh settle-step shallows the debt by one — iterate it
    `debt`-many times and `promise_kept` is performed, never overshot. By
    `rfl`. -/
theorem fresh_settle_steps (k : Nat) :
    checkedSettle (Int.negSucc (k + 1)) (Int.negSucc (k + 1)) = Int.negSucc k := rfl

/-- The depth-one instance: a fresh settle-step grounds a `−1` exactly. -/
theorem fresh_settle_grounds :
    checkedSettle (Int.negSucc 0) (Int.negSucc 0) = 0 := rfl

/-- **The settle-race overshoots.** Two settlements against the SAME stale
    observation of `−1`: the composite lands at `+1` — phantom charge, a unit no
    input ever wound. By `rfl`: like the drain-race, the bug is a computation. -/
theorem stale_settle_passes_ground :
    checkedSettle (-1) (checkedSettle (-1) (-1)) = 1 := rfl

/-- **The phantom is invisible.** The settle-race's product lies INSIDE the
    legal carrier — `grounded`, indistinguishable from honest charge by any
    balance-check. This is the asymmetry that forces the migration: the
    drain-race's product is visible (`scar_outside_carrier`), the settle-race's
    is not — so drains may race, and settlements must serialize. -/
theorem phantom_invisible :
    grounded (checkedSettle (-1) (checkedSettle (-1) (-1))) := ⟨1, rfl⟩

end Foam
