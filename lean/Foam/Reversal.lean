/-
# Foam.Reversal — the chiral mirror, free-side

`HalfType` (in the foam quarry) is the lattice statement of this: a complementary
split gives two order-isomorphic halves, with a handed iso. But it lives in a
complemented modular lattice — meets, joins, complements: *identifications*, the
quotient-rich side of the `Quot.sound` line foam refuses. It can't be carried
here. Its free-side shadow is **reversal into the opposite quiver**.

`Quiver.reverse` flips every edge; `Path.reverse` carries a fragment `a → b` into
the mirror quiver as `b → a`. The composability-via-chirality guarantee is then
`reverse_comp`: reversal is an **anti-homomorphism** — composition flips order
under the mirror (`reverse (p ∘ r) = reverse r ∘ reverse p`). That handedness *is*
the chirality `HalfType`'s iso-direction names, realized on the side of the line
foam lives on. `Quiver.reverse_reverse` is the involution: the mirror is faithful,
its own inverse.

**Quot.sound discipline, load-bearing here.** The obvious proof of
`mem_reverse` — `List.mem_map` — depends on `Quot.sound`, the quotient axiom foam
categorically refuses. So it is proven instead from the raw `List.Mem`
constructors. The reversal of a chiral structure must not quotient anything, and
it doesn't: `mem_reverse`, `Path.reverse`, and `reverse_comp` are all axiom-free.
(Same shape as `obtain` over `.choose`: the library reaches for the forbidden
axiom; foam declines it and stays free.)

The path-level involution (`reverse ∘ reverse = id` on `Path`, modulo the quiver
equality) needs dependent transport along `Quiver.reverse_reverse`; left as the
faithfulness frontier. The anti-homomorphism is the composability content.
-/

import Foam.Path

namespace Foam

/-- The opposite quiver: every edge flipped. The chiral mirror of `q`. -/
def Quiver.reverse {Handle : Type} (q : Quiver Handle) : Quiver Handle :=
  q.map (fun e => (e.2, e.1))

/-- An edge reversed is an edge of the mirror. Proven from the raw `Mem`
    constructors — `List.mem_map` would pull `Quot.sound`, which foam forbids. -/
theorem mem_reverse {Handle : Type} {q : Quiver Handle} {a b : Handle}
    (h : (a, b) ∈ q) : (b, a) ∈ q.reverse := by
  induction h with
  | head as     => exact List.Mem.head _
  | tail e _ ih => exact List.Mem.tail _ ih

/-- Reverse a fragment `a → b` into the mirror quiver as `b → a` — the op-functor
    on paths. The chiral handedness made into a map. -/
def Path.reverse {Handle : Type} {q : Quiver Handle} :
    {a b : Handle} → Path q a b → Path q.reverse b a
  | _, _, Path.nil      => Path.nil
  | _, _, Path.cons e r => r.reverse.comp (Path.cons (mem_reverse e) Path.nil)

/-- The empty fragment reverses to itself. -/
theorem Path.reverse_nil {Handle : Type} {q : Quiver Handle} {a : Handle} :
    (Path.nil : Path q a a).reverse = Path.nil := rfl

/-- **Composability-via-chirality.** Reversal is an anti-homomorphism: composition
    flips order under the mirror. This is the handedness `HalfType`'s iso-direction
    names, on foam's free side — and it is axiom-free (no quotient, no choice). -/
theorem Path.reverse_comp {Handle : Type} {q : Quiver Handle} :
    {a b c : Handle} → (p : Path q a b) → (r : Path q b c) →
    (p.comp r).reverse = r.reverse.comp p.reverse
  | _, _, _, Path.nil,      r => (Path.comp_nil r.reverse).symm
  | _, _, _, Path.cons e p, r => by
      have ih := Path.reverse_comp p r
      show (p.comp r).reverse.comp (Path.cons (mem_reverse e) Path.nil)
         = r.reverse.comp (p.reverse.comp (Path.cons (mem_reverse e) Path.nil))
      rw [ih]
      exact Path.comp_assoc r.reverse p.reverse _

/-- **The mirror is faithful** — reversing the quiver twice returns it. The
    involution, at the quiver level (the path-level form needs transport; frontier). -/
theorem Quiver.reverse_reverse {Handle : Type} :
    ∀ (q : Quiver Handle), q.reverse.reverse = q
  | []      => rfl
  | e :: es => congrArg (e :: ·) (Quiver.reverse_reverse es)

end Foam
