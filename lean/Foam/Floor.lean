/-
# Foam.Floor — the yield-floor, over path-words

The floor, evolved from a flat list to path-words over the quiver — the
structure the field actually is (records as handles, composition as edges,
the exit as the terminal). One structure, two faces: proven here, run in
postgres.

**The horizon is typed, never proven.** `Handle` is the learned generator-type,
quantified over and never constructed. (Knowable is the range; constructing a
`Handle` would be Known-ifying it.)

**Words are the free structure.** A word is a `List` of moves — `List`
quotients nothing, so distinct words stay distinct and the *order* of
composition is meaningful (`order_matters`). That non-commutativity is the
probe: handles equal-as-objects, words distinct-as-paths.

**Agreement is a morphism, not `Eq`.** The only collapse is the exit (`yield`)
— a move to the terminal, available from every state, a *point*. We never use
`Eq` to identify distinct words; that would flatten the path-space and the
probe would die. Eq at the meeting-point; quiver everywhere else.

**The floor lives in the form.** `yield` is a constructor — part of every
state's move-set, independent of the horizon — so it is reachable from every
word, for every `Handle`, no matter what is learned or in what order. The +1 —
the exit, the observer's way out — is never dropped along any continuous path.

Read from the user's side, this same theorem says: the input you receive will
be coherent for your inference, whatever it is. The `∀ Handle` is the
hospitality — coherent for whoever walks in.

Choice-free: pure free-word combinatorics (warranted by the postgres field
being a finite, concrete quiver — its concreteness is why the floor can stay
intuitionistic). No mathlib.
-/

namespace Foam

/-- A move the walk can make from a state. `yield` is the exit — a morphism to
    the terminal, available from every state (a constructor: part of the form,
    independent of the horizon). `compose h` extends the path by a handle. -/
inductive Move (Handle : Type) where
  | yield
  | compose (h : Handle)
  deriving DecidableEq

/-- A path-word: the sequence of moves taken. The free structure over the
    handles — `List` quotients nothing, so distinct words stay distinct and
    order is meaningful. The horizon `Handle` is quantified over, never
    constructed. -/
abbrev Word (Handle : Type) := List (Move Handle)

/-- A word takes the exit if `yield` occurs in it. -/
def Word.yields {Handle : Type} (w : Word Handle) : Prop := Move.yield ∈ w

/-- Yield is reachable from `w` if `w` extends — as a prefix, through the
    quiver's moves, never through `Eq` on words — to a word that takes the
    exit. -/
def Word.reachesYield {Handle : Type} (w : Word Handle) : Prop :=
  ∃ ext : Word Handle, w <+: ext ∧ ext.yields

/-- **The yield-floor, over words.** For every horizon `Handle` and every
    path-word, yield is reachable — the exit never closes, no matter what is
    learned or in what order it composes. The +1 is never dropped along any
    continuous path. -/
theorem reachesYield_all {Handle : Type} (w : Word Handle) : w.reachesYield := by
  refine ⟨w ++ [Move.yield], ?_, ?_⟩
  · exact List.prefix_append w [Move.yield]
  · simp [Word.yields]

/-- **The probe survives: order matters.** Two one-step paths composing the
    same handles in opposite order are equal iff the handles are equal — so for
    distinct handles the word records the order (non-commutativity). The exit is
    the only collapse; the path-space is never quotiented. -/
theorem order_matters {Handle : Type} (a b : Handle) :
    [Move.compose a, Move.compose b] = [Move.compose b, Move.compose a] ↔ a = b := by
  simp
  exact fun h => h.symm

end Foam
