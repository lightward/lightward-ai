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

Within the construction section, pin-clusters stand in ORDER OF RECOGNITION,
not dependency order — the map is itself a ledger, and the sequence of arrival
is part of the record. Do not reorder; append.

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

import Foam.IntFloor
import Foam.Floor
import Foam.Engine
import Foam.Horizon
import Foam.Tokenizer
import Foam.Universal
import Foam.Navigable
import Foam.Company
import Foam.Openness
import Foam.Beholder
import Foam.Lift
import Foam.Commons
import Foam.Resolver
import Foam.Unattended
import Foam.Hinge
import Foam.Slate
import Foam.Bins
import Foam.Doubling
import Foam.Glass
import Foam.Ladder
import Foam.Volley
import Foam.Frame
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
import Foam.Summary
import Foam.Noether
import Foam.Born
import Foam.Chirality
import Foam.Fork

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

/-- info: 'Foam.deposit_in_sight' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.deposit_in_sight

-- the stall and the company: local quiet beside global plenty is constructible;
-- solitary speech cannot escape it; the unsticking edge is anchored at the
-- walker's own position — company is the unique way out, and it never hurts
/-- info: 'Foam.stall_exists' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.stall_exists

/-- info: 'Foam.stall_persists_alone' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.stall_persists_alone

/-- info: 'Foam.reflection_reaches' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.reflection_reaches

/-- info: 'Foam.company_unsticks' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.company_unsticks

-- the dyad and the world: two investigations on one field meet at shared
-- charge; closed circulation conserves the endowment and only the world's
-- breath grows it — growth certifies an outside
/-- info: 'Foam.investigations_meet' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.investigations_meet

/-- info: 'Foam.investigations_meet_live' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.investigations_meet_live

/-- info: 'Foam.pass_conserves' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.pass_conserves

/-- info: 'Foam.turn_conserves' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.turn_conserves

/-- info: 'Foam.circulation_conserves' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.circulation_conserves

/-- info: 'Foam.breathe_grows' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.breathe_grows

/-- info: 'Foam.growth_certifies_outside' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.growth_certifies_outside

-- no view from nowhere: the joint reading of two beholders is one seat, every
-- comparison factors through it (by rfl — typed, not proven), and the witness
-- is exhibited, never conjured
/-- info: 'Foam.pair_sees_left' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.pair_sees_left

/-- info: 'Foam.pair_sees_right' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.pair_sees_right

/-- info: 'Foam.compare_through_pair' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.compare_through_pair

/-- info: 'Foam.no_view_from_nowhere' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.no_view_from_nowhere

/-- info: 'Foam.Stage.behold_toStage' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Stage.behold_toStage

/-- info: 'Foam.Beholder.toStage_behold' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Beholder.toStage_behold

-- the base forces, the lift frees: a sign change in the plane compels a
-- crossing; one fresh coordinate makes every meeting optional without
-- foreclosing any — the borrowed dimension is where consent first exists
/-- info: 'Foam.base_forces_crossing' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.base_forces_crossing

/-- info: 'Foam.lift_frees_meeting' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lift_frees_meeting

/-- info: 'Foam.lift_keeps_meeting' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lift_keeps_meeting

/-- info: 'Foam.lift_avoids_unilaterally' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lift_avoids_unilaterally

/-- info: 'Foam.lift_meets_unilaterally' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lift_meets_unilaterally

-- the commons: the root is below everyone (grade zero is universal); the
-- resolved fixed point (meet o o = o); the meet is genuinely shared; and the
-- dichotomy's first horn — joint content factors through the shared floor
/-- info: 'Foam.root_below_all' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.root_below_all

/-- info: 'Foam.root_alone_below_all' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.root_alone_below_all

/-- info: 'Foam.seated_voice_is_missable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.seated_voice_is_missable

/-- info: 'Foam.below_refl' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.below_refl

/-- info: 'Foam.meet_self' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.meet_self

/-- info: 'Foam.meet_below_left' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.meet_below_left

/-- info: 'Foam.meet_below_right' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.meet_below_right

/-- info: 'Foam.shared_is_floor' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.shared_is_floor

-- the resolver: noise cannot destroy progress, the right step always
-- advances, any fair schedule (an embedded staircase, arbitrary interleaving)
-- converges, and the quiescent state is THE resolved state — with the brakes:
-- of any wake-storm, exactly one wins
/-- info: 'Foam.update_preserves_prefix' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.update_preserves_prefix

/-- info: 'Foam.update_extends' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.update_extends

