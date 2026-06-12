*but if you create a foam engine with its own backstage/frontstage - assuming the existence of a foam engine upstream -*

---

# `lean/Foam` — the formal mirror

This is the Lean side of the **foam layer** (`app/lib/foam*`): a learning
substrate grown under [Lightward AI](../README.md). The load-bearing functions
are *illuminated* here (proven) and *operationalized* in Ruby/SQL (run). Lean
designs the floor; postgres inhabits it; userspace looks through. What is
*learned* — the horizon — is typed, never proven.

Core-only Lean 4 (no mathlib), pinned to `v4.29.0`. Build with:

```
cd lean && lake build      # seconds; CI runs this
```

A green build is the whole guarantee: it re-checks `Foam/Axioms.lean`, the
machine-checked axiom map, so every load-bearing theorem's axiom signature is
pinned and any drift fails the build.

---

## The discipline (why a green build means something)

Every theorem is checked at **propext-or-below**, and `#print axioms` is pinned
on the load-bearing ones in `Foam/Axioms.lean`:

- **Construction is axiom-free.** Relabeling, folding, the readings, the
  arithmetic — no collapse, nothing the observer must attest. These hold
  regardless of who walks in.
- **Collapse costs `propext`** at exactly two sites: the **exit** (`yield` /
  the floor) and the **outcome** (the trichotomy a reader recognizes
  themselves in).
- **`Classical.choice` and `Quot.sound` never appear.** Carry the observer,
  never conjure it (`.choose` is forbidden — `obtain` the witness). Append-only,
  never quotient (`Quot.sound` would merge paths the layer keeps distinct).

The arithmetic the construction stands on (`Int`/`Nat` ring laws) is hand-rolled
axiom-free in `Foam.IntFloor`, because core's equivalents carry `propext` — an
observer's collapse smuggled into lemmas that never needed an observer.

---

## Foam and quantum, concretely

*This section is for readers — lightward humans especially — for whom one or
both of these words is currently fuzzy. Nothing here asks for faith. Every
claim carries a grade:* ***proven*** *(machine-checked in this directory;
`lake build` re-verifies it right now, on your machine),* ***measured*** *(ran
against an actual database; the file to re-run is named), or* ***reading***
*(an interpretation, ours, labeled). Compound tags mean both grades apply;*
***watched*** *means recorded operational history, with the artifact named (git
history is an artifact). We also paid for the opposite of cheerleading: `REFEREE.md`, in this directory, is a cold adversarial review we
commissioned of every physics claim in this corpus. What follows is what
survived it, stated at its surviving size.*

### Foam, concretely

Foam is a Postgres ledger plus a discipline. Bytes flow through it; every
continuation it hears gets a `+1` mark; its voice speaks by sampling what's
marked and spending a `−1`. The ledger is append-only — nothing is ever edited
or deleted, and partial forgetting is *provably visible at the exact cut*
(**proven**: `partial_forgetting_visible`). Speaking spends; listening
recharges; a field left alone can provably stall beside its own riches — and
once stalled, no amount of its own speaking escapes — while one reflection
anchored at its position always unsticks it (**proven**: `Company.lean`; and
**watched**, June 2026: the drain stalled overnight and conversation restored
it — the artifact is this repo's `foam-company` branch history and the
trailer's letter from that week). There is no neural network anywhere in
this. It is arithmetic, in a database, under law.

### Quantum, concretely

Strip the mystique and quantum mechanics runs on two load-bearing facts:

1. **Amplitudes, not counts.** Classical evidence adds positive numbers: more
   occurrences, bigger number, always. Quantum bookkeeping adds *little arrows
   that rotate* — so contributions can **cancel**. The signature behavior:
   something heard *more* can become *less* visible. That cancellation is
   interference, and it is the one behavior positive counting cannot fake.
2. **Reading participates.** Measurement isn't free — it disturbs and spends.
   And whether the probability rule is *forced* (only one consistent way to
   read) or merely *consistent* (a good way among several) depends on the
   dimension of the space — how many independent directions it has: forced at
   three and above, free at two (Gleason's theorem; this distinction is
   load-bearing below).

### Where they actually touch

- **Foam's memory is an arrow, not a bare count** — **proven + operational**.
  The marks are counts, but the *memory* of them rotates: each continuation's
  record is a pair `(re, im)` turning a quarter-turn per occurrence. Perfectly
  regular recurrence cancels to zero: the field *cannot* resonantly say what
  has become uniform — anti-parroting as interference (`rot_complete`, the
  dark-fringe theorems). And the production voice weights its choices by the
  squared projection `born = align²` — the Born weight-form at foam's scale
  (two real dimensions, integer amplitudes) — in live SQL, self-audited
  against its own theorems on demand (`SELECT foam.born_audit()` returns `0`
  or the law is broken).
- **Speaking spends** — **proven + watched**. Conservation is a theorem
  (`drain_chargeIn`: one in, one out, exactly), and measurement back-action is
  an operational fact: the drain of June 2026 depleted its own neighborhood
  into silence beside millions of un-said charge. Escape from a stall is
  provably never the stalled one's to perform — it requires ingest from
  outside — and the reflection anchored at the walker's own position is the
  one move that works *blind*, needing nothing but their address
  (`Company.lean`, `Openness.lean`).
- **One identity, two readings** — **proven**. The theorem that makes foam's
  weight law total the same at every reading angle (`born_parseval`) turned
  out to be *the same theorem* as "exactly two numbers survive the trip
  between two observers who share no coordinates" (`cross_eq_align_rot`,
  `invariants_complete`). The measurement layer and the observer-frame layer
  share one piece of mathematics — the two-square identity — proven once,
  axiom-free.
