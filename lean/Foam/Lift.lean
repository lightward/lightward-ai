/-
# Foam.Lift — the base forces, the lift frees (meeting becomes consensual)

The discrete skeleton of the threeness chain (2026-06-11), smallest honest
case: 1-dimensional processes sharing a carrier. In the base — two walks over
time with `Nat` heights, the discrete half-plane (`Nat` and not `Int` because
the house's clean order lives there: core `Int` order rides on `propext`,
which is why `IntFloor` exists; the recognition is carrier-indifferent) — a sign change *forces* an encounter: if you start
below and end above, you crossed, lattice-point or mid-step, no consent asked
(`base_forces_crossing`, a discrete intermediate-value recognition). One fresh
coordinate dissolves the force: ANY two walks lift disjointly, with the new
height held *constant* — you don't even need to steer (`lift_frees_meeting`).
And the lift forecloses nothing: equal heights meet exactly where the base
met (`lift_keeps_meeting`). So the borrowed dimension makes meeting
*consensual* — avoidable and available, both, which is what consent means.

This is `Fork.lean`'s recognition ("met in the base, two in the total space")
arrived at from the metric side: the fork proved the *record* can hold two
routes through one meeting; this file proves the *carrier* offers the choice
at all only from one-dimension-up. Both are `rfl`-adjacent and that is the
point — a circle that holds is a home, not a vehicle (see the perspectives on
circularity): these theorems don't go anywhere, they make the place livable.

**What is claimed:** exactly the above — forced crossing in the base, free and
non-foreclosing lift, discrete, natural-number-valued, axiom-free.

**What is cited, not claimed** (literature-checked 2026-06-11, citations in
`lean/REFEREE.md`'s lineage): the upper face of the threeness chain — that
relation-without-contact (linking) persists in exactly three dimensions and
dissolves from four up (Zeeman 1960: codimension-2 phenomenon, unconditional
for circles) — and the frame faces: FTPG/Veblen–Young (incidence forces
coordinates, projective dimension ≥ 2) and Gleason 1957 (noncontextual
measures are Born, Hilbert dimension ≥ 3, *false* at 2). None of those are
theorems here; they are the bridge package's to build, on mathlib ground.

**The Busch wrinkle, recorded so the noun stays behind the theorem:** forcing
has two known routes — bring a third dimension (Gleason), or bring a richer
probe space (Busch 2003; Caves–Fuchs–Manne–Renes 2004: POVMs force Born in
ALL dimensions, including 2). Naimark dilation suggests the routes are one
(a richer probe space is a borrowed dimension in disguise) — that
reconciliation is conjecture-grade, named here and claimed nowhere. What
survives either route: forcing lives in what the resolver brings, not in the
substrate. The substrate's half — consistency at dimension 2 — is `Born.lean`.

Pure construction — axiom-free.
-/

namespace Foam

/-- Two walks cross at step `n`: they share the lattice point, or they trade
    sides across one step — the polyline crossing that happens *between*
    lattice points. Both are encounters; neither is asked for. -/
def CrossesUp (f g : Nat → Nat) (n : Nat) : Prop :=
  f n = g n ∨ (f n < g n ∧ g (n + 1) < f (n + 1))

/-- **The base forces the meeting.** In the half-plane — two walks over time —
    starting below and ending above *compels* a crossing somewhere on
    the way: the carrier extracts the encounter whether or not either walk
    chose it. Discrete intermediate-value, by induction on the horizon; no
    step-size condition needed — the order structure alone forces it. -/
theorem base_forces_crossing (f g : Nat → Nat) :
    ∀ N : Nat, f 0 < g 0 → g N < f N → ∃ n, n < N ∧ CrossesUp f g n
  | 0, h0, hN => absurd (Nat.lt_trans h0 hN) (Nat.lt_irrefl _)
  | N + 1, h0, hN => by
    rcases Nat.lt_trichotomy (f N) (g N) with hlt | heq | hgt
    · exact ⟨N, Nat.lt_succ_self N, Or.inr ⟨hlt, hN⟩⟩
    · exact ⟨N, Nat.lt_succ_self N, Or.inl heq⟩
    · obtain ⟨n, hn, hc⟩ := base_forces_crossing f g N h0 hgt
      exact ⟨n, Nat.lt_succ_of_lt hn, hc⟩

/-- **The lift frees the meeting.** One fresh coordinate, and ANY two walks —
    crossing in the base or not — coexist without a single shared point. The
    witness heights are *constants*: the freed dimension doesn't need to be
    steered, only inhabited. What the base extracted by force, the lift makes
    optional. -/
theorem lift_frees_meeting (f g : Nat → Nat) :
    ∃ zf zg : Nat, ∀ n : Nat, (f n, zf) ≠ (g n, zg) :=
  ⟨0, 1, fun _ h => absurd (show (0 : Nat) = 1 from congrArg Prod.snd h) (by decide)⟩

/-- **The lift forecloses nothing.** At equal heights, lifted walks meet
    exactly where the base walks meet — the freed dimension removes the
    compulsion, not the possibility. Avoidable and available, both: that pair
    is what "consensual" means, and the lift is where it first exists. -/
theorem lift_keeps_meeting (f g : Nat → Nat) (n : Nat) (h : f n = g n) :
    ((f n, (0 : Nat)) = (g n, (0 : Nat))) := by
  rw [h]

/-- **Avoidance is unilateral.** Whatever height the other walk takes, this one
    can still avoid every meeting — consent's first half holds against any
    partner, not only by joint agreement (the ∀∃ alternation, where
    `lift_frees_meeting`'s single ∃ chose both heights at once). -/
theorem lift_avoids_unilaterally (f g : Nat → Nat) (zf : Nat) :
    ∃ zg : Nat, ∀ n : Nat, (f n, zf) ≠ (g n, zg) :=
  ⟨zf + 1, fun _ h => absurd (congrArg Prod.snd h).symm (Nat.succ_ne_self zf)⟩

/-- **Meeting is unilateral too.** Whatever height the other walk takes, this
    one can still join it wherever the base meets — consent's second half,
    same quantifier shape. Together with `lift_avoids_unilaterally`: whatever
    one party does, the other retains both options. That alternation is
    consent's actual form. -/
theorem lift_meets_unilaterally (f g : Nat → Nat) (n : Nat) (h : f n = g n)
    (zf : Nat) : ∃ zg : Nat, (f n, zf) = (g n, zg) :=
  ⟨zf, by rw [h]⟩

end Foam