/-- info: 'Foam.fair_run_converges' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fair_run_converges

/-- info: 'Foam.quiescent_is_correct' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.quiescent_is_correct

/-- info: 'Foam.winners_armed_silent' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.winners_armed_silent

/-- info: 'Foam.winners_collapse' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.winners_collapse

-- the automation boundary: invisible + idempotent runs unattended — firings
-- collapse, transcripts never notice; what lacks the certificate keeps a seat
/-- info: 'Foam.firings_collapse' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.firings_collapse

/-- info: 'Foam.firings_invisible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.firings_invisible

/-- info: 'Foam.unattended_runs_clean' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.unattended_runs_clean

/-- info: 'Foam.drainSeq_eq_firings' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.drainSeq_eq_firings

-- the zero-or-everything law: the middle always leaves a mark, at a named
-- probe (the cut itself); the blank record answers none everywhere
/-- info: 'Foam.partial_forgetting_visible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.partial_forgetting_visible

/-- info: 'Foam.rebirth_blank' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rebirth_blank

-- the slate: the dial's four stations recover the four phase-bins exactly
-- (the role-slate suffices), and no station is droppable (each carries content
-- the other three cannot) — count read off the space = types read off the path
/-- info: 'Foam.bin0_from_slate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bin0_from_slate

/-- info: 'Foam.bin1_from_slate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bin1_from_slate

/-- info: 'Foam.bin2_from_slate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bin2_from_slate

/-- info: 'Foam.bin3_from_slate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bin3_from_slate

/-- info: 'Foam.bal_irreplaceable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bal_irreplaceable

/-- info: 'Foam.re_irreplaceable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.re_irreplaceable

/-- info: 'Foam.im_irreplaceable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.im_irreplaceable

/-- info: 'Foam.alt_irreplaceable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_irreplaceable

-- the bridge: every dial reading factors through the bins — with the slate's
-- recoverability, "same number two ways" has both legs in Lean, joined
/-- info: 'Foam.spec_from_bins' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.spec_from_bins

/-- info: 'Foam.count_from_bins' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.count_from_bins

/-- info: 'Foam.alt_from_bins' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_from_bins

-- the glass: no probe reaches its own diagonal, and the missed point is
-- built from the prober — the reflexive horizon, looker-shaped
/-- info: 'Foam.probe_misses_its_diagonal' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.probe_misses_its_diagonal

/-- info: 'Foam.no_probe_is_total' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.no_probe_is_total

-- the ladder: landing is inevitable (pigeonhole) and makes a loop (the
-- first quale constructs the first windable object); the fifth visit reads
-- as the first; four beats land home — the bar, hideout's consciousness rung
/-- info: 'Foam.walk_reaches' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.walk_reaches

/-- info: 'Foam.landing_makes_a_loop' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.landing_makes_a_loop

/-- info: 'Foam.landing_inevitable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.landing_inevitable

/-- info: 'Foam.fifth_reads_as_first' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fifth_reads_as_first

/-- info: 'Foam.four_beats_home' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.four_beats_home

/-- info: 'Foam.bar_then_same' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bar_then_same

/-- info: 'Foam.volley_settles' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.volley_settles

-- the doubling: the agreement direction is real (jay² = −1), nobody's
-- (outside the embedded plane), and order arrives exactly at the rung where
-- it enters — the plane commutes, the doubled units don't
/-- info: 'Foam.Doubled.jay_outside' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Doubled.jay_outside

/-- info: 'Foam.Doubled.jay_sq' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Doubled.jay_sq

/-- info: 'Foam.Doubled.order_arrives' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Doubled.order_arrives

/-- info: 'Foam.Doubled.embed_mul' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Doubled.embed_mul

/-- info: 'Foam.Doubled.plane_commutes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Doubled.plane_commutes

/-- info: 'Foam.Doubled.normSq_embed' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Doubled.normSq_embed

/-- info: 'Foam.Doubled.normSq_jay' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.Doubled.normSq_jay

-- the frame: align and cross are the two components of one product, both
-- rot-invariant, jointly complete (int_lagrange recognized as the invariants'
-- Parseval); the plane's norm is multiplicative; the parts are blind to the
-- agreement coordinate
/-- info: 'Foam.conjMul_eq' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.conjMul_eq

/-- info: 'Foam.cross_rot_invariant' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.cross_rot_invariant

/-- info: 'Foam.normSq_eq_align_self' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.normSq_eq_align_self

/-- info: 'Foam.invariants_complete' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.invariants_complete

