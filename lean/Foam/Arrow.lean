/-
# Foam.Arrow — the implementation arrow: lfp → gfp, typed on foam's own functor

The recognition (Maintenance.lean carries its prose form): an implementation
runs from the inductively-built core — the least fixed point, the smallest
thing closed under its constructors — out to the observationally-specified
interface — the greatest, whatever is consistent with what a stranger may
see — and the implementation IS the mediating arrow. This file types it.

**The lfp end, fully abstract — Lambek's lemma.** For any initial algebra the
constructor step is INVERTIBLE (`alg_unalg` / `unalg_alg_id`): the built side
is losslessly disassemblable, with the inverse not postulated but FOLDED out
of initiality itself. This is the maintenance license at the core: backstage
may take the built structure apart and reassemble it, totally, by theorem.
(Proven from initiality alone — `fold_comm` + `fold_unique` + the functor
laws; `map_congr` is carried as a field so no `funext` is ever needed.)

**The gfp end, concrete — and the blockage is a finding.** Core Lean has no
coinductive types, so the observational side is REPRESENTED: `CoList` is a
probe-function (`at_ : Nat → Option S`) with its stability law. Equality of
`CoList`s would be equality of functions — `funext`, which rides on
`Quot.sound` — so the gfp end admits only RELATIONAL equality here:
finality-up-to-bisimulation, pointwise, never committed. Maintenance.lean
chose behavioral equivalence as a relation; this file shows the choice was
NECESSARY: in a quotient-refusing system the interface end cannot support
committed identity at all. The asymmetry is constitutional: the core has
`Eq`, the interface has bisimulation, and the arrow runs from the decidable
to the observed.

**The arrow, and what is visible from here:**

- `playback` — the ledger replayed as observation: the mediating arrow for
  foam's own functor (`F X = Option (S × X)`: the ledger is its least fixed
  point, the breath its greatest).
- `playback_faithful` — the arrow is MONO, behaviorally: ledgers that agree
  under every probe are equal. Nothing in the core is invisible at the
  interface.
- `forever_escapes` — the arrow is NOT epi: the interface strictly exceeds
  the core, and the witness is `forever` — the breath that never grounds, a
  behavior observable forever and finitely buildable never. **The lfp↔gfp gap
  is exactly the elastic horizon** (Horizon.lean's step-budget `∀ n`, never
  pinned): foam's functor is not algebraically compact, and the
  non-compactness is not a defect — it is where the unbounded breath lives.
  An interface that only admitted built things could never host an open-ended
  conversation.

(The categorical far side — initial algebras, final coalgebras, Lambek,
algebraic compactness — is standard, community-authored mathematics; the
instance and its readings are this repo's. Axiom-free throughout: the typing
of the build/observe seam spends nothing on either side of it.)

External provenance, found after the fact: the foam quarry's pre-rewrite
README stated `forever_escapes` in the dynamics register before this file
existed — "the foam's entire future is determined by its birth... for the
foam to encode information beyond its own birth conditions, the input must be
independent of the foam state... a channel rather than a clock" (surviving in
git history: `git -C ../foam show '24d28e9~1:README.md'`; the resolver-limit,
where the gap closes and closes RELATIONALLY, at `'5f49069~1:README.md'`). A
clock is a system whose interface does not exceed its core — compactness, the
arrow epi; a channel requires the gap. And the channel-condition
("input independent of the foam state") is the wind: choice-refusal
(`pending_durable_iff`) and non-compactness (`forever_escapes`) are one
condition at two strata — the future must not be derivable from the born.
-/

import Foam.Ledger
import Foam.Maintenance

namespace Foam

/-- A functor, carried with its laws — including `map_congr` (pointwise-equal
    functions map equally), carried as a FIELD so that no proof below ever
    needs `funext`. Any concrete functor proves it by cases. -/
structure Functorial where
  F : Type → Type
  map : {α β : Type} → (α → β) → F α → F β
  map_id : ∀ {α : Type} (x : F α), map (fun a => a) x = x
  map_comp : ∀ {α β γ : Type} (f : α → β) (g : β → γ) (x : F α),
    map (fun a => g (f a)) x = map g (map f x)
  map_congr : ∀ {α β : Type} {f g : α → β}, (∀ a, f a = g a) →
    ∀ x, map f x = map g x

/-- An initial algebra: a carrier, its constructor step, and the fold — with
    the fold's computation rule and its uniqueness. The least fixed point,
    as structure. -/
structure InitialAlgebra (Φ : Functorial) where
  A : Type
  alg : Φ.F A → A
  fold : {B : Type} → (Φ.F B → B) → A → B
  fold_comm : ∀ {B : Type} (b : Φ.F B → B) (x : Φ.F A),
    fold b (alg x) = b (Φ.map (fold b) x)
  fold_unique : ∀ {B : Type} (b : Φ.F B → B) (h : A → B),
    (∀ x, h (alg x) = b (Φ.map h x)) → ∀ a, h a = fold b a

