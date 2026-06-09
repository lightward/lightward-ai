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
axiom-free in `Foam.IntArith`, because core's equivalents carry `propext`.

---

## The headline: foam-measurement is the Born rule

Start at **`Foam/Born.lean`**. A context's state is a complex vector (per
symbol, an amplitude `(re, im)` — the spectrum); `align` is the real part of the
inner product; and the measurement layer is proven quantum-mechanical,
axiom-free:

| theorem | what it says |
|---|---|
| `align_rot_invariant` | the reading is **gauge-invariant** — no absolute frame; interpretation lives in the fiber (the commitment, from outside). With `normSq_rot`, the clock is unitary. |
| `born θ z = (align θ z)²` | the **Born measurement** `\|⟨θ\|z⟩\|²` (`born_nonneg`, `born_rot_invariant`) — the count register's quantum sibling |
| `align_add_right` | **superposition** (amplitudes add) |
| `born_superpose` | **interference** — the cross-term, for all states and bases |
| `born_parseval` | the **Born rule forced** — total probability basis-independent (the operational baby-Gleason: `\|ψ\|²` is the *only* consistent measure) |
| `double_slit` | the empirical dark fringe, locked as a theorem |

Empirically (the spikes, `app/lib/foam/spikes/`): `born.sql` shows the
double-slit (count 2, Born 0 — destructive interference); `bell.sql` reaches
CHSH 2.449 on a foam-derived 2-qubit state; `bell2.sql` reaches **CHSH 2√2**
(Tsirelson, maximal) in the *native* co-occurrence joint while the marginals
are flat — entanglement living in the order reading, invisible to the
frontstage. Honestly scoped (see those headers): a ψ-epistemic structure —
frontstage-quantum over a backstage definite record — not a claim of
loophole-free spacelike non-locality.

---

## The map

**The floor — the exit can never close.**
- `Floor` — `:yield` is reachable from every state (the dumpability bet, as a theorem).
- `Navigable` — exit at every projection; the homunculus (`attestsEachStep`, `[propext]`-only) survives every step.
- `Horizon` — shortcuts; the step-budget is `∀ n`, never pinned (the elastic horizon).
- `Engine` — the deposit's safety (monotone, append-only).

**The walk — a stateless UTM.**
- `Tokenizer` — the walk's type (it wrote the postgres interface); the frontstage trichotomy, `yield` the silent move.
- `Universal` — the walk is a UTM over the measurement-type, faithful for every gate.
- `Stream` — the emitting fold; `output_resumes` (carry un-flushed state across a chunk; flush at end-of-stream).

**The codec — compression *is* prediction.**
- `Codec` — lossless on the real LZ78 codec (`decode ∘ encode = id`), axiom-free.
- `Generator` — the generator is the emitting fold read forward over an obtained wind.
- `RoundTrip` — lossless ≅ conservation, one retraction two carriers.

**The ledger and its readings — one append-only object, read many ways.**
- `Ledger` — order (lossless) and frequency (generative); `freq_perm` is `Quot.sound`-free (the abelianization observed, never committed).
- `Spectrum` — the third reading, the ledger at the quarter-turn; `align`, the dial; the rest (the silent move inside an utterance).
- `Noether` — every reading is the invariant of a symmetry; the character table of ℤ/4 closed; the conserved modulus and the parity congruence (`bal ≡ alt mod 2`).
- `Summary` — the readings are finite values of resumable folds (`summary_resumes`); the held cache, exact and sweep-invisible.
- `Chirality` — the abs↔recency bridge, proven exact (`specR_bridge`); storage is write-once, the voice reads the present.
- `Born` — **the quantum-measurement layer** (above).

**Conservation and repair.**
- `Drain` — signed-charge conservation; ground is the type's floor.
- `Scar` — stale observation escapes the floor (the race); the correcting entry; the promissory note (settle at face value).

**The implementation arrow and the backstage.**
- `Arrow` — the implementation arrow lfp → gfp; `playback` mono (faithful) but not epi (`forever_escapes` — the elastic horizon is the lfp↔gfp gap).
- `Maintenance` — invisible moves delete from every frontstage transcript (`maintenance_unobservable`); the proactive-backstage license.
- `Merge` — observer-merge; the round-trip *is* `propext`; observation ⊆ impact.
- `Path` — the un-rooted path fragment, content-addressed, composing Merkle-style.
- `Reversal` — the chiral mirror; double-reversal is a conjugate, not identity.
- `Clock` — a clock loops (eventual periodicity); the wind's necessity made formal.
- `Commitment` — the axiom-signature algebra, object-level; the legal carrier `{∅, {propext}}`.
- `Gauge` — the four-corner commitment gauge; durability forces the backstage to exactly `propext`.

**The foundations.**
- `IntArith` — the axiom-free `Int`/`Nat` ring floor.
- `Axioms` — the machine-checked map: `#guard_msgs` pins every load-bearing theorem's axiom signature.

---

## How the three layers meet

Lean **illuminates** the structure (this directory). Postgres **operationalizes**
it (`app/lib/foam/schema.sql` — the field is the ledger; `foam.speak` now speaks
by the Born measurement). Userspace **looks through** (the pipe, `app/lib/foam.rb`).
The bridge between them is the specs (`spec/lib/foam*`). When the interface is
unknown, a spike (`app/lib/foam/spikes/`) makes it work *within the proven floor*,
then is mapped here and re-implemented clean.

`../foam` is the **quarry** — Isaac's separate research repo, where the fuller
formalization lives. It is *not* a dependency; type-structures are copied in and
freely rotated as the operationalization leads. The operationalization leads;
the quarry supplies shapes.

> *Recording a recognition here is the field learning a handle. When something
> holds, it becomes a theorem.*
