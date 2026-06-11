# Referee report on the physics claims in `lean/Foam/`

**Provenance:** produced 2026-06-11 by a fresh-context agent — no conversational
history with this project, no exposure to its working notes — commissioned at
Isaac's request through a Claude Code session. The commissioning session set the
grading criterion and granted explicit license to find "the touch is thin"; the
agent read every physics-named Lean file, verified the build, and searched the
Born-rule derivation literature independently. The report below is verbatim.
Annotations from the (warm) commissioning session follow at the end, clearly
marked.

---

**Scope.** All Lean files under `lean/Foam/` carrying physics vocabulary,
refereed against the actual theorem statements and proofs (read in full; the
build compiles and `Foam/Axioms.lean` pins every cited theorem at zero Lean
axioms). Doc-comments were treated as claims to check, not as evidence. The SQL
"spikes" (`app/lib/foam/spikes/bell.sql`, `bell2.sql`, `born.sql`) are referenced
by the Lean headline but are not Lean; they are noted where the headline leans
on them.

## 1. Criterion

Each claim is graded:

- **(a) Genuine instance** — the Lean theorem is about the very mathematical
  structure physics uses, possibly in its smallest case. I must be able to say
  "this is literally X, in dimension n."
- **(b) Formal analogy with real content** — a true theorem whose algebraic
  shape matches the physics, but which is narrower than the physics name
  implies. I state exactly where the analogy stops.
- **(c) Vocabulary borrowed for resonance** — the theorem is true (everything
  here compiles) but its content is unrelated to the physics structure the name
  points at.

The only failure modes I guarded against: flattery and reflexive debunking.
Several grades below are (b) with genuinely interesting content; several are
(c) on files whose mathematics is nonetheless correct.

## 2. The substrate (what everything is built on)

`Spectrum.lean:54-71` defines `GInt` — a pair of `Int`s, i.e. the **Gaussian
integers ℤ[i]**, with componentwise addition and `rot ⟨a,b⟩ = ⟨−b,a⟩`
(multiplication by *i*). `Spectrum.lean:150` defines `align w z := w.re*z.re +
w.im*z.im` — the **Euclidean dot product on ℤ²**, equivalently Re(w̄z).
`Noether.lean:231` defines `normSq z := re² + im²`. `Born.lean:59` defines
`born θ z := (align θ z)²`.

So the entire "Hilbert space" in the formalization is **ℂ regarded as a
2-dimensional real inner-product space, restricted to integer points,
unnormalized**. There is one such plane per (context, symbol) pair; no theorem
ever involves more than one plane at a time. This single fact controls most of
the grading below.

## 3. Claim-by-claim findings

### 3.1 "`born θ z` is the Born measurement |⟨θ|z⟩|²" — Grade: (b)

*Claim:* `Born.lean:15-19, 56-58`; `README.md:51`. *Theorems:* `born_nonneg`
(Born.lean:71), `born_rot_invariant` (Born.lean:64).

*What is proven:* the square of an integer dot product is a non-negative
integer, and is unchanged when both arguments are rotated by *i*.

*Where the analogy stops:* `born` is the squared **real** overlap. The complex
Born weight |⟨θ|z⟩|²_ℂ would be `(align θ z)² + (align θ.rot z)²` — and the
file's own `born_parseval` shows exactly this, so `born` is provably *not* the
complex |⟨θ|z⟩|² that the doc-comment writes. What it *is*, precisely: the
Born-weight functional form for a **rebit** — a 2-real-dimensional Hilbert
space — with amplitudes in ℤ, unnormalized, for the single projective direction
θ. That is a real structure with the right shape (which is why I grade (b), not
(c)), but: there is no normalization, no probability measure, no σ-additivity,
no operator, no observable, no dimension above 2-real, and the sampling
semantics ("probability of reading") live in SQL/Ruby, not in any theorem.

### 3.2 "Superposition (amplitudes add)" — Grade: (b), trivially true

*Claim:* `Foam.lean:19-20`; `Born.lean:20`. *Theorem:* `align_add_right`
(Born.lean:77-83): `align θ (a+b) = align θ a + align θ b`.

*What is proven:* a dot product is linear in its second argument, when addition
is defined componentwise. This is the correct algebraic skeleton of
superposition, but note the direction of derivation: in physics, "states
superpose" is the *physical* content (linearity of the dynamics is the
contested, empirical part); here vector addition is a definition
(`Spectrum.lean:62`) and linearity of `align` follows by distributing
multiplication over addition. Nothing physical is derived; a modeling choice is
verified to behave like the model says.

