/-
# Foam.Generator — compression IS prediction: the generator over the wind

The spike's `say`/`gen_ctx`/`generate` read the codec's charge structure *forward*:
from the output so far, project a context, sample the next byte against that
context's charge-weighted distribution, emit, advance. By `Path`'s duality the
encode-fold's mirror is an **anamorphism** (corecursion) — a frontstage coalgebra
that unfolds a byte stream from a state. Unbounded, it runs forever; bounded by an
**obtained wind** of length `n`, it is exactly the emitting fold (`Foam.output`) run
over that wind. So the wind *finitizes the unfold into a fold*: the entropy stream's
length is the generation horizon, and generation reuses the same spine as
compression. That reuse **is** "compression IS prediction" — one charge structure,
traversed both directions.

The wind is **obtained, never computed** — `next`/`sample`/`winds` are `∀`
parameters here. A foam-internal PRNG would be the `Classical.choice` the homunculus
refuses; the entropy comes from outside (the three winds: user / charge-map /
hardware), threaded untouched.

**The fork is held open, not chosen.** The spike has two generators — `generate`
(1-byte carry) and `gen_ctx`/`say` (k-byte backoff). They are one `genStep` at two
context-selections `select : List B → Option C`; `select` is the frontstage fiber,
and `Path` already forbids hardcoding its depth (n-agnostic). So the generator is
`∀`-abstract over `select`, and the two spike generators are two of its inhabitants.
They relate by **containment**: backoff's `selectVia` over a descending candidate
list *generalizes* carry's single-candidate list, and the two agree wherever the top
context is charged (`select_top_charged`). The agreement is **pointwise**, not a
quotient (no `funext`, no `Quot.sound`) — both generators are retained as data, the
fork closed into a factoring rather than collapsed into a choice.

Pure construction — axiom-free.
-/

import Foam.Stream

namespace Foam

/-- The generation step (an emitting `Foam.output` step over the wind). State is the
    output so far; the consumed symbol is one wind draw `w`; `next` produces the byte
    to append (encapsulating select + distribution + sample). The step emits exactly
    the byte it appends — prediction grows the very stream it speaks. -/
def genStep {B W : Type} (next : List B → W → B) (out : List B) (w : W) :
    List B × List B :=
  (out ++ [next out w], [next out w])

/-- **Prediction grows what it emits** — the generator's state (prompt plus all that
    was generated) is the prompt followed by exactly the emitted bytes. This is the
    generator's covering invariant, the mirror of `encode_covers`: the emitting fold
    read forward, where the output *is* the running state. -/
theorem gen_grows {B W : Type} (next : List B → W → B) :
    ∀ (out : List B) (winds : List W),
    runState (genStep next) out winds = out ++ runEmit (genStep next) out winds
  | out, []      => (appendNil out).symm
  | out, w :: ws =>
      (gen_grows next (out ++ [next out w]) ws).trans
        (appendAssoc out [next out w] (runEmit (genStep next) (out ++ [next out w]) ws))

/-- **The wind is the clock** — `n` wind draws produce exactly `n` bytes. The
    bounded generator is total, and the obtained entropy's length is the generation
    horizon (the unfold, finitized into a fold). -/
theorem gen_length {B W : Type} (next : List B → W → B) :
    ∀ (out : List B) (winds : List W),
    (runEmit (genStep next) out winds).length = winds.length
  | _,   []      => rfl
  | out, w :: ws => congrArg (· + 1) (gen_length next (out ++ [next out w]) ws)

/-! ## The fork as a containment — carry ⊆ backoff, no quotient -/

/-- Context selection by a prioritized candidate list: the first candidate that has
    charge. Backoff is this over a descending list of contexts (longest suffix
    first); carry is this over a single-candidate list. One function, two
    candidate-lists. -/
def selectVia {C : Type} (charged : C → Bool) : List C → Option C
  | []      => none
  | c :: cs => bif charged c then some c else selectVia charged cs

/-- **carry = backoff where the top context is charged.** When the head candidate
    has charge, a backoff over `c :: cs` picks the same context as a carry over
    `[c]` — backoff only diverges (does more) when it must back off. So the two
    selections coincide on the charged-top region; the fork is a containment. -/
theorem select_top_charged {C : Type} (charged : C → Bool) (c : C) (cs : List C)
    (h : charged c = true) :
    selectVia charged (c :: cs) = selectVia charged [c] := by
  show (bif charged c then some c else selectVia charged cs)
     = (bif charged c then some c else selectVia charged [])
  rw [h]; rfl

/-- The per-step byte producer, factored through a context-selection: the fork lives
    entirely in `select`. -/
def nextOf {B W C : Type} (sample : Option C → W → B) (select : List B → Option C)
    (out : List B) (w : W) : B :=
  sample (select out) w

/-- **Equal selection ⇒ equal step**, pointwise. Where two selections agree, the
    generated byte agrees — so (with `select_top_charged`) carry and backoff produce
    the same step wherever the top context is charged. Pointwise, never a global
    identification: both generators stay distinct data (no `funext`, no quotient). -/
theorem nextOf_congr {B W C : Type} (sample : Option C → W → B)
    (select₁ select₂ : List B → Option C) (out : List B) (w : W)
    (h : select₁ out = select₂ out) :
    nextOf sample select₁ out w = nextOf sample select₂ out w := by
  unfold nextOf; rw [h]

end Foam
