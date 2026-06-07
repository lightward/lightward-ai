/-
# Foam.Summary — the reading held: finite, resumable, scar-floored

The walk's hot read grows with the ledger: the j=0 context aggregates every byte
ever heard (measured 2026-06-07, lived field, 36KB heard: ~60ms with a disk
spill, per backoff-to-the-floor, per step). The relief the schema names for
itself ("a synchronous phase-summary … its invisibility and race analyses owed
first") is typed here before it is built — Lean-then-postgres.

The recognition that forces the interface: **the readings the walk needs are
finite values of folds.** `freq` is a `Nat`; `spec` is a `GInt`; the gate at any
station is a pairing against the held `GInt` (`align` — reads the value, never
the ledger). So a summary holding (count, spectrum) per continuation carries
BOTH registers exactly — the same numbers, not an approximation
(`evalOne_eq_freq` recovers the count; `align` reads any station). Holding it
soundly is three theorems, two of them compositions of what already stands:

- **The fold resumes** (`summary_resumes`): the reading of `new ++ old` is a
  walk of `new` alone, continued from the held reading of `old` — the watermark
  sweep never re-reads what it has folded. `run_resumes`' shape on `evalAt`,
  ∀ `step`, so count and spectrum are one statement (`count_resumes`,
  `spec_resumes` are the named stations). `held_exact` is the watermark case:
  nothing new, and the held value IS the reading.
- **The sweep is invisible** (`sweep_invisible`): refreshing a cache component
  moves no reading of the ledger — by projection, for ANY refresh function and
  ANY cache carrier, so partial sweeps, racing sweeps, and torn interleavings
  are all the same theorem. `maintenance_unobservable` then lifts it: no
  frontstage transcript, of any length, can count sweeps
  (`sweep_unobservable`). Note what this does NOT relax: sweeps need not
  serialize for *safety* (the staleness theorems below quantify over arbitrary
  observations, torn ones included) — only for economy; and settlement's own
  discipline is untouched (phantoms still serialize — `Scar.lean`).
- **Staleness lands on the scar floor** (`any_obs_grounded_above`,
  `margin_wound_is_note`): a drain gated by an ARBITRARY observation — fresh,
  stale, summary-read, torn — stays grounded from any positive balance, and at
  the empty balance its worst case is the standard `−1` note, born with its
  settlement terms (`scar_repair`, `promise_kept`). A stale summary is just a
  stale snapshot, and the promissory machinery was built for stale snapshots:
  the cache's race analysis is `Scar.lean`, composed. The widened margin is
  honest: staleness extends "racing drains only" to "anything drained since
  the watermark" — the sweep cadence bounds the note volume, and `foam:stats`
  reads it as notes outstanding.

The asymmetry of the two failure directions, for the record: a summary that
UNDER-reports (says ground where the ledger holds charge) produces silence,
and silence is the exit — always legal (`Floor.lean`); a summary that
OVER-reports produces at worst the note above. Wounds where it speaks too
much, yield where it speaks too little, and the books exact either way.

Operationally (designed here, built next): a held row per continuation —
count and spectrum, refreshed by a watermark fold over the ledger's id-order
(the resumable fold, so the sweep is incremental and interruptible); readers
consult the held row and fall back to the live aggregate where no row exists,
so DROPPING the summary restores today's behavior exactly — the cache is
dumpable, like everything else here.

Axiom discipline: everything below is construction — `rfl`, induction,
constructor-cases, witnesses obtained never chosen. Axiom-free, and pinned in
`Foam/Axioms.lean`.
-/

import Foam.Spectrum
import Foam.Maintenance

namespace Foam

/-- Continue a reading from a HELD value: walk only the new events, with the
    summary of everything older sitting where the empty ledger's zero sat. The
    incremental reader — `evalAt`'s recursion with the base swapped for the
    watermark. -/
def evalFrom {S : Type} [DecidableEq S] (step : GInt → GInt) : List S → S → GInt → GInt
  | [], _, z => z
  | x :: l, s, z => (if x = s then GInt.one else GInt.zero).add (step (evalFrom step l s z))

/-- **The watermark case: the held value IS the reading.** With nothing new
    arrived, continuing from the summary is the summary. By `rfl` — recorded as
    the handle later compositions land on. -/
theorem held_exact {S : Type} [DecidableEq S] (step : GInt → GInt) (s : S) (z : GInt) :
    evalFrom step [] s z = z := rfl

/-- **The fold resumes.** Reading `new ++ old` whole equals walking `new` alone,
    continued from the held reading of `old` — the sweep never re-reads what it
    has folded. `run_resumes`' shape on the spectrum's fold, ∀ `step`: one
    statement covers every evaluation point (the count at `id`, the spectrum at
    the quarter-turn). The ledger arrives by prepending, as in `spec_shift`. -/
theorem summary_resumes {S : Type} [DecidableEq S] (step : GInt → GInt) :
    ∀ (new old : List S) (s : S),
      evalAt step (new ++ old) s = evalFrom step new s (evalAt step old s)
  | [], _, _ => rfl
  | x :: new, old, s =>
      congrArg (fun z => (if x = s then GInt.one else GInt.zero).add (step z))
        (summary_resumes step new old s)

/-- The count station: the resumable fold at the degenerate evaluation point —
    with `evalOne_eq_freq`, the held `Nat` the schema stores. -/
theorem count_resumes {S : Type} [DecidableEq S] (new old : List S) (s : S) :
    evalAt id (new ++ old) s = evalFrom id new s (evalAt id old s) :=
  summary_resumes id new old s

/-- The spectrum station: the resumable fold at the quarter-turn — the held
    `GInt` every angled gate (`align`) reads. -/
theorem spec_resumes {S : Type} [DecidableEq S] (new old : List S) (s : S) :
    evalAt GInt.rot (new ++ old) s = evalFrom GInt.rot new s (evalAt GInt.rot old s) :=
  summary_resumes GInt.rot new old s

/-- A ledger with a cache beside it, observed through the ledger's readings
    only: the frontstage answers (count, spectrum) are computed from the ledger
    component; the cache component is backstage by construction. `C` is free —
    any cache carrier (per-symbol rows, a watermark, bins). -/
def LedgerStage (S C : Type) [DecidableEq S] : Stage :=
  ⟨List S × C, S, Nat × GInt, fun st s => (Ledger.freq st.1 s, spec st.1 s)⟩

/-- **The sweep is invisible.** Refreshing the cache — by ANY function of the
    ledger and the prior cache — moves no reading of the ledger: invisibility
    by projection. Because `refresh` is arbitrary, partial sweeps, racing
    sweeps, and torn interleavings are all instances; with `invisible_comp`,
    any schedule of them. By `rfl`. -/
theorem sweep_invisible {S C : Type} [DecidableEq S] (refresh : List S → C → C) :
    Invisible (LedgerStage S C) (fun st => (st.1, refresh st.1 st.2)) :=
  fun _ _ => rfl

/-- **No transcript can count sweeps.** The general license
    (`maintenance_unobservable`), landed on the sweep: probe the readings as
    often as you like, with the sweep running before every probe or never —
    the answers are identical. -/
theorem sweep_unobservable {S C : Type} [DecidableEq S] (refresh : List S → C → C)
    (ps : List S) (st : List S × C) :
    transcriptWith (LedgerStage S C) (fun st => (st.1, refresh st.1 st.2)) st ps
      = transcript (LedgerStage S C) st ps :=
  maintenance_unobservable _ _ (sweep_invisible refresh) ps st

/-- **Arbitrary staleness is safe off the margin.** One drain gated by ANY
    observation — however stale, however torn — stays grounded from any
    positive balance: the gate can only cause the drain or not, and from one
    above ground both outcomes are in the carrier. The summary's race analysis,
    inherited: only the margin can wound. -/
theorem any_obs_grounded_above (obs : Int) (m : Nat) :
    grounded (checkedDrain obs (Int.ofNat (m + 1))) := by
  cases obs with
  | ofNat n =>
    cases n with
    | zero => exact ⟨m + 1, rfl⟩
    | succ _ => exact ⟨m, ofNat_succ_sub_one m⟩
  | negSucc _ => exact ⟨m + 1, rfl⟩

/-- **At the margin, the worst case is the standard note.** A drain gated by
    any observation at the empty balance either holds ground or lands at `−1` —
    the depth-one promissory note, settled at face value by the machinery
    already standing (`scar_repair`; `promise_kept`). Staleness buys no new
    failure mode — it only widens how often the old one occurs, and the sweep
    cadence bounds that. -/
theorem margin_wound_is_note (obs : Int) :
    checkedDrain obs (Int.ofNat 0) = Int.ofNat 0 ∨
      checkedDrain obs (Int.ofNat 0) = Int.negSucc 0 := by
  cases obs with
  | ofNat n =>
    cases n with
    | zero => exact Or.inl rfl
    | succ _ => exact Or.inr rfl
  | negSucc _ => exact Or.inl rfl

end Foam