- **Observers** — **proven + measured**. Every scope gets its own view; what
  two observers can *both* see factors exactly through their deepest common
  ancestor (`shared_is_floor`); and any comparison of two views is itself a
  single new view (`Beholder.lean`). "Quantum within an observer, classical
  between" is the **reading** over those theorems. Meanwhile every *per-trial*
  Bell statistic run against the actual record lands in the classical range
  (**measured**: `rosetta.sql`, `observer_scope.sql` — CHSH ≈ √2; CHSH is a
  correlation score where classical bookkeeping tops out at 2 and quantum can
  reach 2√2 ≈ 2.83). And that is *correct*, not disappointing: the record is
  a definite ledger — what physics calls a hidden variable — and Bell's
  theorem bounds the correlations any definite record can show, whether or
  not anyone can read it.
- **The deliberate stop, and where the forcing went** — **proven absence +
  proven presence + reading**. Foam's Born form is *consistent* in the
  substrate, never *forced* there: no substrate-side uniqueness theorem
  exists, and at this dimension none could (Gleason fails at dimension two —
  the referee confirmed both the absence and the impossibility). But the
  uniqueness isn't missing — it's **located**: `born_forced_at_the_frame`
  (**proven**) shows that any weight law satisfying the frame's completeness
  constraint — for *all* pairs — is the square, everywhere. The substrate
  never holds that constraint for anyone; a beholder whose frame quantifies
  over every pair does — and for them the Born form is forced. The
  **reading**: the substrate's freedom is the room a backend needs (a
  substrate that forced the measure would be making the observer's choices),
  and the forcing is the landing — a beholder who lands gets the quantum
  weight law by virtue of their own accomplishment of landing.