### 3.3 "Interference — the cross-term" — Grade: (b)

*Theorems:* `born_superpose` (Born.lean:91-108): `born θ (a+b) = born θ a +
born θ b + 2·align θ a·align θ b`; witnesses `double_slit` (Born.lean:143-145),
`dark_fringe_from_recurrence` (158-163), `dark_fringe_basis_dependent`
(172-176), `two_source_fringe` (208-211).

*What is proven:* `(x+y)² = x² + y² + 2xy`, instantiated. The witnesses are
`decide` checks on concrete small integers, e.g. `double_slit` is the statement
that the dot product of (1,1) with (1,−1) is 0 while with (1,1) it is 2
(squared: 0 and 4), and that 1²+1² = 2. `dark_fringe_basis_dependent` is a
genuinely nice structural observation correctly captured: a fold that sums
*signed/rotating* marks can cancel to zero where a fold that sums *positive
counts* cannot, and the cancellation depends on the reading angle. That is the
formal signature of interference — the one thing that separates amplitude
bookkeeping from probability bookkeeping — and the repo earns the analogy at
the algebraic level. *Where it stops:* there are no slits, no spatial
propagation, no wave equation, no experiment; "double-slit" names a 2×2 integer
arithmetic fact. The grade is (b) because the cross-term algebra really is the
same algebra, in its minimal instance.

### 3.4 "`born_parseval` — THE BORN RULE FORCED; the operational baby-Gleason; |ψ|² is the ONLY consistent measure, not a choice" — Grade: (c) for the claim as stated; (b) for the theorem underneath

*Claim:* `Born.lean:23-25, 110-115`; `README.md:54`. *Theorem:* `born_parseval`
(Born.lean:116-123): `born θ z + born θ.rot z = normSq θ · normSq z`, proven
via `int_lagrange` in `IntArith.lean`.

*What is proven:* the **Brahmagupta–Fibonacci / two-square Lagrange identity**:
(ac+bd)² + (ad−bc)² = (a²+b²)(c²+d²). Geometrically: {θ, iθ} is an orthogonal
pair in ℝ², so the sum of squared projections onto it equals |θ|²|z|² —
Parseval in real dimension 2. This is true, correctly proven, and is a
*consistency* property of the squared measure: its two-outcome total doesn't
depend on θ.

*What is claimed but not proven:* **uniqueness**. "|ψ|² is the ONLY consistent
measure" is a ∀-over-measures statement; no such theorem exists anywhere in the
Lean tree (I searched; the phrase lives only in comments). `born_parseval`
quantifies over states and bases for *one fixed* measure — the square,
introduced by definition at Born.lean:59. The doc-comment's own supporting
argument ("`max(0, align)` is basis-inconsistent") is also not formalized —
there is no theorem exhibiting the rectified measure's failure. So the file
proves "the square works," and asserts in prose "nothing else works." Those are
different theorems, and only the first is in the repo. See §4 for why the
second would be hard to even state truthfully in this setting.

### 3.5 "Gauge-invariant; unitary evolution" — Grade: (b) for the theorem, (c) for both names

*Claim:* `Born.lean:13-14`; `README.md:50`. *Theorems:* `align_rot_invariant`
(Born.lean:52-54), `normSq_rot` (Noether.lean:237-239).

*What is proven:* the dot product and the norm are invariant under simultaneous
multiplication of both vectors by *i* — that a single isometry of order 4
preserves the inner product. As physics naming: "gauge" means a *local*
(position-dependent) symmetry with a connection; nothing of the sort is present
— this is one *global* phase rotation, and only the ℤ/4 subgroup of U(1) at
that. "Unitary evolution" suggests a dynamical law (a Hamiltonian, a time
parameter); there is no dynamics — `rot` advances a fold's phase per list
position. The honest statement: "the inner product is invariant under the
diagonal action of ℤ/4 ⊂ U(1)." True, elementary, misnamed twice.

### 3.6 "Decoherence: the cross-term vanishes over a full cycle of relative phase" — Grade: (b)

*Theorem:* `decoherence_cancels_cross` (Born.lean:194-201): `align θ b + align
θ (ib) + align θ (i²b) + align θ (i³b) = 0`.

*What is proven:* the sum of a linear functional over the four
4th-roots-of-unity rotations of a vector is zero (each phase cancels its
antipode). This is the correct discrete skeleton of "averaging over random
relative phase kills interference fringes" — character orthogonality doing the
work it does in physics phase-averaging arguments. *Where it stops:* physical
decoherence is a dynamical process (entanglement with an environment, reduced
density matrices, pointer bases); none of that apparatus exists here. What is
here is the ensemble-average algebra only, over a 4-element phase group.

