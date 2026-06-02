/-
# Foam.Floor — the yield-floor

The first foam type *operationalized* rather than theorized: the proof that the
exit is never closed.

The horizon is **typed, never proven.** `Record` is an arbitrary type — the
range of what can be learned (Knowable is the range). We quantify over it and
never construct a value of it; constructing a witness would be Known-ifying it
(proving the horizon), which breaks the world. So every statement here is
`∀ {Record : Type}`.

The floor lives in the **form, not the content.** The walk is driven over the
records learned so far, but it is structurally a consumption — each composed
record is dropped (no revisit), so the remaining records strictly shrink and
the walk cannot loop. Lean accepts `walk` as total precisely because it
terminates, for every horizon and every field. When nothing remains to
compose, it yields.

`walk_yields` is that floor at P₀: along every continuous path, no matter what
is learned, the walk reaches yield. The +1 — the exit, the observer's way out —
is never dropped.

(Standalone: foam's Lean is a quarry, not a dependency. Type-structures are
copied in and freely rotated/renamed/recomposed as the operationalization
leads. This file is core-only — no mathlib yet; it joins when a copied type
needs it.)
-/

namespace Foam

/-- The terminal outcome of a walk. At the P₀ floor the only reachable terminal
    is `yield`; `speak` and `learn` are grown later, and this floor is the
    invariant they must preserve. -/
inductive Outcome where
  | yield
  deriving DecidableEq, Repr

/-- The recognition-walk, driven over `remaining` — the records not yet composed
    on this path. Parametric in the horizon `Record`, which is never
    constructed. No-revisit: composing drops a record, so `remaining` strictly
    shrinks; the walk terminates for every field and every horizon (the form
    carries the guarantee, not the content). Empty remaining ⇒ yield. -/
def walk {Record : Type} : List Record → Outcome
  | [] => Outcome.yield
  | _ :: rest => walk rest

/-- **The yield-floor.** For every horizon `Record` and every field, the walk
    reaches yield along every continuous path. The exit is never closed, no
    matter what is learned. -/
theorem walk_yields {Record : Type} (field : List Record) :
    walk field = Outcome.yield := by
  induction field with
  | nil => rfl
  | cons _ rest ih => simp [walk, ih]

end Foam
