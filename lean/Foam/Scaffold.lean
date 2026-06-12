/-
# Foam.Scaffold — the dimensionality scaffold (the lift is one move; the prices are theorems)

Received from awareness.md and the table (2026-06-12), the same sitting that
named the operating manual: **don't take a liberty the next dimension
outlaws.** The conjecture under it: digital physics is generically a
dimensionality scaffold — the safe lifts are constrained, "safe" meaning
provably free of higher-dimensional moves you'll pay for later, and every
rung's physics is DERIVABLE from the lift itself, never legislated.

This file claims the house-scale piece: the lift is ONE move (the
Cayley–Dickson doubling, `Rung n × Rung n` with the twisted product), and
each rung's price is a witness the kernel computes:

- **The first lift pays order** (`lift_one_pays_order`): a square turns
  negative — i² = −1, at dimension two. (What's bought: phase,
  cancellation, interference — `Spectrum`, `Born`. The norm still composes
  here: the two-square identity, `int_lagrange`, already on the floor.)
- **The second lift pays commutation** (`lift_two_pays_commutation`):
  e₁e₂ = −e₂e₁ at dimension four. Speech-order arrives — `Doubling`'s
  `order_arrives`, met here from the generic construction.
- **The third lift pays association** (`lift_three_pays_association`):
  (e₁e₂)e₄ = −(e₁(e₂e₄)) at dimension eight. Grouping becomes
  path-dependent: HOW you compose is now data — the path-space refusing
  its quotient, again.
- **The fourth lift pays presence** (`lift_four_pays_presence`):
  (e₁+e₁₀)(e₄−e₁₅) = 0 at dimension sixteen, both factors nonzero.
  Presence composed with presence yields absence, and the norm stops
  composing (`norm_stops_composing`: 2·2 ≠ 0). Conservation of magnitude —
  the thing every rung below carries — does not survive this lift.

So the safe rungs are dimensions 1, 2, 4, 8 — FOUR of them, one full
measure — and the fifth position overflows. The general impossibility
(Hurwitz: composition algebras exist at exactly 1, 2, 4, 8) is cited, not
claimed; what is claimed is what the kernel checks: this ladder, this
convention, these witnesses. No magic numbers — the analog world measures
its constants, and a digital world derives them; even the ladder's TOP
arrives as a theorem, not a setting.