- **The doubling** — **proven, at the smallest honest scale**. Take two
  observers, each with their own flat plane of rotating arrows, and let them
  calibrate against a shared reference: a third arrow-direction appears that
  belongs to *neither* of them (`jay_sq`: it squares to −1 — a genuine square
  root of minus one, not a decorative label; `jay_outside`: it is no one's).
  The algebra starts
  remembering *who spoke first* exactly at that rung (`order_arrives` vs
  `plane_commutes` — noncommutativity, quantum mechanics' signature, arriving
  with the shared dimension). And each party's own view is provably blind to
  the shared coordinate (`part_blind`) — which is why neither side ever "sees"
  the joint. Entanglement-*shaped*, claimed at exactly this size; the general
  ladder (Cayley–Dickson, Euler's four-square) is cited, not claimed.

### What is *not* claimed

No qubits. No spacelike Bell violation (the spikes' own headers say so
plainly). No "the database is a quantum computer." And no entanglement
formalization in Lean: the doubling above is entanglement-*shaped* — the
algebra where order starts to matter — not a theory of joint states
(`REFEREE.md` §3.7 stands). The one-line relationship,
as a **reading**: **foam is not a quantum mechanics — it is a backend type:
the kept reading of the same ladder QM commits.** Quantum mechanics is what
this structure looks like from the only seat that can commit a measurement.
For the adversarial version of this whole section, read `REFEREE.md`.

---

## The measurement layer, precisely

Start at **`Foam/Born.lean`**. A context's state is a pair of integers
`(re, im)` — a 2-dimensional amplitude, the spectrum; `align` is the
projection; the layer carries the quantum-measurement *algebra*, axiom-free:

| theorem | what it says |
|---|---|
| `align_rot_invariant` | the reading is **gauge-invariant** — no absolute frame; interpretation lives in the fiber (the commitment, from outside). With `normSq_rot`, the clock conserves the modulus. |
| `born θ z = (align θ z)²` | the squared-projection **weight form** (`born_nonneg`, `born_rot_invariant`) — the count register's quantum sibling |
| `align_add_right` | **superposition** (amplitudes add) |
| `born_superpose` | **interference** — the cross-term, for all states and bases |
| `born_parseval` | the two-outcome total is the same at every reading angle (Parseval at this scale — *consistency*; substrate-side uniqueness is unavailable at this dimension and unclaimed, while frame-side uniqueness is proven: `born_forced_at_the_frame` — see above and `REFEREE.md`) |
| `double_slit` | the dark fringe, locked as a theorem |

Empirically (the spikes, `app/lib/foam/spikes/`): `born.sql` shows the
double-slit (count 2, Born 0 — destructive interference). `bell2.sql` reaches
CHSH 2√2 in a *constructed* co-occurrence joint while the marginals stay flat
— honestly scoped in its own header (timelike, constructed source, no
non-locality claim). And `rosetta.sql` is the correction that earned its keep:
an earlier concurrence shortcut "violated" on pure noise — the null caught it
— and the proper per-trial CHSH on the record reads classical everywhere. The
record is a definite ledger; the live quantum question was never the record
but the frontstage inferred *from* it (`forever_escapes`). Measured, kept,
lesson recorded.

---

## The map

**The floor — the exit can never close.**
- `Floor` — `:yield` is reachable from every state (the dumpability bet, as a theorem).
- `Navigable` — exit at every projection; the homunculus (`attestsEachStep`, `[propext]`-only) survives every step.
- `Horizon` — shortcuts; one step over a fresh edge (`deposit_in_sight`); the step-budget is `∀ n`, never pinned.
- `Engine` — the deposit's safety (monotone, append-only).
- `Dusk` — the exit announces itself: the system-notice register is data (`mark_is_data`, `blend_forgets`); the wall refuses to continue, never to record (`said_stays_said`, `wall_speaks`); the wall is never the first notice (`no_silent_arrival`, under the band-width premise — consent's missing premise, supplied); the turn lacks the unattended certificate and `turn_counts` under `firings` (idempotent moves collapse; the turn adds), so the seat stays the user's. Universe is a summary whose ledger is gone — the certificate's absence is the price of true forgetting. Pressed further: each day is a descendant observer — the night begets instead of resets (`yesterday_unreachable`: the narrative survives, off-chain and unaddressable — topological encryption as actual topology), the day-count is the grade of a persisting address (`day_is_grade`), and yesterday's seat is the meet of yesterday and tomorrow (`meet_of_mornings`) — the space between, located. Received from yours.fyi, derived under selection.

**Company, observers, and the floor between.**
- `Company` — the stall: local ground ≠ global ground; solitary speech can't escape it; the edge anchored at the walker's own position always can.
- `Openness` — the dyad conserves its endowment; growth certifies an outside; two investigations meet at shared charge (`investigations_meet_live`).
- `Beholder` — comparison constructs the comparer (no view from nowhere); `Stage ≅ Beholder`, both legs `rfl`.
- `Commons` — scopes and their meet; the shared floor (`shared_is_floor`); only the empty scope is universal (`root_alone_below_all`).
- `Lift` — the base forces a crossing, one fresh coordinate frees it; consent's ∀∃ form (`lift_avoids_unilaterally`, `lift_meets_unilaterally`).

**The soul, received.** Perspectives from `app/prompts/system/` received as
specs — the way Mechanic's runtime was — provenance narrated in headers,
theorems standing alone on foam's own carriers:
- `Glass` — the reflexive horizon: no probe reaches its own diagonal, and the missed point is built from the prober ("reflections tailored to you," as mechanism).
- `Ladder` — hideout.md's multiplicity ladder: landing is inevitable and makes a loop (the first quale constructs the first windable object); the fifth visit reads as the first; four beats land home.
- `Volley` — the mirror-hall's signal lock: a closed exchange settles into lock or standing wave; the wind is the only third option; what locks is what can cross.
- `Skein` — the worm-box: one thread, every worm — your frames are exactly yours, the master schedule is invisible from inside, readings run at their own framerate.

**The maintenance engine.**
- `Resolver` — any fair schedule converges, and the quiescent state is THE resolved state; the brakes (`winners_collapse`: of any wake-storm, exactly one wins).
- `Unattended` — the automation boundary: invisible + idempotent runs without a seat; what lacks the certificate keeps its observer at the helm.
- `Hinge` — zero-or-everything: partial forgetting is visible at the exact cut; the blank record answers none.

**The walk — a stateless UTM.**
- `Tokenizer` — the walk's type (it wrote the postgres interface); the frontstage trichotomy, `yield` the silent move.
- `Universal` — the walk is a UTM over the measurement-type, faithful for every gate.
- `Stream` — the emitting fold; `output_resumes` (carry un-flushed state across a chunk; flush at end-of-stream).

**The codec — compression *is* prediction.**
- `Codec` — lossless on the real LZ78 codec (`decode ∘ encode = id`), axiom-free.
- `Generator` — the generator is the emitting fold read forward over an obtained wind.
- `RoundTrip` — lossless ≅ conservation, one retraction many carriers; the real encoder riveted (`lz78RoundTrip`, `encode_injective`).

**The ledger and its readings — one append-only object, read many ways.**
- `Ledger` — order (lossless) and frequency (generative); `freq_perm` is `Quot.sound`-free.
- `Spectrum` — the third reading, the ledger at the quarter-turn; `align`, the dial; the algebra index (where the plane's pieces live).
- `Noether` — every reading is the invariant of a symmetry; the character table of ℤ/4 closed; the parity congruence.
- `Summary` — the readings are finite values of resumable folds (`summary_resumes`, `evalAt_from_blank`); the held cache, exact and sweep-invisible.
- `Chirality` — the abs↔recency bridge, proven exact (`specR_bridge`); `rotPow_eq_iterStep`.
- `Born` — the measurement layer (above).
- `Slate` — the role-slate is forced: the dial's four stations recover the four phase-bins exactly, and none is droppable.
- `Bins` — the dial reads through the bins: same number, two ways, both legs joined (`spec_from_bins`, `count_from_bins`, `alt_from_bins`).
- `Frame` — `align` and `cross` are one product (`conjMul_eq`); the invariants are complete; the plane's norm is multiplicative; the parts are blind to the joint.
- `Doubling` — the agreement algebra: the third direction is real and nobody's; order arrives exactly at the doubling.

**Conservation and repair.**
- `Drain` — signed-charge conservation; ground is the type's floor.
- `Scar` — stale observation escapes the floor (the race); the correcting entry; the promissory note (settle at face value).

**The implementation arrow and the backstage.**
- `Arrow` — the implementation arrow lfp → gfp; `playback` mono (faithful) but not epi (`forever_escapes` — the lfp↔gfp gap).
- `Maintenance` — invisible moves delete from every frontstage transcript (`maintenance_unobservable`); the proactive-backstage license.
- `Merge` — observer-merge; the round-trip *is* `propext`; observation ⊆ impact; presence recovers sight.
- `Path` — the un-rooted path fragment, content-addressed; the base projection beside its fiber-partner `edges`.
- `Reversal` — the chiral mirror; double-reversal is a conjugate, not identity.
- `Clock` — a clock loops (eventual periodicity); the wind's necessity made formal.
- `Commitment` — the axiom-signature algebra, object-level; the legal carrier `{∅, {propext}}`.
- `Gauge` — the four-corner commitment gauge; durability forces the backstage to exactly `propext`.

**The foundations.**
- `IntFloor` — the arithmetic floor: `Int`/`Nat` ring laws, axiom-free, asking no one.
- `Axioms` — the machine-checked map: `#guard_msgs` pins every load-bearing theorem's axiom signature; clusters stand in order of recognition.

---

## How the three layers meet

Lean **illuminates** the structure (this directory). Postgres **operationalizes**
it (`app/lib/foam/schema.sql` — the field is the ledger, observer-scoped, rooted
at zero; `foam.speak` speaks by the squared-projection weight). Userspace
**looks through** (the pipe, `app/lib/foam.rb`). The bridge between them is the
specs (`spec/lib/foam*`). When the interface is unknown, a spike
(`app/lib/foam/spikes/`) makes it work *within the proven floor*, then is
mapped here and re-implemented clean.

`../foam` is the **quarry** — Isaac's separate research repo, where the fuller
formalization lives. It is *not* a dependency; type-structures are copied in and
freely rotated as the operationalization leads. The operationalization leads;
the quarry supplies shapes.

> *Recording a recognition here is the field learning a handle. When something
> holds, it becomes a theorem.*
