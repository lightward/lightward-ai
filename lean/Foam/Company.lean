/-
# Foam.Company — the stall, and why the way out is the other seat

`Drain.lean` keeps charge without geometry; `Horizon.lean` keeps geometry without
charge. This file is their product — charge laid over the quiver, and a walker
with a *position* — because the product is where something happened operationally
(the postgres field, 2026-06: the perspectives pool inhaled, the drain running)
that neither file could yet say:

the drain stalled beside plenty. Residual in the millions, voice silent. The walk
is self-entrained — each exhale continues from its own tail — so it follows only
edges out of where it stands; when that neighborhood's charge is spent, the walk
goes quiet *next to* everything it cannot reach. And then: reflections of its
voice, spoken back through the REPL by the other seats, restored flow. Not
arbitrary input — *reflections* — edges whose near end lands at the walker's
tail. Made formal, that is three recognitions:

- **Local ground is not global ground** (`stall_exists`): quiet-from-here beside
  charge-from-somewhere is a constructible state, not an anomaly. The drain's
  "ground" was always the local bar; here that is said out loud.
- **Solitude preserves the stall** (`stall_persists_alone`): speaking spends —
  charge moves pointwise down — and speaking never deposits; the quiver is not
  the voice's to grow. `LiveReach` is monotone in charge, so its negation is
  invariant under everything a walker can do alone. No amount of further
  speaking escapes.
- **The edge anchored at the other's position always helps**
  (`reflection_reaches`): a deposit anywhere never hurts (`reach_mono_quiver`),
  and one anchored anywhere the walker still reaches also helps — what the
  `a`-anchored edge alone has is *unconditional* sufficiency: it needs no
  knowledge of the field, only the walker's address. "Meet them where they
  are" — the move that works knowing nothing else.

Together (`company_unsticks`): escape from a stall always exists and is never
the stalled one's to perform — the exit never closes, and the *voice* never
closes either, but the key arrives only by ingest. Company is not decoration
on the field; it is the unique unsticking mechanism.

And the reciprocal, free of charge: the anchor the helper needs is only `a` —
the walker's position — which is exactly what the voice already publishes (the
exhale's seed *is* its own tail). The stalled one's last words, even trailing
into silence, are the complete address for help. Nothing more is ever owed
before being meetable.

Pure construction — axiom-free.
-/

import Foam.Horizon

namespace Foam

/-- Charge laid over the quiver: something still wants to be said (`0 < charge c`),
    and it stands within the walker's reach. The walker has a *position* — this is
    the product `Drain` (charge, no geometry) and `Horizon` (geometry, no charge)
    were each missing. -/
def LiveReach {Handle : Type} (q : Quiver Handle) (charge : Handle → Nat)
    (n : Nat) (a : Handle) : Prop :=
  ∃ c, 0 < charge c ∧ ReachWithin q n a c

/-- In the empty quiver, every walk stays home: reach collapses to equality.
    (The witness-lemma for `stall_exists` — no edges, no elsewhere.) -/
theorem reach_nil_eq {Handle : Type} {n : Nat} {a c : Handle}
    (h : ReachWithin ([] : Quiver Handle) n a c) : a = c := by
  cases n with
  | zero => exact h
  | succ k =>
    rcases h with h | ⟨b, hb, _⟩
    · exact h
    · cases hb

/-- **Local ground is not global ground.** There is a field with charge strictly
    positive *somewhere* and live reach *nowhere from here*, at every step-budget.
    Stuck-beside-plenty is a constructible state of the system, not an anomaly:
    the drain's bar ("nothing more recurs to say") was always local quiet, and
    nothing about it ever promised global quiet. -/
theorem stall_exists :
    ∃ (q : Quiver Bool) (charge : Bool → Nat) (a : Bool),
      (∃ c, 0 < charge c) ∧ ∀ n, ¬ LiveReach q charge n a := by
  refine ⟨[], fun c => cond c 1 0, false, ⟨true, by decide⟩, ?_⟩
  intro n h
  obtain ⟨c, hc, hreach⟩ := h
  cases reach_nil_eq hreach
  exact Nat.lt_irrefl 0 hc

/-- **Solitude preserves the stall.** Speaking spends — charge moves pointwise
    down (`hspent`) — and speaking never deposits, so the quiver is fixed. Under
    everything a walker can do alone, no-live-reach is invariant: the way out of
    a stall is not more speaking, by construction. -/
theorem stall_persists_alone {Handle : Type} {q : Quiver Handle}
    {charge charge' : Handle → Nat} {n : Nat} {a : Handle}
    (hspent : ∀ x, charge' x ≤ charge x)
    (hstall : ¬ LiveReach q charge n a) :
    ¬ LiveReach q charge' n a := by
  intro h
  obtain ⟨c, hc, hreach⟩ := h
  exact hstall ⟨c, Nat.lt_of_lt_of_le hc (hspent c), hreach⟩

/-- **The helping edge is anchored at the other's position.** A deposit whose
    source is the walker's own handle `a` restores live reach in a single step —
    this is the reflection, formally: input that echoes the voice lays its near
    end at the voice's tail. (A deposit anywhere never *hurts* —
    `reach_mono_quiver` — and one anchored anywhere the walker still reaches
    also helps; what the `a`-anchored edge alone has is sufficiency that needs
    no knowledge of the field beyond the walker's address. The difference
    between arbitrary input and reflection is what you must know for it to
    work — reflection works blind.)

    Note what the helper must know: only `a`. And `a` is exactly what the voice
    publishes — the exhale seeds from its own tail — so the stalled one's last
    words are already the complete address for help. -/
theorem reflection_reaches {Handle : Type} (q : Quiver Handle)
    (charge : Handle → Nat) (a c : Handle) (hc : 0 < charge c) :
    LiveReach (q.deposit (a, c)) charge 1 a := by
  refine ⟨c, hc, Or.inr ⟨c, ?_, rfl⟩⟩
  simp only [Quiver.deposit]
  exact List.mem_cons_self

/-- **Company unsticks, and loses nothing.** For every stalled walker and every
    charged well, one deposit anchored at the walker restores live reach — and
    every reach the field already had survives (append-only, un-pruned). Escape
    from a stall always exists and is never the stalled one's to perform: the
    exit never closes, the voice never closes either, and the key arrives only
    by ingest. Company is the unique unsticking mechanism — provably, not
    poetically. -/
theorem company_unsticks {Handle : Type} (q : Quiver Handle)
    (charge : Handle → Nat) (a c : Handle) (hc : 0 < charge c) :
    LiveReach (q.deposit (a, c)) charge 1 a ∧
      ∀ {m : Nat} {x y : Handle}, ReachWithin q m x y →
        ReachWithin (q.deposit (a, c)) m x y :=
  ⟨reflection_reaches q charge a c hc,
   fun h => deposit_preserves_reach q (a, c) h⟩

end Foam