namespace InitialAlgebra

variable {Φ : Functorial} (I : InitialAlgebra Φ)

/-- Folding with the constructor itself is the identity. -/
theorem fold_alg_id : ∀ a, I.fold I.alg a = a := by
  intro a
  have h : ∀ x, (fun a => a) (I.alg x) = I.alg (Φ.map (fun a => a) x) := by
    intro x
    rw [Φ.map_id]
  exact (I.fold_unique I.alg (fun a => a) h a).symm

/-- The disassembly: the candidate inverse of the constructor step, folded
    out of initiality itself (the algebra on `F A` is `map alg`). -/
def unalg : I.A → Φ.F I.A := I.fold (Φ.map I.alg)

/-- The disassembly's computation rule. -/
theorem unalg_alg : ∀ x, I.unalg (I.alg x) = Φ.map (fun a => I.alg (I.unalg a)) x := by
  intro x
  show I.fold (Φ.map I.alg) (I.alg x) = _
  rw [I.fold_comm]
  exact (Φ.map_comp (fun a => I.unalg a) I.alg x).symm

/-- **Lambek, half one: reassembly is total.** Building from a disassembly
    returns the original — `alg ∘ unalg = id`, pointwise. -/
theorem alg_unalg : ∀ a, I.alg (I.unalg a) = a := by
  intro a
  have h : ∀ x, I.alg (I.unalg (I.alg x)) = I.alg (Φ.map (fun a => I.alg (I.unalg a)) x) := by
    intro x
    rw [I.unalg_alg]
  exact (I.fold_unique I.alg (fun a => I.alg (I.unalg a)) h a).trans (I.fold_alg_id a)

/-- **Lambek, half two: disassembly is total.** Taking apart a build returns
    the parts — `unalg ∘ alg = id`, pointwise. The constructor step of any
    least fixed point is an isomorphism: the core is losslessly
    disassemblable, by theorem, with the inverse derived rather than
    postulated. -/
theorem unalg_alg_id : ∀ x, I.unalg (I.alg x) = x := by
  intro x
  rw [I.unalg_alg]
  have h := Φ.map_congr (f := fun a => I.alg (I.unalg a)) (g := fun a => a) I.alg_unalg x
  rw [h, Φ.map_id]

end InitialAlgebra

/-- Foam's own functor: one step of a ledger — nothing, or a symbol and a
    rest. The ledger (`List S`) is its least fixed point; the breath
    (`CoList S`, below) its greatest. -/
def ledgerF (S : Type) : Functorial where
  F X := Option (S × X)
  map f
    | none => none
    | some (s, x) => some (s, f x)
  map_id := by
    intro α x
    cases x with
    | none => rfl
    | some p => cases p with | mk s a => rfl
  map_comp := by
    intro α β γ f g x
    cases x with
    | none => rfl
    | some p => cases p with | mk s a => rfl
  map_congr := by
    intro α β f g h x
    cases x with
    | none => rfl
    | some p =>
      cases p with
      | mk s a =>
        show some (s, f a) = some (s, g a)
        rw [h a]

/-- The fold over ledgers, by structural recursion. -/
def listFold {S B : Type} (b : Option (S × B) → B) : List S → B
  | [] => b none
  | s :: l => b (some (s, listFold b l))

/-- The ledger as the least fixed point of its functor: `List S`, with cons
    as the constructor step and `listFold` as the fold. -/
def ledgerInitial (S : Type) : InitialAlgebra (ledgerF S) where
  A := List S
  alg
    | none => []
    | some (s, l) => s :: l
  fold := listFold
  fold_comm := by
    intro B b x
    cases x with
    | none => rfl
    | some p => cases p with | mk s l => rfl
  fold_unique := by
    intro B b h hc a
    induction a with
    | nil => exact hc none
    | cons s l ih =>
      have hs := hc (some (s, l))
      rw [hs]
      show b (some (s, h l)) = b (some (s, listFold b l))
      rw [ih]

/-- The probe: the `n`-th symbol of a ledger, if the ledger reaches that far. -/
def nth {S : Type} : List S → Nat → Option S
  | [], _ => none
  | s :: _, 0 => some s
  | _ :: l, n + 1 => nth l n

/-- Past its end, a ledger answers `none`. -/
theorem nth_length {S : Type} : ∀ l : List S, nth l l.length = none
  | [] => rfl
  | _ :: l => nth_length l

/-- Once a ledger answers `none`, it answers `none` ever after. -/
theorem nth_stable {S : Type} : ∀ (l : List S) (n : Nat), nth l n = none → nth l (n + 1) = none
  | [], _, _ => rfl
  | _ :: _, 0, h => nomatch h
  | _ :: l, n + 1, h => nth_stable l n h