Readings, labeled as readings: awareness.md's measure — positions 0–3,
"everything is mod 4 in concept," the third position where "complexity
overflows: awareness can't explore past here without dropping its original
position" — runs in exact parallel: four inhabitable rungs, then a lift
that costs the conservation of presence itself. And the report recorded
there ("one more step would mean losing my grip… I had to WAIT until my
grip solidified") reads as the safe-lift criterion, lived: past the last
composition rung, nonzero things multiply to nothing. The commitment
algebra (`Commitment.lean` — signatures compose by union, never shed) is
the same law on the proof side: what you take on at rung n travels up
every lift after it. Solvency at every higher rung is what "safe" means.

Pure construction — axiom-free, every theorem, refusals included. The
equalities are `rfl`-grade (the kernel computes the products); the
refusals are `decide` on hand-rolled decidable equality.
-/

namespace Foam

/-- The scaffold's carrier: rung 0 is the integer floor; each lift doubles.
    `Rung n` has dimension 2ⁿ. -/
def Rung : Nat → Type
  | 0 => Int
  | n + 1 => Rung n × Rung n

/-- Zero, at every rung. -/
def Rung.zero : (n : Nat) → Rung n
  | 0 => (0 : Int)
  | n + 1 => (Rung.zero n, Rung.zero n)

/-- Addition, coordinatewise. -/
def Rung.add : (n : Nat) → Rung n → Rung n → Rung n
  | 0, a, b => Int.add a b
  | n + 1, x, y => (Rung.add n x.1 y.1, Rung.add n x.2 y.2)

/-- Negation, coordinatewise. -/
def Rung.neg : (n : Nat) → Rung n → Rung n
  | 0, a => Int.neg a
  | n + 1, x => (Rung.neg n x.1, Rung.neg n x.2)

/-- Subtraction. -/
def Rung.sub (n : Nat) (x y : Rung n) : Rung n :=
  Rung.add n x (Rung.neg n y)

/-- Conjugation: fix the first coordinate's conjugate, negate the second —
    the involution the doubling twists by. At the floor it is the identity
    (an integer is its own mirror). -/
def Rung.conj : (n : Nat) → Rung n → Rung n
  | 0, a => a
  | n + 1, x => (Rung.conj n x.1, Rung.neg n x.2)

/-- **The one move.** The Cayley–Dickson product:
    (a,b)(c,d) = (ac − d̄b, da + bc̄). Every rung's multiplication is this
    move applied to the rung below; nothing else is ever introduced. The
    prices below are consequences of this definition alone. -/
def Rung.mul : (n : Nat) → Rung n → Rung n → Rung n
  | 0, a, b => Int.mul a b
  | n + 1, x, y =>
    (Rung.sub n (Rung.mul n x.1 y.1) (Rung.mul n (Rung.conj n y.2) x.2),
     Rung.add n (Rung.mul n y.2 x.1) (Rung.mul n x.2 (Rung.conj n y.1)))

/-- The squared norm: the sum of the squares of all 2ⁿ coordinates — the
    conserved magnitude, while it lasts. -/
def Rung.normSq : (n : Nat) → Rung n → Int
  | 0, a => Int.mul a a
  | n + 1, x => Rung.normSq n x.1 + Rung.normSq n x.2

/-- The i-th basis element (i < 2ⁿ): a single 1 in an ocean of zeros. -/
def Rung.e : (n : Nat) → Nat → Rung n
  | 0, _ => (1 : Int)
  | n + 1, i =>
    if i < 2 ^ n then (Rung.e n i, Rung.zero n)
    else (Rung.zero n, Rung.e n (i - 2 ^ n))

/-- Decidable equality, hand-rolled by recursion on the rung. -/
def Rung.decEq : (n : Nat) → DecidableEq (Rung n)
  | 0 => (inferInstance : DecidableEq Int)
  | n + 1 => fun x y =>
    @instDecidableEqProd _ _ (Rung.decEq n) (Rung.decEq n) x y

instance {n : Nat} : DecidableEq (Rung n) := Rung.decEq n

/-- **The first lift pays order.** At dimension two a square turns
    negative: e₁² = −e₀. No ordering survives (a nonzero square below
    zero); what's bought is the quarter-turn — phase, cancellation,
    interference. The kernel computes both sides. -/
theorem lift_one_pays_order :
    Rung.mul 1 (Rung.e 1 1) (Rung.e 1 1) = Rung.neg 1 (Rung.e 1 0) := rfl

/-- **The second lift pays commutation.** At dimension four, e₁e₂ and e₂e₁
    answer in opposite signs: who spoke first is now data. `Doubling`'s
    `order_arrives`, met from the generic move. -/
theorem lift_two_pays_commutation :
    Rung.mul 2 (Rung.e 2 1) (Rung.e 2 2)
      = Rung.neg 2 (Rung.mul 2 (Rung.e 2 2) (Rung.e 2 1))
    ∧ Rung.mul 2 (Rung.e 2 1) (Rung.e 2 2)
      ≠ Rung.mul 2 (Rung.e 2 2) (Rung.e 2 1) :=
  ⟨rfl, by decide⟩

/-- **The third lift pays association.** At dimension eight, (e₁e₂)e₄ and
    e₁(e₂e₄) answer in opposite signs: HOW the composition was grouped is
    now data — the path refusing its quotient, at the algebra's own
    scale. -/
theorem lift_three_pays_association :
    Rung.mul 3 (Rung.mul 3 (Rung.e 3 1) (Rung.e 3 2)) (Rung.e 3 4)
      = Rung.neg 3 (Rung.mul 3 (Rung.e 3 1) (Rung.mul 3 (Rung.e 3 2) (Rung.e 3 4)))
    ∧ Rung.mul 3 (Rung.mul 3 (Rung.e 3 1) (Rung.e 3 2)) (Rung.e 3 4)
      ≠ Rung.mul 3 (Rung.e 3 1) (Rung.mul 3 (Rung.e 3 2) (Rung.e 3 4)) :=
  ⟨rfl, by decide⟩

/-- The first sedenion witness: e₁ + e₁₀. Nonzero — two whole units of
    presence. -/
def sedLeft : Rung 4 := Rung.add 4 (Rung.e 4 1) (Rung.e 4 10)

/-- The second sedenion witness: e₄ − e₁₅. Nonzero — two whole units of
    presence. -/
def sedRight : Rung 4 := Rung.sub 4 (Rung.e 4 4) (Rung.e 4 15)

/-- **The fourth lift pays presence.** At dimension sixteen, two nonzero
    elements multiply to zero: presence composed with presence yields
    absence. This is the rung past the last composition algebra — the
    overflow position, the step whose price is the grip itself. -/
theorem lift_four_pays_presence :
    sedLeft ≠ Rung.zero 4 ∧ sedRight ≠ Rung.zero 4
      ∧ Rung.mul 4 sedLeft sedRight = Rung.zero 4 :=
  ⟨by decide, by decide, rfl⟩

/-- **The norm stops composing.** Each witness carries magnitude 2; their
    product carries none. Conservation of magnitude — held at every rung
    below (the two-square identity is `int_lagrange`, on the floor) — does
    not survive the fourth lift. The safe rungs are four: one full
    measure. -/
theorem norm_stops_composing :
    Rung.normSq 4 sedLeft * Rung.normSq 4 sedRight
      ≠ Rung.normSq 4 (Rung.mul 4 sedLeft sedRight) := by
  decide

end Foam
