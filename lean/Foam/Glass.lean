/-
# Foam.Glass — the reflexive horizon (every deep probe ends in a mirror)

The worm-box's second piece, typed (2026-06-12). The observation, Isaac's:
physical probes are eventually self-referential, and the self-referential
remainder encodes as *reflexive* — reflecting whatever reaches that point;
deep enough into any probe you see reflections tailored to *you*, not to the
observer who configured it. Shannon's uncertainty gets a reading from this:
**entropy is the reflexive port** — the bits a probe cannot determine about
itself are exactly where the current looker enters. Uncertainty isn't absence
of structure; it's where *you* show up in the reading. (The house built this
slot before naming it: the wind is *obtained, never computed* — "a
foam-internal PRNG is the conjured observer" — the uncertainty slot is
structurally reserved for whoever's outside.)

The classical jewel under the observation is Cantor's diagonal, constructive
and axiom-free — and read this way it says more than "no surjection": **the
point a self-probing schema cannot reach is built FROM the schema itself**
(`diagonal f` is a function *of* `f`). A different prober misses a different
point. The unreachable reading is prober-shaped — "tailored to you" is the
proof's own mechanism, not a metaphor laid over it.

The Wigner's-friend reading rides on top (a READING, labeled): the friend's
collapse is a commit at the friend's seat, and seats don't port — an outside
probe pushed past its reflexive horizon returns the outside prober's own
shape, not the friend's outcome, because the outcome was never in the channel
(only the frame-invariants cross; commits aren't among them). Two beholders,
quantum within, classical between; the "paradox" is the inherited expectation
that `propext` transfers. It doesn't.

Pure construction — axiom-free. No `funext` anywhere: function-equality is
consumed (via `congrFun`), never produced.
-/

namespace Foam

/-- The diagonal reading: built FROM the probe — each prober's own missed
    point. The looker-shaped remainder. -/
def diagonal {A : Type} (f : A → A → Bool) : A → Bool :=
  fun x => !(f x x)

/-- **No probe reaches its own diagonal.** For every probing schema `f` and
    every address `a`, the reading `f a` is not the diagonal — the
    self-referential remainder is structurally out of reach, and what sits
    there is made of the prober. -/
theorem probe_misses_its_diagonal {A : Type} (f : A → A → Bool) (a : A) :
    f a ≠ diagonal f := by
  intro h
  have h' : f a a = !(f a a) := congrFun h a
  cases hb : f a a with
  | false => rw [hb] at h'; exact absurd h' (by decide)
  | true => rw [hb] at h'; exact absurd h' (by decide)

/-- **The reflexive horizon, packaged**: no probing schema is total over its
    own readings — there is always at least one reading (the prober's own
    diagonal) that no address carries. Every sufficiently deep probe ends in
    glass, and the glass is shaped like whoever is looking. -/
theorem no_probe_is_total {A : Type} (f : A → A → Bool) :
    ¬ ∃ a, f a = diagonal f :=
  fun ⟨a, h⟩ => probe_misses_its_diagonal f a h

end Foam