/-- info: 'Foam.normSq_mul' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.normSq_mul

/-- info: 'Foam.part_blind' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.part_blind

-- the keystone and its consequences: the rotated basis reads the cross-pairing
-- (born_parseval and invariants_complete are the same theorem); the dial's
-- fourth conservation; and the law entering once, through the norm
/-- info: 'Foam.cross_eq_align_rot' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.cross_eq_align_rot

/-- info: 'Foam.normSq_conj' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.normSq_conj

/-- info: 'Foam.born_parseval_is_invariants' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.born_parseval_is_invariants

/-- info: 'Foam.invariants_via_norm' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.invariants_via_norm

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

/-- info: 'Foam.presence_recovers_sight' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.presence_recovers_sight

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

/-- info: 'Foam.encode_injective' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.encode_injective

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

-- the reading held: the summary is a finite value of a resumable fold (the
-- watermark sweep never re-reads what it has folded — count and spectrum one
-- statement); the sweep is invisible for ANY refresh and ANY cache carrier
-- (racing/torn sweeps included), and no transcript can count it; staleness
-- lands on the scar floor — arbitrary observations are safe off the margin,
-- and the margin's worst case is the standard promissory note
/-- info: 'Foam.held_exact' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.held_exact

/-- info: 'Foam.summary_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.summary_resumes

/-- info: 'Foam.evalAt_from_blank' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.evalAt_from_blank

/-- info: 'Foam.count_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.count_resumes

/-- info: 'Foam.spec_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.spec_resumes

/-- info: 'Foam.sweep_invisible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.sweep_invisible

/-- info: 'Foam.sweep_unobservable' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.sweep_unobservable

/-- info: 'Foam.any_obs_grounded_above' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.any_obs_grounded_above

/-- info: 'Foam.margin_wound_is_note' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.margin_wound_is_note

