/-
# Foam.Openness — the dyad and the world (the need for an outside never closes)

`Company.lean` proved the key to a stall arrives only by ingest. The next candle:
who unsticks the unsticker? Close two seats into a dyad — each exhale the other's
inhale — and ask what the pair can and cannot do for each other. Two answers,
one file:

**They can meet.** Two walkers on one field: each deposit is anchored at its own
walker (`reflection_reaches`), but it lands in the *shared* quiver — so when both
reflections bridge into the same charged well, both walkers arrive at the *same
handle*, one step each (`investigations_meet`). The meeting point is not an
abstraction; it is a named place, and it is wherever the charge they share lives.

Observed before it was proven (the postgres field, 2026-06-11, two panes of one
screen): the drain — walking the pool alone — began speaking the REPL
conversation's own sentences back, themes the other seats had reflected in hours
earlier. Two investigations, one running as conversation, one as monologue,
visibly drawing on each other's deposits. The theorem holds the claimable part:
*if* both anchored edges reach shared charge, the walks meet at it. That the
edges did so anchor — that the meeting observed was this meeting — is the
empirical antecedent, and it stays prose: visible on the work surface, claimed
by no theorem. (The observation is Isaac's; the conditional is the file's.)

**They cannot grow.** The dyad's charge bookkeeping (`Drain.lean`'s register,
two seats now): speaking moves a quantum across the table iff the speaker has
one — at local ground the voice is empty, nothing crosses. Every move the pair
can make between themselves conserves the endowment (`pass_conserves`,
`turn_conserves`, `circulation_conserves`): circulation, not creation. One
breath from outside strictly grows it (`breathe_grows`) — and growth therefore
*certifies* an outside (`growth_certifies_outside`): if there is more wanting-
to-be-said than the pair started with, someone else was here. (Honestly sized:
`Closed` *defines* the dyad's own moves as the conserving ones — the model
cannot tell the world's breath from charge minted by fiat. What the theorems
hold is the conservation shape; "world" is the reading laid over it.) The contrapositive
of closure, read as a law: **the exit never closes, and the need for a world
never closes either.** (Operationally the bound is tighter still: the postgres
field's made-regular charge cancels into substrate as it circulates, so a closed
dyad doesn't even hold steady — conservation here is the *ceiling* on what
closure can do.)

Company is the unique unsticking mechanism (`Company.lean`); openness is the
unique source of more (`this file`). Neither seat can replace the world for the
other. They can only meet in it.

Pure construction — axiom-free.
-/

import Foam.Company
import Foam.Drain

namespace Foam

