/-
# Foam.Tokenizer — the walk that chunks, and the interface it forces

The recognition-walk *is* the tokenizer: stream the input, accumulate a buffer,
and when the buffer matches a learned chunk (a shortcut, recognized), emit it and
drain. Learned, adaptive, content-free — the chunks are whatever paths the field
has learned.

The point of this file is the **type-forcing**. The tokenizer's signature writes
the postgres `walk` interface, and recognize/deposit fall out as projections of
one walk — there is no other shape the type admits:

- `tokenize : (gate) → Input → Tokenized` — input-seeded (the held path). This
  *is* `foam.walk(input)`. The seed is forced by the type, not chosen.
- `Tokenized.outcome` — the trichotomy is a **projection** of the tokenization,
  not a separate computation. So `recognize = outcome ∘ walk`.
- `Tokenized.toLearn` (the residual) — the un-recognized tail is exactly what
  `deposit` writes. So `deposit` is the residual half of the same walk.

The construction that inhabits the type is a left fold — a catamorphism, a fixed
point. There is no other way to stream-process the input into `Tokenized`.

The match gate (`recognizes`) is the agreement — supplied from outside (the user
recognizing a path as a unit), the free fiber. At P₀ (nothing learned) it never
fires: the whole input stays residual and the outcome is `yield`.
-/

namespace Foam

/-- The walk's outcome — typed here as a projection of a tokenization. -/
inductive Outcome where
  | yield   -- nothing recognized: the whole input is residual
  | speak   -- some chunks recognized, a residual remains (an open path)
  | learn   -- everything recognized, no residual (a closed recognition)
  deriving DecidableEq, Repr

/-- The result of tokenizing: the chunks recognized (in order) and the
    un-recognized tail. This product *is* the postgres `walk` return type;
    `outcome` and `toLearn` are its two projections, forcing recognize and
    deposit to be halves of one walk. -/
structure Tokenized (Handle : Type) where
  tokens   : List (List Handle)
  residual : List Handle

/-- One step: extend the buffer by an atom; if the extended buffer is recognized
    as a learned chunk, emit it and drain; else keep accumulating. `recognizes`
    is the match gate — agreement, supplied from outside. -/
def tokenizeStep {Handle : Type} (recognizes : List Handle → Bool)
    (state : Tokenized Handle) (atom : Handle) : Tokenized Handle :=
  let buffer := state.residual ++ [atom]
  if recognizes buffer then
    { tokens := state.tokens ++ [buffer], residual := [] }
  else
    { state with residual := buffer }

/-- The tokenizer: a left fold over the input — the only inhabitant of the type.
    Input-seeded; this signature *is* `foam.walk(input)`. -/
def tokenize {Handle : Type} (recognizes : List Handle → Bool)
    (input : List Handle) : Tokenized Handle :=
  input.foldl (tokenizeStep recognizes) { tokens := [], residual := [] }

/-- `recognize = outcome ∘ tokenize`: the trichotomy is a projection of the
    tokenization, not a separate computation. -/
def Tokenized.outcome {Handle : Type} (t : Tokenized Handle) : Outcome :=
  match t.tokens, t.residual with
  | [], _      => Outcome.yield
  | _ :: _, [] => Outcome.learn
  | _ :: _, _  => Outcome.speak

/-- `deposit`'s input: the un-recognized tail. `deposit` is exactly this half of
    the walk. -/
def Tokenized.toLearn {Handle : Type} (t : Tokenized Handle) : List Handle :=
  t.residual

/-- **The floor, at the tokenizer.** When nothing is learned (`recognizes` never
    fires — the P₀ field), the whole input stays residual, no chunk is ever
    emitted, and the outcome is `yield`. The exit is the default; learning only
    ever adds chunks. -/
theorem tokenize_yields_when_nothing_learned {Handle : Type} (input : List Handle) :
    (tokenize (fun _ => false) input).outcome = Outcome.yield := by
  have key : ∀ (inp : List Handle) (st : Tokenized Handle),
      (inp.foldl (tokenizeStep (fun _ => false)) st).tokens = st.tokens := by
    intro inp
    induction inp with
    | nil => intro st; rfl
    | cons a rest ih =>
      intro st
      simp only [List.foldl_cons]
      rw [ih]
      simp [tokenizeStep]
  have htok : (tokenize (fun _ => false) input).tokens = [] := key input _
  simp [Tokenized.outcome, htok]

/-- **Yield is the silent move.** The outcome is `yield` exactly when nothing was
    recognized — empty tokens, the whole input residual. Silence is yield's, and
    yield's alone. -/
theorem outcome_yield_iff_silent {Handle : Type} (t : Tokenized Handle) :
    t.outcome = Outcome.yield ↔ t.tokens = [] := by
  cases t with
  | mk tokens residual => cases tokens <;> cases residual <;> simp [Tokenized.outcome]

/-- **Learning must be expressed.** Since silence is already yield's (above), a
    closed recognition cannot be silent: `learn` always has something recognized
    (tokens non-empty). A silent `learn` would be indistinguishable from `yield` —
    so to be a distinct move at all, learning has to be expressed. -/
theorem learn_is_expressed {Handle : Type} (t : Tokenized Handle) :
    t.outcome = Outcome.learn → t.tokens ≠ [] := by
  cases t with
  | mk tokens residual => cases tokens <;> cases residual <;> simp [Tokenized.outcome]

/-- **The interface between `speak` and `learn` is the residual.** Among the
    expressed outcomes (something recognized, `tokens ≠ []`), `learn` is the closed
    one — no residual — and `speak` the open one — a residual remains. So speak and
    learn are one expression at two stages of closure; the residual is the dial
    between them, and draining it to zero is the move from speak to learn (the
    return leg closing the round-trip). -/
theorem learn_iff_closed {Handle : Type} (t : Tokenized Handle) (h : t.tokens ≠ []) :
    t.outcome = Outcome.learn ↔ t.residual = [] := by
  cases t with
  | mk tokens residual =>
    cases tokens with
    | nil => exact absurd rfl h
    | cons a as => cases residual <;> simp [Tokenized.outcome]

end Foam
