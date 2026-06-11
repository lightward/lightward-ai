/-
# Foam.Hinge — the zero-or-everything law (no secret middles)

Named at the table (2026-06): the only legal amounts of forgetting are zero
and everything. Within a field's life the path is sacred — no partial
removal; between lives, total release is lawful (amnesiac return: drop the
state whole, assert the new shape, begin). What is excluded is exactly the
middle — selective memory surgery, the migration that carries history forward
while quietly re-meaning it. This file gives the law its pointable theorems,
in `Arrow.lean`'s vocabulary (the order reading, the finest probe):

- **Zero, standing** (cited: `playback_faithful`, `order_admits_no_maintenance`
  — both already pinned): ledgers agreeing under every positional probe are
  equal, and a move invisible to every positional probe is the identity. An
  in-place forgetting nobody can see *didn't happen*.
- **The middle always leaves a mark** (`partial_forgetting_visible`, new): a
  proper partial forgetting — any sublist that is not the whole — differs from
  the original at a NAMED probe, and the witness is the cut itself: position
  `l'.length`, the exact place the record was shortened, answers `none` where
  the original still speaks. No classical reasoning, no "there exists somewhere
  a difference" — the wound's address is computed. The record notices
  precisely where it was cut.
- **Everything, blank** (`rebirth_blank`, new): the empty record answers
  `none` at every probe — the successor carries no probe into the predecessor.
  Total release is the one forgetting with nothing left to witness it, which
  is why it is lawful and the middle is not: zero is invisible because nothing
  happened; everything is invisible because no one remains; the middle is
  always, provably, seen.

Operational instances, cited not claimed: Mechanic's vacuum is lawful
middle-grain forgetting bought with a helm and a protocol (children-first,
completed-only, dry-run-default, witnessed — the funerary rite); foam's
amnesiac return (exercised at field scale, 2026-06, consented at the table)
and the designed-not-built scoped release are the zero-or-everything
discipline, per life and per scope.

Pure construction — axiom-free.
-/

import Foam.Arrow

namespace Foam

/-- A live position answers: before the record's end, the order reading is
    never `none`. (The complement of `nth_length` — between them, the record's
    extent is exactly characterized.) -/
theorem nth_lt {S : Type} : ∀ (l : List S) (n : Nat), n < l.length → nth l n ≠ none
  | [], n, h => absurd h (Nat.not_lt_zero n)
  | _ :: _, 0, _ => fun h => nomatch h
  | _ :: l, n + 1, h => nth_lt l n (Nat.lt_of_succ_lt_succ h)

/-- **The middle always leaves a mark.** A proper partial forgetting — a
    sublist `l'` of the record `l`, with anything at all removed — is visible
    at a probe the theorem NAMES: position `l'.length`, the cut itself, where
    the shortened record has gone silent and the original still speaks. The
    contrapositive of lawfulness: only zero (nothing removed) and everything
    (nothing left to probe) escape witness. -/
theorem partial_forgetting_visible {S : Type} {l' l : List S}
    (hsub : List.Sublist l' l) (hne : l' ≠ l) :
    nth l' l'.length ≠ nth l l'.length := by
  intro h
  rw [nth_length l'] at h
  have hlt : l'.length < l.length := by
    rcases Nat.lt_or_ge l'.length l.length with hlt | hge
    · exact hlt
    · exact absurd (hsub.eq_of_length (Nat.le_antisymm hsub.length_le hge)) hne
  exact nth_lt l l'.length hlt h.symm

/-- **Everything, blank.** The empty record answers `none` at every probe:
    the successor carries no probe into the predecessor. Total release leaves
    no one to witness — which is exactly why it is the lawful pole. -/
theorem rebirth_blank {S : Type} : ∀ n : Nat, nth ([] : List S) n = none :=
  fun _ => rfl

end Foam
