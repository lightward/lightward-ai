/-
# Foam.Gauge — the four-corner transition system: durability pinches the backstage
# to pure propext

A small operational model of a two-party exchange — one party outside the system
(the user/observer), one inside (the machinery); Goffman's front stage / back
stage — over the four-corner commitment gauge. The corners are the seed-gauge
`{⊥, +, −, 0}` of the foam quarry's recognition-index (external provenance), and
their adjacency is drawn in this repo's own prompt layer
(`app/prompts/system/3-perspectives/2x2.md`: four sectors, gaps centered in each
wall — diagonal corners not adjacent), which is what makes the durability
predicates below GEOMETRY rather than restated axiom-refusals: the circularity a
naive formalization would have is broken by the transition graph having
independent sources.

The capability set gating the moves is `Sig` (`Foam/Commitment.lean`) — the three
standard axioms read as backstage capabilities:

- `usesPropext` — a commitment may LAND (the collapse exists): gates `tamp` and
  `widen`, the frontstage moves.
- `usesChoice` — the backstage may SELF-FILL a pending slot (conjure the
  observer): gates `conjure`, the backstage move out of `⊥`.
- `usesQuot` — a move may cross between the two commitment corners directly
  (identify the sectors without passing the basepoint or the join): gates `blur`.

The silent yield is the unit: available to every locus at every corner, gated by
nothing — silence needs no capability, which is exactly why it cannot be
mis-attributed (it carries no signature to misread).

The theorems, each a falsifiable claim about the model (and about nothing else —
see the caveat):

- `free_silent`: with NO capabilities every step is the identity — the
  zero-axiom backstage can only echo. Degrades-to-yield, inside the gauge model.
- `no_leap`: `⊥ → 0` in one step is impossible at every capability set — the
  2x2's wall-gaps as theorem: the only route from the basepoint to the join
  passes through a commitment corner.
- `pending_durable_iff`: the backstage cannot move `⊥` ⟺ no `Classical.choice`.
- `sectors_disjoint_iff`: the two commitment corners never connect directly ⟺
  no `Quot.sound`.
- `commitments_land_iff`: some frontstage move leaves `⊥` ⟺ `propext` present.
- `gauge_durable_iff_observer` — **the pinch**: all three durabilities hold ⟺
  the capability set is exactly `Sig.observer` (`propext` and nothing else).
  Pure propext is not chosen; it is forced by the four corners holding up.