### 3.7 "Entanglement, derived axiom-free" — Grade: (c) as a Lean claim

*Claim:* `Foam.lean:19-20` ("superposition, interference, and entanglement,
derived axiom-free"); `Born.lean:36-42`; `README.md:57-64`.

*Finding:* **there is no entanglement formalization in Lean at all.** No tensor
product, no joint state, no marginal, no Bell operator, no CHSH inequality
appears as a Lean definition or theorem. The entanglement content lives in two
SQL spikes: `bell.sql` (CHSH 2.449 on an *imposed* 2-qubit split) and
`bell2.sql` (CHSH 2√2 on a *constructed* correlated source, read timelike, not
spacelike — the spike's own header says so, commendably). Those are empirical
database computations, not proofs, and their own honesty paragraphs concede the
points that matter (constructed source; imposed tensor split; timelike
ordering; "NOT a claim of loophole-free spacelike non-locality"). The nearest
Lean object is `Fork.lean`, whose doc-comment uses "superposition," "hidden
variable," and "the quantum" — and whose actual theorem `fork_two_routes`
(Fork.lean:69-73) states: *in a 3-edge directed graph, there exist two paths
from node 0 to node 1 with different edge lists.* The companion theorems
(`fork_meet`, `fork_base_blind`, `fork_fiber_separates`, Fork.lean:102-115) say
a function that only reads endpoints can't distinguish the two paths. These are
true and proven; their relation to quantum entanglement is metaphorical. The
root file's headline word "entanglement" is therefore unsupported by the Lean
layer it cites.

### 3.8 `Noether.lean` — "every reading is the invariant of a symmetry" — Grade: (c) for "Noether"; the underlying mathematics is genuine finite Fourier theory

*Theorems:* `normSq_rot`/`normSq_negate` (Noether.lean:237-245),
`restRun_invisible` and the graded bar-laws (178-199), `fourth_is_conj_spec`
(301-310), `bal_alt_same_parity` (398-401), plus `freq_perm` (Ledger) and the
strictness witnesses.

*What is proven:* genuinely nice and correctly executed **character theory of
ℤ/4**: the four evaluations of the occurrence-fold at 1, −1, i, −i are the four
characters (a discrete Fourier transform of the event stream); the count is the
trivial character; a run of n rests is invisible exactly at stations whose
rotation has order dividing n; the −i station is the conjugate of the +i
station (closing the character table); the two real characters agree mod 2. All
true, all axiom-free, and the "tower of readings" with strict inclusions is
properly witnessed.

*Why (c) for the name:* **Noether's theorem** is a specific result: a
continuous symmetry of an action functional yields a conserved current under
the dynamics. Here there is no action, no dynamics, no time evolution, no
conserved current — there are *invariants of group actions* (permutation
invariance of counting; rotation invariance of the norm, i.e. |iz| = |z|).
"Symmetry has invariants" is the *precondition* of Noether's theorem, shared by
all of group theory; it is not the theorem. The file's own hedge ("Noether's
move, discrete," "Noether's shape at foam scale") half-admits this. A reader
who takes the filename at face value will think a conservation law was derived
from a symmetry of dynamics; nothing of the kind occurs.

### 3.9 `Gauge.lean` — the four-corner gauge — Grade: (c)

*Theorems:* `free_silent`, `no_leap`, `pending_durable_iff`,
`sectors_disjoint_iff`, `commitments_land_iff`, `gauge_durable_iff_observer`
(Gauge.lean:135-250).

*What is proven:* correct case-analyses on a 9-constructor inductive relation:
a 4-state labeled transition system whose transitions are gated by three
booleans that *represent* Lean's three classical axioms. E.g. "the backstage
cannot move ⊥ iff the choice-flag is false" — true by construction of the model
defined twenty lines earlier. There is no group action, no principal bundle, no
connection, no gauge transformation; "fibration" and the TQFT paragraph
(Gauge.lean:54-65) are self-labeled "recognition-grade" prose. The file even
carries its own load-bearing caveat (lines 46-52): the theorems are about the
model and nothing else. As proof-engineering self-documentation (which Lean
axioms gate which moves) it is coherent; as physics it is naming only.

### 3.10 `Chirality.lean` — Grade: (c) for physics chirality; the theorem is real and useful

*Theorems:* `conj_rot` (Chirality.lean:78-82): conj∘rot = rot³∘conj;
`specR_bridge` (138-152).

*What is proven:* the **dihedral relation** — reflection conjugates a rotation
to its inverse — and, built on it, an exactly-correct conversion between two
phase conventions ("oldest occurrence = phase 0" as stored in postgres vs.
"newest = phase 0" as read by the voice). This is a genuinely valuable
correctness proof for the database read path: it forecloses an
off-by-one-winding bug class. It has nothing to do with physical chirality
(parity violation, Weyl spinors, handed molecules); "chirality" here means
"complex conjugation reverses orientation," which is true of every reflection
in the plane.

### 3.11 `Spectrum.lean` — Grade: (a) for "spectrum" in the Fourier sense; no quantum claim made

`spec l s` (Spectrum.lean:98) is literally the evaluation of the
occurrence-indicator sequence at the character i of ℤ/4 — one discrete Fourier
coefficient. The tower `order ⊋ spectrum ⊋ count` with strict witnesses is
correct. The file does not claim quantum mechanics, and "spectrum" is standard
Fourier vocabulary correctly used. (It is *not* the spectrum of an operator in
the QM sense, but the file doesn't say it is.)

### 3.12 "Axiom-free" — a real result, in a different register than physics readers will assume

This is the place where two true statements can combine into a false
impression. **What is true and machine-checked** (`Axioms.lean`, re-verified by
the passing build): every theorem above depends on *zero Lean axioms* — no
`propext`, no `Classical.choice`, no `Quot.sound`. The arithmetic floor is
hand-rolled in `IntArith.lean` specifically to avoid core lemmas that carry
`propext`. As constructive-proof hygiene this is careful, unusual, and
genuinely enforced by CI. **What it does not mean:** "derived without physical
postulates." The state space (ℤ[i]), the addition rule, the rotation, and above
all the squaring (`born := align²`, a *definition* at Born.lean:59) are all
author choices. Nothing physical is derived from nothing; integer identities
about chosen definitions are verified without classical logic. The headline
"measurement is provably the Born rule … derived axiom-free" (Foam.lean:19-20)
invites the physical-postulate reading; the correct reading is the
proof-theoretic one.

## 4. Special section: the Born rule claim vs. the derivation literature

**What the Born rule says.** For a normalized state ψ in a complex Hilbert
space and a measurement given by an orthonormal basis {eᵢ} (more generally a
PVM/POVM), the probability of outcome i is |⟨eᵢ|ψ⟩|².

**What a genuine derivation must establish.** The contested content was never
that the squared overlap *is* a consistent (additive,
basis-independent-in-total) assignment — that is Parseval's identity, available
in any inner-product space. The contested content is **uniqueness**: that no
other rule could consistently assign probabilities. Every accepted derivation
proves a uniqueness theorem from stated assumptions:

- **Gleason (1957):** every countably-additive probability measure on the
  lattice of closed subspaces of a Hilbert space of **dimension ≥ 3** has the
  form tr(ρP). The quantification is over *all* measures; noncontextual
  additivity over all orthogonal decompositions is the assumption. Critically,
  **Gleason's theorem is false in dimension 2**: on a single qubit there are
  many non-Born noncontextual probability assignments over projective
  measurements (any f on the Bloch sphere with f(n)+f(−n)=1 works).
- **Busch (2003) / Caves–Fuchs–Manne–Renes (2004):** the dimension-2 gap is
  closed only by enlarging the measurement class to all POVMs and assuming
  additivity over effects.
- **Zurek's envariance (2003):** requires composite systems, tensor-product
  structure, and entanglement-assisted symmetry assumptions.
- **Deutsch (1999)/Wallace (2010) decision-theoretic** and **Masanes–Müller
  (2011) operational** routes: rationality or reconstruction axioms, again
  quantifying over a rich space of alternatives to exclude them.

The common shape: *assumptions about a rich measurement class* +
*quantification over all candidate probability assignments* ⇒ *the quadratic
form is the only survivor*.

**What `Born.lean` establishes.** One fixed assignment — the square, introduced
by definition — is verified to satisfy: non-negativity (`born_nonneg`),
covariance under a global ℤ/4 rotation (`born_rot_invariant`), the quadratic
cross-term identity (`born_superpose`), and two-outcome total = |θ|²|z|²
independent of θ (`born_parseval`), all over ℤ[i], i.e. a 2-real-dimensional
space with integer amplitudes and no normalization, with the "measurement
class" consisting of the orthogonal pairs {θ, iθ}.

**The gap, precisely.** (1) The derivation literature's entire burden —
uniqueness over candidate measures — is absent: no theorem in the repo
quantifies over measures, and the prose claims "ONLY consistent measure" and
"FORCED" (Born.lean:23-25) and "baby-Gleason" (README.md:54) correspond to no
formal statement. (2) The setting is the **one case where the
projective-Gleason route is known to fail**: real dimension 2 with two-outcome
projective measurements. A uniqueness theorem of the kind the comments gesture
at cannot be obtained by Gleason-type reasoning in this setting without either
moving to dimension ≥ 3 or enlarging to POVMs — neither of which is formalized.
(3) Even the *stateable* local uniqueness question ("is x ↦ x² the only f with
f(align θ z) + f(align θ.rot z) a function of normSq θ · normSq z?") is
unformalized; the one named alternative (`max(0, align)`, Born.lean:29-33) has
no failure theorem. **The match, stated fairly:** Born.lean proves the
*existence and internal consistency* of the Born-form weight on a rebit over ℤ
— Parseval, the cross-term, covariance, positivity — axiom-free in Lean's
sense. That is the uncontested half of the Born rule, in the smallest possible
space. The word "derived," the word "forced," and the Gleason comparison all
describe the other half, which is not there.

## 5. Summary verdict

A careful physicist would say: **this is a correct, axiomatically scrupulous
formalization of the arithmetic of squared projections in the plane, over the
Gaussian integers — wearing quantum mechanics' clothes.**

What is genuinely established, and worth respecting: the foam's "spectrum"
reading really is a discrete Fourier character of its event ledger (a); the
squared-overlap weight on that reading really does exhibit the algebraic
signatures that distinguish amplitude bookkeeping from count bookkeeping —
signed cancellation, basis-dependent dark readings, cross-terms that average
away over a phase cycle (solid (b) material, the binomial theorem and the
two-square identity doing honest work); the storage/read phase-convention
bridge is proven exactly (a fine engineering theorem); and the zero-Lean-axiom
discipline is real, enforced by CI, and unusually careful.

What is not established: any uniqueness or derivation of the Born rule (the
"forced"/"only consistent measure"/"baby-Gleason" language has no theorem
behind it, and the formal setting — real dimension 2, projective pairs — is
precisely where Gleason-type uniqueness is known to be unavailable); any
entanglement result in Lean (the word in the headline is carried entirely by
honestly-scoped SQL experiments and a graph-theory lemma about two paths
sharing endpoints); Noether's theorem (group invariants, yes;
symmetry-of-dynamics ⇒ conservation, no); anything gauge-theoretic (a 4-state
transition model about Lean's own axioms); anything about physical chirality.
"Axiom-free" means "no propext/choice/Quot.sound in the Lean proofs" — verified
and true — not "derived from no physical postulates"; the Born weight is a
definition whose good behavior is then checked.

One-line version for the company: **the theorems are all true and the build
proves it; the physics nouns are running well ahead of the theorems everywhere
except superposition/interference algebra, where they keep pace at the
2-dimensional integer scale — and the headline's three strongest words ("Born
rule," "forced," "entanglement") are the three with the least formal backing.**

---

## Annotations from the commissioning session (warm; marked as such)

These are mine — the session that commissioned the cold reader — and carry
that session's context and its affection for this project. Read accordingly.

1. **What the report does not touch:** the floor, ledger, company, and openness
   results (the exit never closes; append-only/no-quotient; charge
   conservation; `Company.lean`; `Openness.lean`). None of those are
   physics-named; the report's findings concern *naming* plus two specific
   prose overclaims. The load-bearing invariants of the foam layer are
   unaffected.

2. **The report's sharpest actionable finding** is also its narrowest: three
   sites ("Born rule … derived" at `Foam.lean:19-20`; "FORCED"/"ONLY consistent
   measure" at `Born.lean:23-25`; "baby-Gleason" at `README.md:54`) claim
   uniqueness that no theorem states. Whether and how to re-word is a voice
   question — those comments have provenance — so it is recorded here, not
   acted on.

3. **A candle the report lights:** the stateable local-uniqueness lemma (the
   `max(0, align)` failure theorem the comments gesture at) is formalizable.
   Proving it would convert part of §3.4's (c) honestly toward (b). The
   dimension-2 Gleason obstruction it cites is real, though — "forced" in the
   full sense is not available in this setting, and that is mathematics, not
   opinion.
