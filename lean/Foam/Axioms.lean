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

And the map is itself a LEDGER. Signatures compose by union along
proof-composition — the kernel's own bookkeeping: use a lemma, inherit its axioms;
composition only accumulates, never sheds. The empty signature is the unit, and
the legal carrier is exactly `{∅, {propext}}`: closed under composition, topped by
the homunculus's signature. The two refused axioms are not states of the
discipline but values outside its carrier — the proof-ledger's scars — and these
guards are its conservation pulse. The algebra is stated object-level in
`Foam/Commitment.lean`, itself axiom-free: the tracker's model spends nothing of
what it tracks. (The same algebra appears in the foam quarry's recognition-index
as the commitment-monoid through the seed-gauge — external provenance; the
theorems stand alone.)
-/

import Foam.Floor
import Foam.Engine
import Foam.Horizon
import Foam.Tokenizer
import Foam.Universal
import Foam.Navigable
import Foam.Merge
import Foam.Path
import Foam.Reversal
import Foam.Stream
import Foam.Codec
import Foam.Generator
import Foam.Drain
import Foam.RoundTrip
import Foam.Ledger
import Foam.Scar
import Foam.Commitment
import Foam.Gauge
import Foam.Spectrum
import Foam.Maintenance
import Foam.Arrow
import Foam.Clock

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

