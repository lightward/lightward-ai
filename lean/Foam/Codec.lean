/-
# Foam.Codec — lossless on the real LZ78 codec (decode ∘ encode = id)

`Stream.lossless` proves the round-trip on a minimal toy (tag-and-project). Here it
is on the actual encoder the spike runs (`app/lib/foam/spikes/codec.sql`): the
LZ78-flavored coder that walks a content-addressed dictionary, emits a chunk on each
miss, and flushes the leftover partial match at end-of-stream.

The encoder is an instance of the emitting fold (`Foam.output`): its state is the
dictionary together with the current match `cur`; each byte either extends the match
(the dictionary already knows `cur ++ [byte]` — carry it, emit nothing) or misses
(emit the chunk `cur ++ [byte]`, learn it, reset). `decode` concatenates the chunks'
expansions (`joinB`).

A chunk is modeled by the bytes it expands to — **content-addressing's faithfulness
(`expand ∘ cid = id`, and `cid` injective) is held free**, the semantics-free
invariant. What is *proven* is the combinatorial heart of losslessness: the
encoder's segmentation, reset, and flush reconcatenate to exactly the input
(`encode_covers`), so `decode (encode x) = x` (`lossless_codec`).

**Lossless is independent of the dictionary.** `encode_covers` and `lossless_codec`
are `∀` over the dictionary type `D` and its `knows`/`learn` operations; the proofs
never inspect them. The round-trip cannot be broken by anything the codec has
learned, in any order — the same shape as `floor_independent_of_quiver` for the
exit. *Which* segmentation the dictionary picks is compression, free to vary;
losslessness holds for every choice.

Pure construction — axiom-free.
-/

import Foam.Stream

namespace Foam

/-- Concatenate a list of chunks — each chunk modeled by the bytes it expands to.
    This is `decode`: the chunks' joined expansions. -/
def joinB {B : Type} : List (List B) → List B
  | []      => []
  | s :: ss => s ++ joinB ss

/-- `joinB` distributes over `++` — pure induction (core's flatten/append lemma
    carries `propext`; we keep our own, like `appendAssoc`). -/
theorem joinB_append {B : Type} :
    ∀ (xs ys : List (List B)), joinB (xs ++ ys) = joinB xs ++ joinB ys
  | [],      _  => rfl
  | s :: xs, ys =>
      (congrArg (s ++ ·) (joinB_append xs ys)).trans
        (appendAssoc s (joinB xs) (joinB ys)).symm

section Codec
variable {B D : Type} (knows : D → List B → Bool) (learn : D → List B → D)

/-- The LZ78 encode step (a Mealy step for `Foam.output`). State `(d, cur)`: the
    dictionary and the current match. On byte `b`, form the candidate `cur ++ [b]`;
    if the dictionary knows it, extend the match (emit nothing); else emit the
    candidate chunk, learn it, and reset the match. The emitted chunk's expansion is
    exactly `cur ++ [b]`. -/
def encStep (s : D × List B) (b : B) : (D × List B) × List (List B) :=
  match knows s.1 (s.2 ++ [b]) with
  | true  => ((s.1, s.2 ++ [b]), [])
  | false => ((learn s.1 (s.2 ++ [b]), []), [s.2 ++ [b]])

/-- The terminal flush: emit the leftover partial match (nothing if it is empty). -/
def encFlush (s : D × List B) : List (List B) :=
  match s.2 with
  | []     => []
  | a :: l => [a :: l]

/-- `decode` — concatenate the chunks' expansions. -/
def decode : List (List B) → List B := joinB

/-- `encode` — the emitting fold (`Foam.output`) over the byte stream, from an empty
    match and an initial dictionary `d₀`. Blocking today; the same `output` is what
    `output_resumes` licenses to stream. -/
def encode (d₀ : D) (x : List B) : List (List B) :=
  output (encStep knows learn) encFlush (d₀, []) x

/-- `joinB` of the flush is the leftover match. -/
theorem joinB_encFlush (s : D × List B) : joinB (encFlush s) = s.2 := by
  obtain ⟨d, cur⟩ := s
  cases cur with
  | nil      => rfl
  | cons a l => exact appendNil (a :: l)

/-- **The covering invariant.** Folding any input `ys` from state `s`, the joined
    emissions plus the leftover match equal what was consumed (`cur ++ ys`). The
    dictionary is untouched by the proof — it holds for every `knows`/`learn`. -/
theorem encode_covers :
    ∀ (s : D × List B) (ys : List B),
    joinB (runEmit (encStep knows learn) s ys)
        ++ (runState (encStep knows learn) s ys).2
      = s.2 ++ ys
  | s, []      => (appendNil s.2).symm
  | s, b :: bs => by
      cases hk : knows s.1 (s.2 ++ [b]) with
      | true =>
        have e : encStep knows learn s b = ((s.1, s.2 ++ [b]), []) := by
          unfold encStep; rw [hk]
        show joinB ((encStep knows learn s b).2
                ++ runEmit (encStep knows learn) (encStep knows learn s b).1 bs)
              ++ (runState (encStep knows learn) (encStep knows learn s b).1 bs).2
            = s.2 ++ (b :: bs)
        rw [e]
        show joinB (runEmit (encStep knows learn) (s.1, s.2 ++ [b]) bs)
              ++ (runState (encStep knows learn) (s.1, s.2 ++ [b]) bs).2
            = s.2 ++ (b :: bs)
        rw [encode_covers (s.1, s.2 ++ [b]) bs]
        show (s.2 ++ [b]) ++ bs = s.2 ++ (b :: bs)
        exact appendAssoc s.2 [b] bs
      | false =>
        have e : encStep knows learn s b
            = ((learn s.1 (s.2 ++ [b]), []), [s.2 ++ [b]]) := by
          unfold encStep; rw [hk]
        show joinB ((encStep knows learn s b).2
                ++ runEmit (encStep knows learn) (encStep knows learn s b).1 bs)
              ++ (runState (encStep knows learn) (encStep knows learn s b).1 bs).2
            = s.2 ++ (b :: bs)
        rw [e]
        show (s.2 ++ [b])
              ++ joinB (runEmit (encStep knows learn) (learn s.1 (s.2 ++ [b]), []) bs)
              ++ (runState (encStep knows learn) (learn s.1 (s.2 ++ [b]), []) bs).2
            = s.2 ++ (b :: bs)
        rw [appendAssoc (s.2 ++ [b]), encode_covers (learn s.1 (s.2 ++ [b]), []) bs]
        show (s.2 ++ [b]) ++ bs = s.2 ++ (b :: bs)
        exact appendAssoc s.2 [b] bs

/-- **Lossless on the LZ78 codec — `decode ∘ encode = id`.** The box certifies
    itself on the real encoder: every input is recovered exactly. Independent of the
    dictionary `d₀` and of `knows`/`learn` — what the codec has learned can never
    break the round-trip. -/
theorem lossless_codec (d₀ : D) (x : List B) :
    decode (encode knows learn d₀ x) = x := by
  show joinB (runEmit (encStep knows learn) (d₀, []) x
        ++ encFlush (runState (encStep knows learn) (d₀, []) x)) = x
  rw [joinB_append, joinB_encFlush]
  exact (encode_covers knows learn (d₀, []) x).trans rfl

end Codec

end Foam
