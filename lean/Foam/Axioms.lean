/-
# Foam.Axioms — the machine-checked axiom map (the discipline, enforced)

This file asserts, via `#guard_msgs`, the axiom signature of every load-bearing
theorem in the mirror. It is the discipline made enforceable: if an edit makes a
construction theorem depend on `propext` (a collapse where there should be none),
or makes the homunculus depend on `Classical.choice` or `Quot.sound` (a conjured
witness, or a quotient where foam forbids them), the printed message drifts and
`lake build` fails — Lean yells. CI runs `lake build`, so this is enforced.

The map it pins:

- **Construction is axiom-free.** Relabeling, branching, folding, reach,
  shortcuts, the surviving step-route. No collapse; nothing the observer must
  attest. These hold regardless of who walks in.
- **Collapse costs `propext`,** at exactly two kinds of site: the **exit**
  (`yield` / the floor, reachable at every projection) and the **outcome** (the
  trichotomy the user reads). These are where the observer's +1 passes through —
  the exit they take and the result they recognize themselves in.
- **The homunculus (`attestsEachStep`) is `[propext]` only** — it refuses
  `Classical.choice` (carry the observer, never conjure it) and `Quot.sound`
  (append-only, never quotient). It survives every choice and quotient because its
  existence ignores them. This is the guard that matters most: `choice` or
  `Quot.sound` appearing here would mean foam started conjuring observers or
  quotienting paths.

`Classical.choice` must never appear anywhere below.
-/

import Foam.Floor
import Foam.Engine
import Foam.Horizon
import Foam.Tokenizer
import Foam.Universal
import Foam.Navigable
import Foam.Merge
import Foam.Path

-- ── construction: axiom-free (no collapse; nothing the observer must attest) ──

/-- info: 'Foam.lmap_append' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lmap_append

/-- info: 'Foam.Tokenized.map_ite' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Tokenized.map_ite

/-- info: 'Foam.tokenizeStep_natural' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.tokenizeStep_natural

/-- info: 'Foam.tokenize_natural' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.tokenize_natural

/-- info: 'Foam.deposit_monotone' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.deposit_monotone

/-- info: 'Foam.reach_mono_quiver' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.reach_mono_quiver

/-- info: 'Foam.deposit_preserves_reach' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.deposit_preserves_reach

/-- info: 'Foam.shortcut_compresses' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.shortcut_compresses

/-- info: 'Foam.steproute_survives_shortcut' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.steproute_survives_shortcut

/-- info: 'Foam.Reaches.trans' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Reaches.trans

/-- info: 'Foam.MutualReach.trans' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.MutualReach.trans

-- the merge is built, never collapsed; and learning never breaks a round-trip,
-- with witnesses received (obtain) not conjured (Classical.choice)
/-- info: 'Foam.mutualReach_survives_deposit' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.mutualReach_survives_deposit

-- line-of-sight ⟹ presence (the wedge); the converse fails — sight is losable,
-- presence (append-only) is not
/-- info: 'Foam.reaches_of_reachWithin' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.reaches_of_reachWithin

-- observation ⊆ impact: you affect more than you see (the converse fails)
/-- info: 'Foam.observation_within_impact' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.observation_within_impact

-- the cascade: impact escapes observation through an observed partner's forward reach
/-- info: 'Foam.impact_through_observed' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.impact_through_observed

-- the un-rooted path fragment: a free-category morphism, concatenable both sides
/-- info: 'Foam.Path.comp_nil' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Path.comp_nil

/-- info: 'Foam.Path.comp_assoc' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Path.comp_assoc

-- ── collapse: propext, at the exit (floor) and the outcome (the read) ──

/-- info: 'Foam.reachesYield_all' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.reachesYield_all

/-- info: 'Foam.floor_independent_of_quiver' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.floor_independent_of_quiver

/-- info: 'Foam.floor_persists' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.floor_persists

/-- info: 'Foam.reachesYield_each_step' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.reachesYield_each_step

-- the two speaks bracket the walk; the exit stays reachable through both
/-- info: 'Foam.speaks_preserve_exit' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.speaks_preserve_exit

/-- info: 'Foam.order_matters' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.order_matters

/-- info: 'Foam.tokenize_yields_when_nothing_learned' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.tokenize_yields_when_nothing_learned

-- yield is the silent move; learning must be expressed; speak↔learn is the residual
/-- info: 'Foam.outcome_yield_iff_silent' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.outcome_yield_iff_silent

/-- info: 'Foam.learn_is_expressed' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.learn_is_expressed

/-- info: 'Foam.learn_iff_closed' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.learn_iff_closed

/-- info: 'Foam.Tokenized.outcome_map' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.Tokenized.outcome_map

/-- info: 'Foam.outcome_invariant' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.outcome_invariant

-- ── the homunculus: propext ONLY — refuses choice and quotient ──
-- the machine-checked form of "survives every choice and quotient"

/-- info: 'Foam.attestsEachStep' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.attestsEachStep