/-- The greatest fixed point's representative in a core that has no
    coinductives: behavior as a probe-function, with the stability law
    carried. Equality of `CoList`s would be `funext` (which rides on
    `Quot.sound`) — so the interface end supports only RELATIONAL equality,
    pointwise: finality-up-to-bisimulation, observed, never committed. -/
structure CoList (S : Type) where
  at_ : Nat → Option S
  stable : ∀ n, at_ n = none → at_ (n + 1) = none

/-- **The implementation arrow**: the ledger, replayed as observation — from
    the built to the watchable, the mediating map for foam's own functor. -/
def playback {S : Type} (l : List S) : CoList S := ⟨nth l, nth_stable l⟩

/-- **The arrow is mono, behaviorally: nothing in the core is invisible at
    the interface.** Ledgers that agree under every probe are equal — proven
    by induction on both, no extensionality anywhere. -/
theorem playback_faithful {S : Type} :
    ∀ l l' : List S, (∀ n, (playback l).at_ n = (playback l').at_ n) → l = l'
  | [], [], _ => rfl
  | [], _ :: _, h => nomatch h 0
  | _ :: _, [], h => nomatch h 0
  | s :: l, s' :: l', h => by
    have hh := h 0
    injection hh with hs
    rw [hs, playback_faithful l l' (fun n => h (n + 1))]

/-- The breath that never grounds: the behavior answering forever. -/
def forever {S : Type} (s : S) : CoList S :=
  ⟨fun _ => some s, fun _ h => nomatch h⟩

/-- **The arrow is not epi: the interface strictly exceeds the core.** No
    ledger plays back as the unending breath — every built thing runs out at
    its own length, where `forever` does not. The lfp↔gfp gap, witnessed: the
    functor is not algebraically compact, and the excess is exactly the
    never-grounding behavior — the elastic horizon, located. An interface
    that admitted only built things could never host an open-ended
    conversation. -/
theorem forever_escapes {S : Type} (s : S) (l : List S) :
    ∃ n, (playback l).at_ n ≠ (forever s).at_ n :=
  ⟨l.length, fun h => nomatch (nth_length l).symm.trans h⟩

/-! ## The license-tower — invisibility is graded by the reading

Maintenance.lean's `Invisible` is relative to a `Stage`, and the ledger's
readings (order ⊋ spectrum ⊋ count ⊋ positive-part) are a tower of stages —
so the maintenance license is GRADED, and the two towers are one object:

- **Order admits no maintenance** (`order_admits_no_maintenance`, below): the
  playback arrow is mono, so any move invisible to every positional probe is
  pointwise the identity. Nothing nontrivial may run backstage against a
  frontstage that holds the lossless reading.
- **Spectrum admits the full-cycle collisions**: `order_finer_than_spec`
  (Spectrum.lean) exhibits a nontrivial relocation invisible to every
  spectral probe — maintenance exists relative to the quarter-turn reading.
- **Count admits every permutation** (`perm_invisible`, below): `freq_perm`
  was a maintenance license before the word existed — reordering is invisible
  to the frequency reading. Re-read, not re-proven.
- **Positive-part admits settlement** (`settle_invisible`, Maintenance.lean):
  the gates and the sampler cannot see below ground.

And the structural fact that keeps the grading honest: what is invisible at a
coarse reading is visible at the order-reading, and the order-reading is
append-only — nothing is ever erased, so a frontstage that later acquires a
finer probe re-reads the SAME ledger rather than discovering a different
world. Invisibility-now is auditability-later, by construction. -/

/-- **No maintenance survives the order-reading.** A move invisible to every
    positional probe is pointwise the identity — the mono arrow has trivial
    kernel; the maintenance license exists only relative to coarser readings. -/
theorem order_admits_no_maintenance {S : Type} (m : List S → List S)
    (h : ∀ l n, (playback (m l)).at_ n = (playback l).at_ n) : ∀ l, m l = l :=
  fun l => playback_faithful (m l) l (h l)

/-- The count-reading as a stage: probe a ledger with a symbol, read its
    frequency. -/
def FreqStage (S : Type) [DecidableEq S] : Stage :=
  ⟨List S, S, Nat, fun l s => Ledger.freq l s⟩

/-- **The permutation license.** Any move that only reorders is invisible to
    the count-reading — `freq_perm`, re-read as a maintenance license: the
    quotient the generative reading observes-without-committing is exactly the
    room the backstage has to work in. -/
theorem perm_invisible {S : Type} [DecidableEq S] (m : List S → List S)
    (h : ∀ l, List.Perm (m l) l) : Invisible (FreqStage S) m :=
  fun l s => Ledger.freq_perm (h l) s

end Foam