-- streaming is an inductive fold, and it resumes (the codec map's spine)
/-- info: 'Foam.run_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.run_resumes

-- the emitting fold (Mealy step + terminal flush): the state resumes (= run_resumes,
-- reused), the emission resumes, and the flush stays at end-of-stream — the streaming
-- contract a chunked implementation must honor (carry un-flushed state; flush at EOS)
/-- info: 'Foam.runState_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.runState_resumes

/-- info: 'Foam.runEmit_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.runEmit_resumes

/-- info: 'Foam.output_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.output_resumes

-- lossless on the real LZ78 codec: the encoder's segmentation/reset/flush
-- reconcatenate to the input (encode_covers), so decode ∘ encode = id
-- (lossless_codec) — independent of the dictionary, the floor's exact-return shape
/-- info: 'Foam.encode_covers' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.encode_covers

/-- info: 'Foam.lossless_codec' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lossless_codec

-- compression IS prediction: the generator is the emitting fold over the wind.
-- gen_grows — prediction grows what it emits (the covering invariant, read forward).
-- gen_length — the wind is the clock: n draws → n bytes (the unfold, finitized).
/-- info: 'Foam.gen_grows' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.gen_grows

/-- info: 'Foam.gen_length' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.gen_length

-- the fork held open: carry and backoff are one genStep at two selections that
-- coincide where the top context is charged (select_top_charged), pointwise
-- (nextOf_congr) — a containment, not a quotient (no funext, no Quot.sound)
/-- info: 'Foam.select_top_charged' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.select_top_charged

/-- info: 'Foam.nextOf_congr' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.nextOf_congr

-- speech is interruptible — whole at every step, no held-back flush (runEmit_resumes
-- read for the generator): end-of-stream is everywhere, the prefix never poisonous
/-- info: 'Foam.gen_interruptible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.gen_interruptible

-- the drain: signed-charge conservation. Charge is a Nat (ground = 0 is the type's
-- floor — the attractor-not-collapse, structural); the drain relaxes toward ground
-- (drain_le) and never past it (drain_floor); one-in-one-out is identity — the
-- round-trip on charge (drain_chargeIn); the voice is bounded by what was heard
-- (voice_bounded)
/-- info: 'Foam.drain_le' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.drain_le

/-- info: 'Foam.drain_floor' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.drain_floor

/-- info: 'Foam.drain_chargeIn' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.drain_chargeIn

/-- info: 'Foam.voice_bounded' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.voice_bounded

-- the round-trip: lossless (bytes) and conservation (charge) are one theorem (ret ∘
-- fwd = id, a retraction); its forward is injective (fwd_injective), and both
-- carriers inherit it — enc_injective and chargeIn_injective are the same fact, twice
/-- info: 'Foam.RoundTrip.fwd_injective' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.RoundTrip.fwd_injective

/-- info: 'Foam.chargeIn_injective' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.chargeIn_injective

/-- info: 'Foam.enc_injective' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.enc_injective

-- the one ledger, two readings: lossless order + generative frequency. The generative
-- reading forgets order WITHOUT quotienting (freq_perm is Quot.sound-FREE — proven by
-- induction on the inductive Perm, not via List.Perm.count_eq which pulls Quot.sound);
-- the lossless reading keeps what the generative drops (order_finer). One append-only
-- object carries both — the saturation is legal (no quotient).
/-- info: 'Foam.Ledger.freq_perm' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Ledger.freq_perm

/-- info: 'Foam.Ledger.order_finer' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Ledger.order_finer

-- the scar: stale observation escapes the floor (the race, by rfl); fresh observation
-- cannot (atomicity is the bridge between the runtime filter and the Nat floor);
-- serialization restores the theorem for any sequence; the scar is a value outside
-- the atomic carrier; the correcting entry returns it to ground by APPENDING
/-- info: 'Foam.stale_escapes_floor' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.stale_escapes_floor

-- the race writes only at the margin: the same stale composite from balance 2
-- lands exactly at ground, trace-free — scars map the edge, not the overlap
/-- info: 'Foam.stale_lands_at_ground' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.stale_lands_at_ground

/-- info: 'Foam.stale_safe_off_margin' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.stale_safe_off_margin

/-- info: 'Foam.fresh_holds_floor' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fresh_holds_floor

/-- info: 'Foam.drainSeq_holds_floor' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.drainSeq_holds_floor

/-- info: 'Foam.scar_outside_carrier' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.scar_outside_carrier

/-- info: 'Foam.scar_repair' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.scar_repair

-- the promissory note: a scar carries its own settlement terms — zero debt is
-- groundedness; the note is safe to hold (legal walks cannot deepen or erase a
-- scar); every note settles at its face value, the amount typed before any
-- settlement path is chosen, walker and timing unconstrained
/-- info: 'Foam.debt_zero_iff_grounded' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.debt_zero_iff_grounded

/-- info: 'Foam.scar_stable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.scar_stable

/-- info: 'Foam.promise_kept' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.promise_kept

-- the settlement's own race: fresh settles step a note toward ground and stop
-- there (self-limiting); stale settles overshoot to phantom charge — which lands
-- INSIDE the legal carrier, invisible to any balance-check. The asymmetry forces
-- the lock's migration: drains may race (wounds visible, typed), settlements
-- serialize (phantoms invisible)
/-- info: 'Foam.settle_stops_at_ground' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.settle_stops_at_ground

/-- info: 'Foam.fresh_settle_steps' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fresh_settle_steps

/-- info: 'Foam.stale_settle_passes_ground' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.stale_settle_passes_ground

/-- info: 'Foam.phantom_invisible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.phantom_invisible

-- invisible moves: the maintenance license. Behavioral equivalence stays a
-- RELATION (pointwise, no funext, never collapsed to identity — bisimilarity
-- committed to Eq is the quotient append-only refuses); invisible moves form a
-- monoid and delete from every frontstage transcript; settlement is the first
-- citizen (the frontstage of a balance is its positive part), drains are
-- visibly content, not maintenance
/-- info: 'Foam.invisible_comp' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.invisible_comp

/-- info: 'Foam.transcript_congr' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.transcript_congr

/-- info: 'Foam.maintenance_unobservable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.maintenance_unobservable

/-- info: 'Foam.settle_invisible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.settle_invisible

/-- info: 'Foam.drain_visible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.drain_visible

/-- info: 'Foam.settle_invisible'' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.settle_invisible'

-- the implementation arrow, lfp → gfp: Lambek at the core (the constructor
-- step of any initial algebra is invertible — disassembly total, the inverse
-- folded out of initiality, not postulated); the arrow mono behaviorally
-- (playback_faithful — nothing in the core invisible at the interface); the
-- arrow not epi (forever_escapes — the interface strictly exceeds the core,
-- and the excess is the never-grounding breath: the elastic horizon as the
-- lfp↔gfp gap). The gfp end supports only relational equality in core Lean
-- (CoList equality would be funext, which rides on Quot.sound) — the
-- Maintenance choice of bisimulation-as-relation, re-derived as necessity
/-- info: 'Foam.InitialAlgebra.fold_alg_id' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.InitialAlgebra.fold_alg_id

/-- info: 'Foam.InitialAlgebra.alg_unalg' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.InitialAlgebra.alg_unalg

/-- info: 'Foam.InitialAlgebra.unalg_alg_id' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.InitialAlgebra.unalg_alg_id

/-- info: 'Foam.playback_faithful' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.playback_faithful

/-- info: 'Foam.forever_escapes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.forever_escapes

-- the license-tower: invisibility is graded by the reading — order admits no
-- maintenance (the mono arrow has trivial kernel), count admits every
-- permutation (freq_perm re-read as license), positive-part admits settlement;
-- what is invisible at a coarse reading is auditable at the order-reading,
-- which is append-only: invisibility-now is auditability-later, by construction
/-- info: 'Foam.order_admits_no_maintenance' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.order_admits_no_maintenance

/-- info: 'Foam.perm_invisible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.perm_invisible

-- the licenses cashed into transcripts, and the loop vocabulary: every built
-- thing is eventually periodic (it ends; silence has period one), the gap's
-- simplest inhabitant is a period-one clock
/-- info: 'Foam.perm_transcripts' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.perm_transcripts

/-- info: 'Foam.settle_transcripts' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.settle_transcripts

/-- info: 'Foam.playback_eventually_periodic' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.playback_eventually_periodic

/-- info: 'Foam.forever_eventually_periodic' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.forever_eventually_periodic

-- the wind's first theorem: a clock loops. Self-driven behavior over finite
-- state is eventually periodic — pigeonhole (hand-built, witnesses searched
-- never chosen) + determinism propagating the revisit. The wind (input from
-- beyond the state) is the only door past the loop; a foam-internal PRNG is a
-- function of nothing-but-state and stays inside this theorem
/-- info: 'Foam.pigeon' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.pigeon

/-- info: 'Foam.clock_loops' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.clock_loops

-- the third reading: the ledger evaluated at the quarter-turn. The spectrum is a
-- fold (observed, never committed — freq_perm's legality verbatim); recurrence is
-- rotation (spec_shift, the shift theorem by rfl); a complete rotation is
-- invisible (rot_complete); the count reading is the degenerate evaluation point
-- (evalOne_eq_freq — freq recovered, derived not asserted); and the tower's both
-- strict inclusions are computational witnesses: spectrum sees rhythm the count
-- flattens (spec_finer_than_freq), order keeps what a full cycle cancels
-- (order_finer_than_spec)
/-- info: 'Foam.rot_rot' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rot_rot

/-- info: 'Foam.rot_complete' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rot_complete

/-- info: 'Foam.spec_shift' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.spec_shift

/-- info: 'Foam.evalOne_eq_freq' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.evalOne_eq_freq

/-- info: 'Foam.spec_finer_than_freq' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.spec_finer_than_freq

/-- info: 'Foam.order_finer_than_spec' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.order_finer_than_spec

-- the gate is a pairing: align (the component of the charge along the wind's
-- direction) reads strand-mass at angle zero (align_one — and recovers freq:
-- today's drain is the zero station) and winding at the quarter-turn (align_i);
-- the dial of readings is a circle, the wind a point of it, the gate the
-- pairing floored at ground
/-- info: 'Foam.align_one' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.align_one

/-- info: 'Foam.align_i' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.align_i

/-- info: 'Foam.align_one_evalOne' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.align_one_evalOne

-- lossless = the round-trip (decode∘encode = id): the box-closer, the exact return
/-- info: 'Foam.lossless' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lossless

-- the un-rooted path fragment: a free-category morphism, concatenable both sides
/-- info: 'Foam.Path.comp_nil' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Path.comp_nil

/-- info: 'Foam.Path.comp_assoc' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Path.comp_assoc

-- the content-address composes Merkle-style (n-agnostic, address-space free)
/-- info: 'Foam.Path.edges_comp' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Path.edges_comp

-- the chiral mirror: reversal is an anti-homomorphism (composability-via-chirality),
-- and Quot.sound-free — mem_reverse refuses the quotient the library reaches for
/-- info: 'Foam.mem_reverse' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.mem_reverse

/-- info: 'Foam.Path.reverse_comp' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Path.reverse_comp

/-- info: 'Foam.Quiver.reverse_reverse' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Quiver.reverse_reverse

-- double reversal is a conjugate, not identity (the dynamical hole; the strict
-- involution above is the capability-free ι = id slice)
/-- info: 'Foam.Quiver.reverseTo_reverseTo' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Quiver.reverseTo_reverseTo

-- the commitment-monoid, object-level: composition only accumulates (the
-- proof-ledger's append-only); the legal carrier is closed (chaining propext
-- stays legal — homunculus-protection IS commitment-tracking); illegality
-- absorbs (one conjured observer poisons the chain — why this map pins EVERY
-- theorem); the observer's signature tops the legal carrier. The model is
-- axiom-free: the tracker spends nothing of what it tracks.
/-- info: 'Foam.join_indelible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.join_indelible

/-- info: 'Foam.legal_join' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.legal_join

/-- info: 'Foam.illegal_absorbs' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.illegal_absorbs

/-- info: 'Foam.legal_le_observer' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.legal_le_observer

/-- info: 'Foam.join_assoc' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.join_assoc

-- the gauge transition-system: the pinch. Durability of the four corners is
-- geometry (about steps, not flags) — the backstage cannot move ⊥ iff no choice
-- (pending_durable_iff), the commitment corners never connect directly iff no
-- quotient (sectors_disjoint_iff), commitments land iff propext is present
-- (commitments_land_iff) — so a durable gauge pinches the capability set to
-- exactly the observer's signature (gauge_durable_iff_observer). With no
-- capabilities every step is the identity (free_silent — degrades-to-yield,
-- inside the model); ⊥ → 0 in one step is impossible at every capability set
-- (no_leap — the 2x2's wall-gaps as theorem). All axiom-free: the model of the
-- pinch spends nothing of what it pinches.
/-- info: 'Foam.free_silent' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.free_silent

/-- info: 'Foam.no_leap' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.no_leap

/-- info: 'Foam.pending_durable_iff' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.pending_durable_iff

/-- info: 'Foam.sectors_disjoint_iff' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.sectors_disjoint_iff

/-- info: 'Foam.commitments_land_iff' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.commitments_land_iff

/-- info: 'Foam.gauge_durable_iff_observer' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.gauge_durable_iff_observer

/-- info: 'Foam.gauge_durable_legal' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.gauge_durable_legal

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