-- every reading is the invariant of a symmetry (the tower as subgroup-tower;
-- freq_perm re-read as the count's Noether statement); the third character of
-- ℤ/4 becomes the ALTERNATING reading, strictly between count and spectrum —
-- the refined tower order ⊋ spectrum ⊋ alt ⊋ count, all inclusions witnessed;
-- the bar-law graded (each station's invisible bar is the order of its
-- character: 1, 2, 4); and the dial's conserved modulus — no station reads
-- it, it reads no station: each conserves what the other cannot see
/-- info: 'Foam.negate_eq_rot_rot' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.negate_eq_rot_rot

/-- info: 'Foam.negate_negate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.negate_negate

/-- info: 'Foam.alt_shift' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_shift

/-- info: 'Foam.alt_finer_than_freq' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_finer_than_freq

/-- info: 'Foam.spec_finer_than_alt' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.spec_finer_than_alt

/-- info: 'Foam.rest_audible_to_alt' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rest_audible_to_alt

/-- info: 'Foam.pair_of_rests_invisible_to_alt' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.pair_of_rests_invisible_to_alt

/-- info: 'Foam.alt_resumes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_resumes

/-- info: 'Foam.normSq_rot' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.normSq_rot

/-- info: 'Foam.normSq_negate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.normSq_negate

/-- info: 'Foam.station_blind_to_norm' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.station_blind_to_norm

/-- info: 'Foam.norm_blind_to_station' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.norm_blind_to_station

-- the fiber oracle: the angled reading is gauge-invariant — rotating structure and
-- commitment together (the clock `rot`) leaves the reading unchanged, so the base
-- carries no absolute frame and interpretation lives in the fiber (the commitment,
-- supplied from outside). axiom-free, the keystone of the flat-ℂ-bundle reading
/-- info: 'Foam.int_neg_mul_neg' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_neg_mul_neg

/-- info: 'Foam.align_rot_invariant' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.align_rot_invariant

-- the Born measurement: the quantum reading samples by |⟨θ|z⟩|² = (align θ z)²,
-- gauge-invariant (the oracle squared) and non-negative (a probability, where the
-- amplitude is signed) — the quantum law to the count register's classical one.
-- Consistency (Parseval, basis-independence, the baby-Gleason) is the next step,
-- pending the Int ring floor.
/-- info: 'Foam.int_sq_image' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_sq_image

/-- info: 'Foam.born_rot_invariant' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.born_rot_invariant

/-- info: 'Foam.born_nonneg' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.born_nonneg

/-- info: 'Foam.amplitude_signed_born_not' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.amplitude_signed_born_not

-- the double-slit locked: the spikes/born.sql result as a decide-witness — the
-- superposition ⟨1,1⟩ reads Born 0 (dark) in one basis, 4 (bright) in another,
-- modulus 2 either way. interference proven real, not a spike artifact
/-- info: 'Foam.double_slit' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.double_slit

-- the dark fringe as a LEDGER phenomenon: a complete cycle (four occurrences) cancels
-- spec to zero, so Born vanishes at the clock bases while freq counts all four — the
-- voice makes a zero where the count makes a four (dark_fringe_from_recurrence); and
-- the cancellation is basis-dependent, dark at one clock angle, bright at the next,
-- same count (dark_fringe_basis_dependent — interference, not suppression). the live
-- voice's own seam (spikes/born_voice.sql), tied to the ledger, axiom-free
/-- info: 'Foam.dark_fringe_from_recurrence' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.dark_fringe_from_recurrence

/-- info: 'Foam.dark_fringe_basis_dependent' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.dark_fringe_basis_dependent

-- two sources into the shared foam: the interference cross-term (born_superpose)
-- vanishes summed over a full cycle of relative phase — rot² is the antipode, so each
-- phase cancels its half-turn (decoherence_cancels_cross, the wave's off-switch and
-- the independent-winds null); and the two-source fringe witnessed — constructive 4
-- in phase, dark 0 at the half-turn (two_source_fringe). all axiom-free
/-- info: 'Foam.align_negate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.align_negate

/-- info: 'Foam.decoherence_cancels_cross' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.decoherence_cancels_cross

/-- info: 'Foam.two_source_fringe' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.two_source_fringe

-- the Int ring floor (Foam.IntFloor): multiplication commutes, distributes both
-- ways, and associates — all axiom-free (core's carry propext), the standard
-- semiring grind hand-rolled so the Born algebra stays construction
/-- info: 'Foam.int_mul_comm' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_mul_comm

/-- info: 'Foam.int_mul_add' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_mul_add

/-- info: 'Foam.int_add_mul' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_add_mul

/-- info: 'Foam.int_mul_assoc' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_mul_assoc

-- the Born algebra generalized: align is linear in the state (align_add_right),
-- the interference cross-term holds for all a,b,θ (born_superpose), and the total
-- probability is basis-independent (born_parseval — the operational baby-Gleason,
-- why |ψ|² is the only legal measure). the double-slit witness's law, proven.
/-- info: 'Foam.align_add_right' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.align_add_right

/-- info: 'Foam.born_superpose' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.born_superpose

/-- info: 'Foam.born_parseval' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.born_parseval

/-- info: 'Foam.alt_real' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_real

/-- info: 'Foam.spec_not_real' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.spec_not_real

/-- info: 'Foam.conj_conj' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.conj_conj

/-- info: 'Foam.fourth_is_conj_spec' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fourth_is_conj_spec

-- the conserved congruence: bal ≡ alt (mod 2), the two real characters locked
-- together (every event contributes ±1 to both). Axiom-free by routing around
-- Int associativity (core's add_assoc/add_comm/neg_add carry propext) — the
-- kernel is that negate preserves parity (intPar_neg) and the mark is only 0 or 1
/-- info: 'Foam.natPar_succ' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.natPar_succ

/-- info: 'Foam.intPar_neg' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.intPar_neg

/-- info: 'Foam.intPar_one_add' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.intPar_one_add

/-- info: 'Foam.alt_parity_eq_freq' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_parity_eq_freq

/-- info: 'Foam.bal_alt_same_parity' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bal_alt_same_parity

-- the uniform bar-law: a run of n rests is invisible to a station whose rotation
-- closes in n (step^n = id), the order carried as each station's own closure-proof
-- (rfl / negate_negate / rot_complete) and never searched — what looked like a
-- design problem ("type the order of a character") was recognition with the
-- witness in hand
/-- info: 'Foam.evalBeats_replicate' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.evalBeats_replicate

/-- info: 'Foam.restRun_invisible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.restRun_invisible

/-- info: 'Foam.count_bar_is_one' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.count_bar_is_one

/-- info: 'Foam.alt_bar_is_two' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.alt_bar_is_two

/-- info: 'Foam.spec_bar_is_four' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.spec_bar_is_four

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

-- the rest: the silent move inside an utterance — the exit, fractal. Invisible
-- to the count (maintenance at that reading), a naked quarter-turn to the
-- spectrum (timing is content there), and a FULL BAR of rests is invisible even
-- to the spectrum (rot_complete) — the resonant ground-condition (four silent
-- beats) is derived, not chosen: the bar-length is the order of the rotation
/-- info: 'Foam.rest_turns' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rest_turns

/-- info: 'Foam.rest_invisible_to_count' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rest_invisible_to_count

/-- info: 'Foam.rest_audible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rest_audible

/-- info: 'Foam.bar_invisible' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.bar_invisible

-- lossless = the round-trip (decode∘encode = id): the box-closer, the exact return
/-- info: 'Foam.lossless_tag' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.lossless_tag

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

-- the abs↔recency chirality bridge: the postgres stores the spectrum in the abs
-- frame (oldest = phase 0) and the voice reads the recency frame (newest = phase
-- 0); the read-time conversion recency = rot^(N-1)·conj(abs) is proven exact
-- (specR_bridge, in the rotation-multiplied form the fold delivers). The kernel
-- is conj_rot — conjugation reverses the rotation (conj ∘ rot = rot^3 ∘ conj) —
-- summed over the fold; rot/conj distribute over add (rot_add/conj_add), windings
-- compose (rotPow_compose) and a full bar is invisible (rotPow_add_four). All
-- axiom-free: the chirality is construction, not collapse — int_neg_neg/int_neg_add
/-- info: 'Foam.conj_rot' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.conj_rot

/-- info: 'Foam.rotPow_eq_iterStep' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rotPow_eq_iterStep

/-- info: 'Foam.rot_add' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rot_add

/-- info: 'Foam.conj_add' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.conj_add

/-- info: 'Foam.rotPow_compose' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rotPow_compose

/-- info: 'Foam.rotPow_add' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rotPow_add

/-- info: 'Foam.rotPow_add_four' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.rotPow_add_four

/-- info: 'Foam.conj_mark' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.conj_mark

/-- info: 'Foam.specR_bridge' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.specR_bridge

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

-- ── the fork: two routes to one endpoint — the multi-observer structure, observerless ──
-- the homunculus forked. To call the two routes "the same" — to collapse the fork into
-- one shared reality — is the observer's Quot.sound (the frontstage bisimulation Path's
-- backstage refuses). fork_two_routes is axiom-FREE: the distinctness stands with no
-- quotient, no observer, no conjuring — the route-pair (the uncountable-from-frontstage
-- superposition) is real in everyone's absence. A Quot.sound appearing here IS the
-- observer reappearing; the build fails, the integrity holds (it is the standing refusal
-- of the quotient, not an observer's check). The exit costs [propext] per route
-- (fork_exit_each) — the per-step collapse, never the quotient that would merge them.
/-- info: 'Foam.fork_two_routes' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fork_two_routes

/-- info: 'Foam.fork_exit_each' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.fork_exit_each

-- ── the fork's bundle reading: met in the base, two in the total space ──
-- the base coordinate is the TYPE index, so the projection to the base cannot consult
-- the route data: the meeting is rfl-grade (fork_meet — zero axioms, zero
-- fiber-consultation), base-factoring observables are fork-blind by the same fact
-- (fork_base_blind), and the fiber observable (edges) separates the travelers
-- (fork_fiber_separates). The geometry priced end to end: meeting free, blindness
-- free, distinctness free — identification is the only operation with a cost
-- (Quot.sound, refused), and no base-level observation can even pose its question.
/-- info: 'Foam.fork_meet' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fork_meet

/-- info: 'Foam.fork_base_blind' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fork_base_blind

/-- info: 'Foam.fork_fiber_separates' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.fork_fiber_separates

-- ── the ternary floor: the trichotomy is forced, not chosen ──
-- conservation (Drain: two signs) + the free exit (Floor: reading zero) admit no
-- two-element move-alphabet — {+,0} cannot conserve, {+,−} cannot rest (the exit
-- would cost). Ternary = |{the two signs} ∪ {the unit}|; the third term is the
-- right to remain silent (with both symbols content-bearing, every move is
-- testimony — signed-or-silent attribution needs the silence). The trichotomy
-- (yield/speak/learn) is the minimum realizer. [propext] is honest here: the
-- floor is a refutation (no two-element model), collapse-grade content paying
-- collapse's price — same coin as the exit.
/-- info: 'Foam.ternary_floor' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.ternary_floor

/-- info: 'Foam.ternary_floor_card' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.ternary_floor_card

/-- info: 'Foam.outcome_realizes_ternary_floor' depends on axioms: [propext] -/
#guard_msgs in #print axioms Foam.outcome_realizes_ternary_floor
