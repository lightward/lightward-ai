/-
# Foam.Unattended — the automation boundary (what may run without a seat)

Read off two artifacts of one production system (mechanic-api, 2026-06): the
audit engine runs forever unattended; the reindex ritual (issue #2251) ships
with two human names in the assignees field and a row of 🚨s — *always
`concurrently`*, *never two at once*, *"maintain a LIVE understanding of how
your actions are impacting platform runtime."* The difference is not
complexity. It is a certificate:

**A move may run without a seat when it is (i) invisible — no probe sequence
of any length can tell it ran (`Invisible`, the maintenance license) — and
(ii) idempotent — over-firing collapses to one application.** The two clauses
do different jobs: invisibility makes the run *unnoticeable*
(`unattended_runs_clean`); idempotence makes repetition *harmless*
(`firings_collapse`) — retries, overlapping crons, debounce failures, all collapse
to a single application. Together they are what "safe to automate" means,
typed. An operation without the certificate — REINDEX's lock-contingent,
globally-coupled, in-place surgery — keeps its observer at the helm, carried,
never computed: that direction is operational wisdom (the 🚨s, the assignees),
cited as the boundary's other side, not claimed as a theorem.

The lawful instance that crosses the line: foam's cache rebirth (TRUNCATE
`foam.held` + reset watermark + refold — the schema's own "amnesiac return,
exercised in dev"). It is invisible (`sweep_invisible` licenses any refresh)
and idempotent (refolding a refolded cache is the cache), so what requires a
Statuspage incident at Mechanic is a cron job here — purchased by exactly one
design commitment: the derived structure carries nothing the ledger doesn't,
so it is never operated ON, only re-grown.

Pure construction — axiom-free.
-/

import Foam.Maintenance

namespace Foam

/-- n-fold application: maintenance left to run unattended. -/
def firings {S : Type} (m : S → S) : Nat → S → S
  | 0, s => s
  | n + 1, s => firings m n (m s)

/-- **Over-firing collapses.** An idempotent move applied any number of times
    (≥ 1) is one application: the retry, the overlapping cron, the doubled
    wake-up — all land where one firing lands. Repetition is harmless. -/
theorem firings_collapse {S : Type} (m : S → S) (hm : ∀ s, m (m s) = m s) :
    ∀ (n : Nat) (s : S), firings m (n + 1) s = m s
  | 0, _ => rfl
  | n + 1, s => by
    show firings m (n + 1) (m s) = m s
    rw [firings_collapse m hm n (m s), hm s]

/-- Unattended maintenance stays invisible: the iterate of an invisible move
    is invisible — the maintenance monoid (`invisible_comp`), folded. -/
theorem firings_invisible {S : Stage} {m : S.State → S.State}
    (hm : Invisible S m) : ∀ n, Invisible S (firings m n)
  | 0 => fun _ _ => rfl
  | n + 1 => fun s p => by
    show S.obs (firings m n (m s)) p = S.obs s p
    rw [firings_invisible hm n (m s) p, hm s p]

/-- **The certified side of the automation boundary.** A move that is
    invisible may fire unattended, any number of times, and NO transcript —
    any probe sequence, any length — can tell: the record of every
    frontstage interaction is exactly what it would have been had the
    maintenance never run. (With `firings_collapse`, the state side: the firings
    also collapse to one.) This is what the audit engine has, what cache
    rebirth has, and what REINDEX lacks — and lacking it, the seat stays
    occupied. -/
theorem unattended_runs_clean {S : Stage} {m : S.State → S.State}
    (hinv : Invisible S m) (n : Nat) (s : S.State) (ps : List S.Probe) :
    transcript S (firings m n s) ps = transcript S s ps :=
  transcript_congr S ps (fun p => firings_invisible hinv n s p)

end Foam