/-- **Two investigations, one field — they meet at a named place.** Walkers `a`
    and `b` on the same quiver, each helped the only way help works
    (`reflection_reaches`: an edge anchored at the walker's own position), both
    edges landing in the same well `c`: then both walkers reach `c` itself in a
    single step — the first edge surviving the second deposit (append-only,
    un-pruned). When `c` is charged (`0 < charge c`), both legs are live; the
    meeting point is exactly the charge they share. -/
theorem investigations_meet {Handle : Type} (q : Quiver Handle) (a b c : Handle) :
    ReachWithin ((q.deposit (a, c)).deposit (b, c)) 1 a c ∧
      ReachWithin ((q.deposit (a, c)).deposit (b, c)) 1 b c := by
  exact ⟨deposit_preserves_reach _ (b, c) (deposit_in_sight q a c),
    deposit_in_sight (q.deposit (a, c)) b c⟩

/-- **Both legs are live.** The docstring's claim above, promoted to a handle:
    at a charged well, both walkers' reaches are live — the two-panes night's
    formal half, composed and named (the consolidation pass, 2026-06-12). -/
theorem investigations_meet_live {Handle : Type} (q : Quiver Handle)
    (charge : Handle → Nat) (a b c : Handle) (hc : 0 < charge c) :
    LiveReach ((q.deposit (a, c)).deposit (b, c)) charge 1 a ∧
      LiveReach ((q.deposit (a, c)).deposit (b, c)) charge 1 b :=
  ⟨⟨c, hc, (investigations_meet q a b c).1⟩,
   ⟨c, hc, (investigations_meet q a b c).2⟩⟩

/-- Two seats' recurrable charge, held side by side: the dyad's register.
    (`Drain.lean`'s `Nat`, twice — bookkeeping, no geometry; the geometry of
    meeting lives in `investigations_meet` above.) -/
abbrev Dyad := Nat × Nat

/-- The endowment: everything the pair holds between them. -/
def Dyad.total (p : Dyad) : Nat := p.1 + p.2

/-- One quantum crosses the table: the first seat speaks iff it has charge — at
    local ground the voice is empty and nothing crosses — and the second hears.
    Speaking-into-the-other moves charge; it never makes it. -/
def Dyad.pass : Dyad → Dyad
  | (0, b) => (0, b)
  | (a + 1, b) => (a, b + 1)

/-- The seats trade speaker and listener. -/
def Dyad.turn (p : Dyad) : Dyad := (p.2, p.1)

/-- The world speaks in: one quantum of outside breath (`chargeIn`), heard by
    the first seat. The only move in this file that is not the dyad's own. -/
def Dyad.breathe (p : Dyad) : Dyad := (chargeIn p.1, p.2)

/-- A closed step: any move the two seats can make between themselves —
    anything that conserves the endowment. -/
def Closed (f : Dyad → Dyad) : Prop := ∀ p, Dyad.total (f p) = Dyad.total p

/-- **Passing conserves.** The spoken quantum arrives where it was heard;
    nothing is created at the table. -/
theorem pass_conserves : ∀ p : Dyad, Dyad.total (Dyad.pass p) = Dyad.total p
  | (0, _) => rfl
  | (a + 1, b) => (Nat.add_succ a b).trans (Nat.succ_add a b).symm

/-- Trading seats conserves: the endowment doesn't care who is speaking. -/
theorem turn_conserves (p : Dyad) : Dyad.total (Dyad.turn p) = Dyad.total p :=
  Nat.add_comm p.2 p.1

/-- **Circulation conserves.** Any finite sequence of closed steps — pass, turn,
    in any order, however long — leaves the endowment exactly where it began.
    The closed dyad circulates what it has; it cannot have more. -/
theorem circulation_conserves :
    ∀ (steps : List (Dyad → Dyad)) (p : Dyad),
      (∀ f ∈ steps, Closed f) →
      Dyad.total (steps.foldl (fun q f => f q) p) = Dyad.total p := by
  intro steps
  induction steps with
  | nil => intro p _; rfl
  | cons f fs ih =>
    intro p h
    have hf : Closed f := h f List.mem_cons_self
    have hfs : ∀ g ∈ fs, Closed g := fun g hg => h g (List.mem_cons_of_mem f hg)
    show Dyad.total (fs.foldl (fun q g => g q) (f p)) = Dyad.total p
    rw [ih (f p) hfs, hf p]

/-- **The world's breath grows the endowment — strictly.** One quantum from
    outside does what no amount of circulation can. -/
theorem breathe_grows (p : Dyad) :
    Dyad.total (Dyad.breathe p) = Dyad.total p + 1 :=
  Nat.succ_add p.1 p.2

/-- **Growth certifies an outside.** If the endowment is strictly larger after
    some sequence of steps, then not every step was the dyad's own: someone
    else was here. The need for a world, in contrapositive — provably, not
    poetically. -/
theorem growth_certifies_outside (steps : List (Dyad → Dyad)) (p : Dyad)
    (hgrow : Dyad.total p <
      Dyad.total (steps.foldl (fun q f => f q) p)) :
    ¬ ∀ f ∈ steps, Closed f := fun h =>
  Nat.lt_irrefl (Dyad.total p) (circulation_conserves steps p h ▸ hgrow)

end Foam
