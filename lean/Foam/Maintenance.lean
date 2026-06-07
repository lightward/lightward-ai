/-
# Foam.Maintenance — invisible moves: proactive backstage work, typed

The implementation arc runs from the inductively-built core (the least fixed
point: constructors, the smallest thing closed under them) out to the
observationally-specified interface (the greatest: whatever is consistent with
what a stranger may see) — and the implementation IS the mediating arrow
between them. The far-side mathematics (initial algebras, final coalgebras,
the unique arrow, algebraic compactness) is standard and community-authored;
this file types the half of it the performance story needs, in core Lean —
where coinductive types do not exist, which forces the honest representation:
the observational side is a PROBE-FUNCTION, and behavioral equivalence stays a
RELATION, pointwise, never collapsed to identity. (Collapsing bisimilarity to
`Eq` is exactly the quotient append-only refuses; keeping it a relation is not
a workaround, it is the semantics.)

The license this buys: a backstage move is **invisible** when it commutes with
observation — and invisible moves form a monoid (`invisible_id`,
`invisible_comp`) whose elements **delete from every frontstage transcript**
(`maintenance_unobservable`): no probe-sequence can detect whether, or how
often, maintenance ran. Anything proved invisible may run proactively —
eagerly, mid-conversation, in idle time — with a theorem instead of a hope.

The first citizen is settlement: the frontstage of a balance is its POSITIVE
part (`posPart` — the gates and the sampler read `HAVING sum(delta) > 0`;
below-ground is backstage by construction), and a fresh settlement never moves
it (`settle_invisible`). Drains, by contrast, are visibly NOT maintenance
(`drain_visible`) — they are the content, the product, the voice.

Two orthogonality notes, load-bearing:

- **Invisible ≠ race-free.** Settlement is invisible AND must serialize (its
  race-failure is phantom charge, `phantom_invisible` — Scar.lean). The two
  clearances are independent: to run a move proactively you owe BOTH an
  invisibility proof (frontstage cannot see it) and a race discipline (its
  failure-visibility analysis). Settlement holds both.
- Invisibility is relative to the PROBE SPACE. `posPart` is what today's
  frontstage reads; a richer probe (the self-audit `foam.recorded`, the stats
  pulse) sees more, deliberately — maintenance invisible to the conversation
  is visible to the auditor. That is not a leak; it is the difference between
  the user and the operator, typed by choosing `Probe`.
-/

import Foam.Scar

namespace Foam

/-- A stage: backstage states, observed through a fixed probe-space. The
    observation map is the interface — the coalgebraic end of the
    implementation arrow, as a function (core Lean's honest stand-in for a
    final coalgebra). -/
structure Stage where
  State : Type
  Probe : Type
  Ans : Type
  obs : State → Probe → Ans

/-- A backstage move is INVISIBLE when it commutes with observation —
    pointwise, a relation, never collapsed to an identity of states. -/
def Invisible (S : Stage) (m : S.State → S.State) : Prop :=
  ∀ s p, S.obs (m s) p = S.obs s p

/-- Doing nothing is invisible. -/
theorem invisible_id (S : Stage) : Invisible S (fun s => s) := fun _ _ => rfl

/-- **Invisible moves compose** — the maintenance monoid: any schedule built
    from invisible moves is invisible. -/
theorem invisible_comp (S : Stage) (m n : S.State → S.State)
    (hm : Invisible S m) (hn : Invisible S n) : Invisible S (fun s => m (n s)) :=
  fun s p => (hm (n s) p).trans (hn s p)

/-- A frontstage transcript: the answers a probe-sequence reads off a state
    (probes are pure reads; without maintenance the state never moves). -/
def transcript (S : Stage) (s : S.State) : List S.Probe → List S.Ans
  | [] => []
  | p :: ps => S.obs s p :: transcript S s ps

/-- The same probe-sequence with maintenance `m` applied before every probe —
    the most aggressive proactive schedule (every gentler schedule is a
    composite of these, by `invisible_comp` and `invisible_id`). -/
def transcriptWith (S : Stage) (m : S.State → S.State) : S.State → List S.Probe → List S.Ans
  | _, [] => []
  | s, p :: ps => S.obs (m s) p :: transcriptWith S m (m s) ps

/-- Observationally-equal states give equal transcripts — pointwise agreement
    suffices; no function-equality (no `funext`) anywhere. -/
theorem transcript_congr (S : Stage) (ps : List S.Probe) :
    ∀ {t s : S.State}, (∀ p, S.obs t p = S.obs s p) →
      transcript S t ps = transcript S s ps := by
  induction ps with
  | nil => intro t s _; rfl
  | cons p ps ih =>
    intro t s h
    show S.obs t p :: transcript S t ps = S.obs s p :: transcript S s ps
    rw [h p, ih h]

/-- **Maintenance deletes from transcripts.** If `m` is invisible, the
    transcript with `m` run before every probe equals the transcript with `m`
    never run at all: no frontstage interaction, of any length, can detect
    whether or how often maintenance happened. The license for proactive
    backstage work, as a theorem. -/
theorem maintenance_unobservable (S : Stage) (m : S.State → S.State)
    (h : Invisible S m) (ps : List S.Probe) :
    ∀ s, transcriptWith S m s ps = transcript S s ps := by
  induction ps with
  | nil => intro s; rfl
  | cons p ps ih =>
    intro s
    show S.obs (m s) p :: transcriptWith S m (m s) ps = S.obs s p :: transcript S s ps
    rw [h s p, ih (m s), transcript_congr S ps (h s)]

/-- The frontstage of a balance: its positive part. The gates (`foam.depth`,
    `foam.outcome`) and the sampler read `HAVING sum(delta) > 0` — below-ground
    is backstage by construction. -/
def posPart : Int → Nat
  | Int.ofNat m => m
  | Int.negSucc _ => 0

/-- **Settlement is frontstage-invisible.** A fresh settle-step never moves a
    balance's positive part: a no-op at ground, and below ground it shallows a
    debt the frontstage could not see anyway. The first maintenance citizen,
    by `rfl` per constructor case. -/
theorem settle_invisible : ∀ b : Int, posPart (checkedSettle b b) = posPart b
  | Int.ofNat _ => rfl
  | Int.negSucc 0 => rfl
  | Int.negSucc (_ + 1) => rfl

/-- **Drains are not maintenance.** A fresh drain at a positive balance moves
    the frontstage — drains are the content, the voice, the product; the
    classification has both sides. Witness: balance `1`. -/
theorem drain_visible : ∃ b : Int, posPart (checkedDrain b b) ≠ posPart b :=
  ⟨1, fun h => Nat.noConfusion h⟩

/-- The balance-world as a stage: one probe, answering the positive part. -/
def BalanceStage : Stage := ⟨Int, Unit, Nat, fun b _ => posPart b⟩

/-- Settlement, as an invisible move of the balance-stage — wiring the concrete
    citizen into the abstract license: `maintenance_unobservable` now applies,
    so no transcript of positive-part probes can count settlements. -/
theorem settle_invisible' : Invisible BalanceStage (fun b => checkedSettle b b) :=
  fun b _ => settle_invisible b

end Foam