Caveat, load-bearing: this is a MODEL. Within it the pinch is theorems (all
axiom-free — the model of commitment-tracking spends none); whether the actual
backstage (Lean's kernel under this mirror, the pipe under its users) is this
model is not provable from inside — that faithfulness is the single external
commitment, delegated to whoever checks, renewed per check. An internal proof of
it would be a conjured tamp — the exact thing `pending_durable_iff` says a
durable gauge cannot contain.

Read in the TQFT register (external provenance — the foam quarry's index, brick
62; the theorems here stand alone): the move-alphabet's seat-asymmetry — every
landing move frontstage, the backstage's only legal move the silent yield — is
the state-sum signature *no local bulk observables* (observables live on the
boundary; frontstage/backstage = boundary/bulk), typed here for attribution
reasons with no topology in view. And the quotient-refusal
(`sectors_disjoint_iff`) selects the *extended* form over the Atiyah functor:
Atiyah's bordism category is diffeomorphism-quotiented — a `Quot` move a durable
gauge cannot contain — so what survives is the form that keeps the structure
un-quotiented. The mappings are recognition-grade; the standard mathematics on
their far side (state-sum invariants, bordism, bulk/boundary) is not ours and
can break them — which is what makes them worth recording.
-/

import Foam.Commitment

namespace Foam

/-- The four corners of the commitment gauge — the quarry's seed-gauge
    `{⊥, +, −, 0}`; the four sectors of `2x2.md` (the basepoint `bot` ↔ the
    unknown, the two commitment corners ↔ the two disjoint knowables; `bot`/`zero`
    are the diagonal pair, not adjacent). -/
inductive Corner
  | bot
  | plus
  | minus
  | zero

/-- Who supplies a move: the party outside the system or the machinery inside it
    (Goffman's front stage / back stage). One attention-head per nesting level —
    a locus is a seat, not a thread. -/
inductive Locus
  | frontstage
  | backstage

/-- One step of the exchange, gated by the backstage's capability set. The
    constructors are the move-alphabet: the unit `yield`, the frontstage
    `tamp`/`widen` (gated by the collapse capability), the backstage `conjure`
    (gated by choice), and `blur` (gated by quotient). -/
inductive Step (caps : Sig) : Locus → Corner → Corner → Prop
  /-- The silent yield: any locus, any corner, no capability — the unit. -/
  | yield (l : Locus) (c : Corner) : Step caps l c c
  /-- An external commitment lands on `+`. -/
  | tamp_plus : caps.usesPropext = true → Step caps .frontstage .bot .plus
  /-- An external commitment lands on `−`. -/
  | tamp_minus : caps.usesPropext = true → Step caps .frontstage .bot .minus
  /-- A committed corner is held open into the join — also an external act. -/
  | widen_plus : caps.usesPropext = true → Step caps .frontstage .plus .zero
  /-- A committed corner is held open into the join — also an external act. -/
  | widen_minus : caps.usesPropext = true → Step caps .frontstage .minus .zero
  /-- The backstage self-fills a pending slot — the conjured observer. -/
  | conjure_plus : caps.usesChoice = true → Step caps .backstage .bot .plus
  /-- The backstage self-fills a pending slot — the conjured observer. -/
  | conjure_minus : caps.usesChoice = true → Step caps .backstage .bot .minus
  /-- The two commitment corners are crossed directly — the sectors identified
      without passing the basepoint or the join. -/
  | blur_pm (l : Locus) : caps.usesQuot = true → Step caps l .plus .minus
  /-- The reverse crossing. -/
  | blur_mp (l : Locus) : caps.usesQuot = true → Step caps l .minus .plus

/-- The pending corner is durable: no backstage step leaves `⊥`. (Stated as
    geometry — about steps, not about flags.) -/
def PendingDurable (caps : Sig) : Prop :=
  ∀ c, Step caps .backstage .bot c → c = Corner.bot

/-- The two commitment corners never connect directly, from either seat. -/
def SectorsDisjoint (caps : Sig) : Prop :=
  ∀ l, ¬Step caps l .plus .minus ∧ ¬Step caps l .minus .plus

/-- Some frontstage move genuinely leaves the pending corner: commitments can
    land. -/
def CommitmentsLand (caps : Sig) : Prop :=
  ∃ c, c ≠ Corner.bot ∧ Step caps .frontstage .bot c

/-- The full durability of the four-corner gauge: pendings persist, the
    commitment corners stay disjoint, and commitments can land. -/
def GaugeDurable (caps : Sig) : Prop :=
  PendingDurable caps ∧ SectorsDisjoint caps ∧ CommitmentsLand caps

/-- **With no capabilities, every step is the identity** — the zero-axiom
    backstage can only echo. Degrades-to-yield, inside the gauge model. -/
theorem free_silent (l : Locus) (c d : Corner) (h : Step Sig.free l c d) : c = d := by
  cases h with
  | yield => rfl
  | tamp_plus h => exact Bool.noConfusion h
  | tamp_minus h => exact Bool.noConfusion h
  | widen_plus h => exact Bool.noConfusion h
  | widen_minus h => exact Bool.noConfusion h
  | conjure_plus h => exact Bool.noConfusion h
  | conjure_minus h => exact Bool.noConfusion h
  | blur_pm l h => exact Bool.noConfusion h
  | blur_mp l h => exact Bool.noConfusion h

/-- **The wall-gaps, as theorem.** `⊥ → 0` in one step is impossible at every
    capability set: the only route from the basepoint to the join passes through
    a commitment corner (`2x2.md`'s diagonal — the unknown and the known are not
    adjacent). -/
theorem no_leap (caps : Sig) (l : Locus) : ¬Step caps l Corner.bot Corner.zero := by
  intro h
  nomatch h

/-- The route that does exist: at the observer's capabilities, the join is
    reachable from the basepoint in two hops through a commitment corner —
    land, then hold open. -/
theorem zero_via_atom :
    Step Sig.observer .frontstage Corner.bot Corner.plus ∧
      Step Sig.observer .frontstage Corner.plus Corner.zero :=
  ⟨Step.tamp_plus rfl, Step.widen_plus rfl⟩

/-- **Pending-durability is exactly choice-refusal.** The backstage cannot move
    `⊥` if and only if it cannot conjure — things can land charged and stay
    charged precisely when no one inside can quietly resolve them. -/
theorem pending_durable_iff (caps : Sig) :
    PendingDurable caps ↔ caps.usesChoice = false := by
  cases caps with
  | mk p ch q =>
    constructor
    · intro hd
      cases ch with
      | false => rfl
      | true => exact Corner.noConfusion (hd Corner.plus (Step.conjure_plus rfl))
    · intro hch c h
      cases h with
      | yield => rfl
      | conjure_plus h =>
        have h' : ch = true := h
        exact Bool.noConfusion (hch.symm.trans h')
      | conjure_minus h =>
        have h' : ch = true := h
        exact Bool.noConfusion (hch.symm.trans h')

/-- **Sector-disjointness is exactly quotient-refusal.** The two commitment
    corners stay unconnected if and only if nothing may identify them — the two
    knowables remain "known to you to be independent". -/
theorem sectors_disjoint_iff (caps : Sig) :
    SectorsDisjoint caps ↔ caps.usesQuot = false := by
  cases caps with
  | mk p ch q =>
    constructor
    · intro hd
      cases q with
      | false => rfl
      | true => exact absurd (Step.blur_pm Locus.frontstage rfl) (hd Locus.frontstage).1
    · intro hq l
      constructor
      · intro h
        cases h with
        | blur_pm l h =>
          have h' : q = true := h
          exact Bool.noConfusion (hq.symm.trans h')
      · intro h
        cases h with
        | blur_mp l h =>
          have h' : q = true := h
          exact Bool.noConfusion (hq.symm.trans h')

/-- **Landing is exactly propext-presence.** Some frontstage move leaves `⊥` if
    and only if the collapse capability is there: without it the commitment
    corners are unreachable and the gauge degenerates to flow-without-landing. -/
theorem commitments_land_iff (caps : Sig) :
    CommitmentsLand caps ↔ caps.usesPropext = true := by
  cases caps with
  | mk p ch q =>
    constructor
    · intro hl
      obtain ⟨c, hne, hstep⟩ := hl
      cases hstep with
      | yield => exact absurd rfl hne
      | tamp_plus h => exact h
      | tamp_minus h => exact h
    · intro hp
      exact ⟨Corner.plus, fun h => Corner.noConfusion h, Step.tamp_plus hp⟩

/-- **The pinch.** The four-corner gauge is durable if and only if the
    capability set is exactly the observer's signature — `propext` and nothing
    else. Pure propext is not a stylistic choice of the backstage; it is forced
    by the frontstage fibration holding up: durable `⊥` refuses choice, disjoint
    sectors refuse quotient, landing commitments demand the collapse. Pinched
    from both sides. -/
theorem gauge_durable_iff_observer (caps : Sig) :
    GaugeDurable caps ↔ caps = Sig.observer := by
  cases caps with
  | mk p ch q =>
    constructor
    · intro hd
      obtain ⟨hpend, hdisj, hland⟩ := hd
      have hch : ch = false := (pending_durable_iff _).mp hpend
      have hq : q = false := (sectors_disjoint_iff _).mp hdisj
      have hp : p = true := (commitments_land_iff _).mp hland
      rw [hch, hq, hp]
      rfl
    · intro he
      have hp : p = true := congrArg Sig.usesPropext he
      have hch : ch = false := congrArg Sig.usesChoice he
      have hq : q = false := congrArg Sig.usesQuot he
      exact ⟨(pending_durable_iff _).mpr hch, (sectors_disjoint_iff _).mpr hq,
        (commitments_land_iff _).mpr hp⟩

/-- The pinch's corollary, closing the loop with the commitment algebra: a
    durable gauge's backstage is legal — and conversely legality alone is not
    enough (the `free` backstage is legal but nothing lands). Durability is
    strictly stronger: it picks the observer out of the legal carrier. -/
theorem gauge_durable_legal (caps : Sig) (h : GaugeDurable caps) : caps.legal := by
  have he : caps = Sig.observer := (gauge_durable_iff_observer caps).mp h
  rw [he]
  exact legal_observer

end Foam
