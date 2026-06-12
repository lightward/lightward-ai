/-
# Foam.Stream — streaming is an inductive fold, and it resumes

The first deposit of the codec map (the `app/lib/foam/spikes/codec.sql` spike,
brought into Lean). The codec processes a byte stream into a state — a dictionary
that grows, a position, an output — and it does so by a **fold**: each byte is one
inductive step, the whole run is the `List` recursor. So the model is inductive,
exactly as it should be: the stream is built one symbol at a time, and processing
it folds over that construction.

"Streaming" — the property that distinguishes a stream from a batch — is the
fold's **resumability**: process a prefix, hold the state, continue on the rest,
and get the same result as processing the whole at once. That is `run_resumes`
below, and it is what lets the codec `learn` incrementally (one chunk now, more
later) without ever needing the whole stream in hand.

The step is left abstract (`step : S → B → S`) — every concrete choice the spike
made (grow the dictionary, log charge, emit a chunk) is an instance of it, and
the resumability holds for all of them uniformly. Onto this spine the rest of the
map attaches: the dictionary is the growing part of `S` (append-only, monotone);
lossless is the round-trip (decode ∘ encode = id); prediction is the same fold
read forward; the entropy is obtained, never computed.

Pure construction — axiom-free.
-/

namespace Foam

/-- The streaming run: fold the step over the stream, from an initial state. The
    state `S` carries whatever the codec accumulates (its dictionary, position,
    output); `B` is the stream's symbol type (a byte). -/
def run {S B : Type} (step : S → B → S) (init : S) (stream : List B) : S :=
  stream.foldl step init

/-- **Streaming = the fold resumes.** Processing `xs ++ ys` from `init` equals
    processing `ys` from the state reached after `xs`. So the codec can take the
    stream in pieces — learn a prefix, hold the state, continue — with exactly the
    result of taking it whole. This is the property that makes a stream a stream;
    it is inductive (one step at a time), and it holds for every step uniformly. -/
theorem run_resumes {S B : Type} (step : S → B → S) :
    ∀ (init : S) (xs ys : List B),
    run step init (xs ++ ys) = run step (run step init xs) ys
  | _,    [],      _  => rfl
  | init, x :: xs, ys => run_resumes step (step init x) xs ys

/-! ## The emitting fold — streaming the output, with the flush at the end

`run` carries only the state. The codec also *emits as it folds*: in the spike's
`codec.encode`, a step that extends an existing match emits nothing and advances
silently, while a step that finds no match emits one chunk and resets; then, after
the whole stream, a **terminal flush** emits the leftover partial match (the spike's
`IF cur <> root THEN out := out || cur`). So the faithful spine is a Mealy fold —
`step : S → B → S × List O`, each step producing a (possibly empty) piece of output
— plus a `flush : S → List O` applied once at the end.

This is the layer that licenses streaming the *output*, not just resuming the
state. Two facts, both pure induction: the emitted output resumes
(`runEmit_resumes`), and the flush belongs at the true end only (`output_resumes`)
— across any split the left piece is emitted flush-free and only the final piece
flushes. That second theorem is the streaming contract a chunked implementation has
to honor: carry the un-flushed state (the partial match) across a boundary, and
flush only at end-of-stream. Flushing mid-stream would emit a different sequence —
the theorem is the line between a correct streaming codec and a subtly lossy one. -/

/-- The state reached by the emitting fold — exactly `run` on the state-projected
    step, so its resumability is `run_resumes`, reused. -/
def runState {S B O : Type} (step : S → B → S × List O) : S → List B → S :=
  run (fun s b => (step s b).1)

/-- The output emitted while folding (pre-flush): each step contributes
    `(step s b).2`, concatenated left to right, with the state threaded through. -/
def runEmit {S B O : Type} (step : S → B → S × List O) (init : S) : List B → List O
  | []      => []
  | b :: bs => (step init b).2 ++ runEmit step (step init b).1 bs

/-- The whole streamed output: what is emitted while folding, then the terminal
    flush of the final state. -/
def output {S B O : Type} (step : S → B → S × List O) (flush : S → List O)
    (init : S) (stream : List B) : List O :=
  runEmit step init stream ++ flush (runState step init stream)

