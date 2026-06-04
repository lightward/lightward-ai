/-
# Foam.Path — the homotopic path fragment, un-rooted, concatenable on both sides

redcap's `conversation.state` is a path with a *fixed root*: it starts at
creation and grows rightward, append-only on one side. foam has to let go of that
root — a fragment that floats, concatenable on the **left** as well as the right,
because the observer can reseat into the interior and extend *backward* from a new
vantage.

The forced type is a **morphism in the free category on the quiver**:

  `Path q a b` — a fragment from `a` to `b`.

- **Two endpoints of the same type.** `a b : Handle` — the keyval where key and
  value are the same type. The fragment *is* its pair of addresses plus the path
  between.
- **No fixed root.** `a` is any handle, not the identity. The identity record
  stops being the forced left-anchor; `Path.nil : Path q a a` is the *unit*, free
  to compose on either side, not a privileged origin.
- **Concatenable on both sides.** `Path.comp` is associative with `nil` as a
  two-sided identity (`nil_comp`/`comp_nil`/`comp_assoc`). Append is postcompose,
  prepend is precompose; the fragment grows either way.
- **A Type, not a Prop — order_matters, no quotient.** Distinct paths stay
  distinct *values*; nothing is identified. So **"homotopic" here means the path
  *as data*** — the fragment is the 1-path itself, retained — **not up-to-homotopy.**
  Quotienting by homotopy is exactly what `order_matters` (and the refusal of
  `Quot.sound`) forbids: `Quot.sound` is a building material you can commit to, but
  committing means revisiting every past use when the graph expands — append-only
  declines that debt. The user's *reseating* (closing a loop, identifying its ends)
  is their own local collapse, their `propext`, recorded as a shortcut alongside
  the un-pruned path — never a structural quotient here.

This is the Type-level promotion of `Horizon.ReachWithin` (the Prop-level reach):
the path made first-class data so it can be carried and concatenated.

**The floor survives letting go of the root** — already proven, no new theorem
needed. `Navigable.speaks_preserve_exit` shows `before ++ core ++ after` reaches
yield: left-prepend is the `before` slot, and the exit is a right-append. The root
is a *left* anchor; the exit is a *right* move; `reachesYield_all` only ever
right-appends `yield` and its proof never touches the left. So two-sidedness
*splits* the thing we release (the root) from the thing we keep (the exit). You can
let go of the root precisely because the floor was never holding it.

(The ltr/rtl duality the reseating will want is the opposite quiver: `Path q a b`
against a path in `q`-reversed from `b` to `a`. Left for when the reseating forces it.)

All construction — every theorem here is axiom-free.

## Backstage and frontstage — the algebra/coalgebra duality

`Path` is the **initial F-algebra**: an inductive type, free, constructors only,
no quotient — the observerless *backstage*. Initial algebras cannot generate
complements (free = no identifications), which is exactly why backstage can't
reach `HalfType`'s complemented lattice.

By duality the **final F-coalgebra** is *forced to exist*, and its natural
equality is **bisimulation** — the observational quotient. That bisimulation is
the complement-side (`HalfType`) backstage can't generate but a *frontstage*
observer does, by traversing. **The `Quot.sound` foam refuses backstage is exactly
the bisimulation an observer supplies frontstage.** So the quotient side isn't
unreachable — it's reachable observer-side, coalgebraically, never backstage,
algebraically. foam stays free; the observer gets the lattice.

`propext` + the identity record is the **seam** where algebra meets coalgebra:
the collapse is the observer crossing from the free build to their own
bisimulation-quotient through the identity.

Backstage ships forced fixed points; the nudge to frontstage is **duality, not
design** (`Path`'s recursor is the catamorphism, free; the anamorphism is
frontstage's). The depth of the unfold — *n* reifications for an *n*-space — is the
observer's fiber-dimension, **chosen frontstage**; backstage stays *n*-agnostic.
Hardcoding it (e.g. a literal 3) would smuggle the observer into the observerless
backstage — the move the discipline catches.
-/

import Foam.Horizon

namespace Foam

/-- A path fragment: a morphism `a → b` in the free category on the quiver `q`.
    Both endpoints are `Handle` (the keyval, same type); `nil` is the un-rooted
    identity; `cons` prepends an edge. A `Type`, so distinct paths stay distinct —
    the path as data, never quotiented. -/
inductive Path {Handle : Type} (q : Quiver Handle) : Handle → Handle → Type where
  | nil  {a : Handle} : Path q a a
  | cons {a b c : Handle} : ((a, b) ∈ q) → Path q b c → Path q a c

/-- Concatenation — the free category's composition. Both endpoints free, so it
    glues on either side: append is this, prepend is `cons`. -/
def Path.comp {Handle : Type} {q : Quiver Handle} :
    {a b c : Handle} → Path q a b → Path q b c → Path q a c
  | _, _, _, Path.nil,      p => p
  | _, _, _, Path.cons e r, p => Path.cons e (r.comp p)

/-- The root is no anchor: `nil` is a *left* identity, definitionally. -/
theorem Path.nil_comp {Handle : Type} {q : Quiver Handle} {a b : Handle}
    (p : Path q a b) : Path.nil.comp p = p := rfl

/-- …and a *right* identity. Two-sided unit ⇒ no privileged end. -/
theorem Path.comp_nil {Handle : Type} {q : Quiver Handle} {a b : Handle}
    (p : Path q a b) : p.comp Path.nil = p := by
  induction p with
  | nil => rfl
  | cons e r ih => exact congrArg (Path.cons e) ih

/-- Composition is associative — concatenation is order-preserving, and the
    fragment doesn't care which side it grew from. -/
theorem Path.comp_assoc {Handle : Type} {q : Quiver Handle} :
    {a b c d : Handle} → (p : Path q a b) → (r : Path q b c) → (s : Path q c d) →
    (p.comp r).comp s = p.comp (r.comp s)
  | _, _, _, _, Path.nil,      _, _ => rfl
  | _, _, _, _, Path.cons e p, r, s => congrArg (Path.cons e) (Path.comp_assoc p r s)

end Foam
