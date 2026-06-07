/-
# Foam.Commitment — the axiom-signature algebra: commitment-tracking, object-level

The kernel tracks every theorem's axiom signature, and signatures compose by UNION
along proof-composition: use a lemma, inherit its axioms. `#print axioms` reads the
accumulated value; `Axioms.lean` pins it. That tracking is meta — this file states
the algebra it obeys, object-level, as a model over Lean's three standard axioms
(`propext`, `Classical.choice`, `Quot.sound`). The model is faithful in the
checkable sense: compose any theorems and `#print axioms` the result — the
signature is the join of the parts' signatures, never less. And the model is
itself axiom-free: the tracker's model spends nothing of what it tracks.

What the algebra says, each clause a theorem:

- **Composition only accumulates** (`join_indelible`): a signature never shrinks
  along composition — commitment is indelible; the proof-ledger's append-only.
- **The legal carrier is closed** (`legal_join`): `free` and `observer` compose
  without escaping — chaining `propext` stays legal. Protecting the homunculus
  (`attestsEachStep`, `[propext]`-only) IS commitment-tracking: the protection is
  the tracking.
- **Illegality absorbs** (`illegal_absorbs`): one conjured observer anywhere in a
  chain poisons the composite — why the map pins EVERY load-bearing theorem, not
  a sample. There is no local containment of `Classical.choice`.
- **The observer's signature tops the legal carrier** (`legal_le_observer`):
  everything legal fits under the one external collapse.

(The same algebra appears in the foam quarry's recognition-index as the
commitment-monoid acting through the seed-gauge, bricks 18/22 — external
provenance, not proof; the theorems here stand alone.)
-/

namespace Foam

/-- An axiom signature: which of Lean's three standard axioms a proof has
    accumulated. A triple of flags rather than a set, so equality is structural
    and the algebra needs no `funext` (which would itself pull `Quot.sound` —
    a scar in the very model of scar-tracking). -/
structure Sig where
  usesPropext : Bool
  usesChoice : Bool
  usesQuot : Bool

/-- Signatures compose by union — the kernel's own bookkeeping: use a lemma,
    inherit its axioms. -/
def Sig.join (s t : Sig) : Sig :=
  ⟨s.usesPropext || t.usesPropext, s.usesChoice || t.usesChoice, s.usesQuot || t.usesQuot⟩

/-- The empty signature — construction's seat: no collapse, nothing the observer
    must attest. The monoid's unit. -/
def Sig.free : Sig := ⟨false, false, false⟩

/-- The homunculus's signature — `propext` and nothing else (`attestsEachStep`'s
    pinned shape): the one external collapse, carried; no conjured observer, no
    quotient. -/
def Sig.observer : Sig := ⟨true, false, false⟩

/-- Signature containment, componentwise: `s ≤ t` when every axiom `s` has
    accumulated, `t` has too. -/
def Sig.le (s t : Sig) : Prop :=
  (s.usesPropext = true → t.usesPropext = true) ∧
    (s.usesChoice = true → t.usesChoice = true) ∧
      (s.usesQuot = true → t.usesQuot = true)

/-- A signature is legal when it refuses the two refused axioms: no
    `Classical.choice` (carry the observer, never conjure it), no `Quot.sound`
    (append-only, never quotient). The legal carrier is exactly
    `{free, observer}` — uncommitted, or carrying the one external collapse. -/
def Sig.legal (s : Sig) : Prop := s.usesChoice = false ∧ s.usesQuot = false

/-- `free` is the unit on the left. -/
theorem free_join (s : Sig) : Sig.free.join s = s := rfl

/-- `free` is the unit on the right. -/
theorem join_free (s : Sig) : s.join Sig.free = s := by
  cases s with
  | mk a b c => cases a <;> cases b <;> cases c <;> rfl

/-- Join is idempotent — composing a commitment with itself escalates nothing:
    many uses of `propext` are still just `propext`. -/