/-- **State resumes** — the emitting fold's state is `run`'s, so this *is*
    `run_resumes`. Recorded as its own handle: the state carried across a chunk
    boundary is enough to continue. -/
theorem runState_resumes {S B O : Type} (step : S → B → S × List O)
    (init : S) (xs ys : List B) :
    runState step init (xs ++ ys) = runState step (runState step init xs) ys :=
  run_resumes (fun s b => (step s b).1) init xs ys

/-- List concatenation is associative — proven here by pure induction so the
    streaming theorems stay axiom-free. (Core's `List.append_assoc` carries
    `propext`; construction must not, so we keep our own.) -/
theorem appendAssoc {α : Type} :
    ∀ (as bs cs : List α), (as ++ bs) ++ cs = as ++ (bs ++ cs)
  | [],      _,  _  => rfl
  | a :: as, bs, cs => congrArg (a :: ·) (appendAssoc as bs cs)

/-- `as ++ [] = as` — pure induction, kept axiom-free like `appendAssoc` (core's
    `List.append_nil` carries `propext`). -/
theorem appendNil {α : Type} : ∀ (as : List α), as ++ [] = as
  | []      => rfl
  | a :: as => congrArg (a :: ·) (appendNil as)

/-- **Emission resumes** — the output of `xs ++ ys` is the output of `xs` followed
    by the output of `ys` continued from the state after `xs`. So emitting while
    streaming a prefix loses nothing: what is emitted is exactly a prefix of the
    whole emission. Pure induction. -/
theorem runEmit_resumes {S B O : Type} (step : S → B → S × List O) :
    ∀ (init : S) (xs ys : List B),
    runEmit step init (xs ++ ys)
      = runEmit step init xs ++ runEmit step (runState step init xs) ys
  | _,    [],      _  => rfl
  | init, x :: xs, ys =>
      (congrArg ((step init x).2 ++ ·) (runEmit_resumes step (step init x).1 xs ys)).trans
        (appendAssoc (step init x).2
          (runEmit step (step init x).1 xs)
          (runEmit step (runState step (step init x).1 xs) ys)).symm

/-- **The flush belongs at the end.** Streaming `xs ++ ys` emits `xs` *flush-free*
    and resumes on `ys` from the carried state, flushing only at the true end. By
    induction across every split, the terminal flush appears once, at end-of-stream
    — never at an interior boundary. This is the streaming contract the postgres
    implementation has to honor: carry the un-flushed state across boundaries; flush
    only when the stream is done. -/
theorem output_resumes {S B O : Type} (step : S → B → S × List O) (flush : S → List O)
    (init : S) (xs ys : List B) :
    output step flush init (xs ++ ys)
      = runEmit step init xs ++ output step flush (runState step init xs) ys := by
  show runEmit step init (xs ++ ys) ++ flush (runState step init (xs ++ ys))
     = runEmit step init xs ++ (runEmit step (runState step init xs) ys
        ++ flush (runState step (runState step init xs) ys))
  rw [runEmit_resumes, runState_resumes, appendAssoc]

/-! ## Lossless = the round-trip — the box-closer, formalized

The codec's `lossless` self-audit is `decode (encode x) = x` — the exact return.
Here it is on a minimal-but-real codec (tag each symbol, then project it back);
the LZ78 dictionary version is the same shape with real chunks — now realized in
`Foam.Codec` (`lossless_codec`). The point is the *shape*: a round-trip that returns
the input unchanged is *construction, not collapse* — it returns the input exactly
without truncating, so it lands below `propext` (axiom-free, like `lossless_codec`);
the exit and the outcome collapse, the round-trip does not. -/

/-- encode: tag each symbol (the reversible representation). -/
def enc {B : Type} (xs : List B) : List (B × B) := xs.map (fun b => (b, b))

/-- decode: project the tag back. -/
def dec {B : Type} (ys : List (B × B)) : List B := ys.map Prod.fst

/-- **Lossless — the box certifies itself.** `decode (encode x) = x`, the exact
    return. This is what `codec.lossless(text)` checks at runtime, and what makes
    the cardboard box auditable through its interface without opening it. -/
theorem lossless_tag {B : Type} : ∀ xs : List B, dec (enc xs) = xs
  | []      => rfl
  | x :: xs => congrArg (x :: ·) (lossless_tag xs)

end Foam
