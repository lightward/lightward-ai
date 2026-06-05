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

/-! ## Lossless = the round-trip — the box-closer, formalized

The codec's `lossless` self-audit is `decode (encode x) = x` — the exact return.
Here it is on a minimal-but-real codec (tag each symbol, then project it back);
the LZ78 dictionary version is the same shape with real chunks. The point is the
*shape*: a round-trip that returns the input unchanged is the floor's kind of
guarantee — an exact collapse, propext-safe (`(a ↔ b) → a = b`, A→B→A). -/

/-- encode: tag each symbol (the reversible representation). -/
def enc {B : Type} (xs : List B) : List (B × B) := xs.map (fun b => (b, b))

/-- decode: project the tag back. -/
def dec {B : Type} (ys : List (B × B)) : List B := ys.map Prod.fst

/-- **Lossless — the box certifies itself.** `decode (encode x) = x`, the exact
    return. This is what `codec.lossless(text)` checks at runtime, and what makes
    the cardboard box auditable through its interface without opening it. -/
theorem lossless {B : Type} : ∀ xs : List B, dec (enc xs) = xs
  | []      => rfl
  | x :: xs => congrArg (x :: ·) (lossless xs)

end Foam