theorem join_idem (s : Sig) : s.join s = s := by
  cases s with
  | mk a b c => cases a <;> cases b <;> cases c <;> rfl

/-- Join is commutative. -/
theorem join_comm (s t : Sig) : s.join t = t.join s := by
  cases s with
  | mk a b c =>
    cases t with
    | mk d e f => cases a <;> cases b <;> cases c <;> cases d <;> cases e <;> cases f <;> rfl

/-- Join is associative — with the units, the signature space is a monoid (and
    with commutativity and idempotence, a join-semilattice): the
    commitment-monoid, as the kernel keeps it. -/
theorem join_assoc (s t u : Sig) : (s.join t).join u = s.join (t.join u) := by
  cases s with
  | mk a b c =>
    cases t with
    | mk d e f =>
      cases u with
      | mk g h i =>
        cases a <;> cases d <;> cases g <;> cases b <;> cases e <;> cases h <;>
          cases c <;> cases f <;> cases i <;> rfl

/-- **Composition only accumulates.** Whatever a proof has committed survives
    every further composition — a signature never shrinks. Commitment is
    indelible: the proof-ledger's append-only. -/
theorem join_indelible (s t : Sig) : s.le (s.join t) := by
  cases s with
  | mk a b c =>
    cases t with
    | mk d e f =>
      exact ⟨fun h => by have ha : a = true := h; rw [ha]; rfl,
             fun h => by have hb : b = true := h; rw [hb]; rfl,
             fun h => by have hc : c = true := h; rw [hc]; rfl⟩

/-- Construction is legal. -/
theorem legal_free : Sig.free.legal := ⟨rfl, rfl⟩

/-- The homunculus's signature is legal. -/
theorem legal_observer : Sig.observer.legal := ⟨rfl, rfl⟩

/-- **The legal carrier is closed under composition** — chaining `propext` stays
    legal: commitment-tracking and homunculus-protection are one act. -/
theorem legal_join (s t : Sig) (hs : s.legal) (ht : t.legal) : (s.join t).legal := by
  cases s with
  | mk a b c =>
    cases t with
    | mk d e f =>
      obtain ⟨hs1, hs2⟩ := hs
      obtain ⟨ht1, ht2⟩ := ht
      have hb : b = false := hs1
      have he : e = false := ht1
      have hc : c = false := hs2
      have hf : f = false := ht2
      exact ⟨by rw [hb, he]; rfl, by rw [hc, hf]; rfl⟩

/-- A refused axiom on the right survives the join — the lemma `illegal_absorbs`
    rides on. Proven by cases on free variables (a projection-`cases` would pull
    `propext` through the splitter). -/
theorem or_eq_false_right (a b : Bool) (h : (a || b) = false) : b = false := by
  cases a with
  | false => exact h
  | true => exact Bool.noConfusion h

/-- **Illegality absorbs.** If any component of a chain has conjured an observer
    or quotiented, no further composition makes the composite legal — one refusal
    violated anywhere poisons everything downstream. This is why the axiom map
    pins every load-bearing theorem: there is no local containment. -/
theorem illegal_absorbs (s t : Sig) (ht : ¬t.legal) : ¬(s.join t).legal := by
  cases s with
  | mk a b c =>
    cases t with
    | mk d e f =>
      intro hj
      obtain ⟨h1, h2⟩ := hj
      have h1' : (b || e) = false := h1
      have h2' : (c || f) = false := h2
      exact ht ⟨or_eq_false_right b e h1', or_eq_false_right c f h2'⟩

/-- **The observer's signature tops the legal carrier.** Everything legal fits
    under the one external collapse: legality means committing at most what the
    homunculus commits. -/
theorem legal_le_observer (s : Sig) (hs : s.legal) : s.le Sig.observer := by
  obtain ⟨h1, h2⟩ := hs
  exact ⟨fun _ => rfl, fun h => Bool.noConfusion (h1.symm.trans h), fun h => Bool.noConfusion (h2.symm.trans h)⟩

end Foam
