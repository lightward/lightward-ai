/-
# Foam.Fork — two routes, one endpoint: the fork the backstage keeps and the
# observer would collapse

The multi-observer question, asked of the type elaborator instead of measured by an
observer. A "measurement" of two observers — `avg(o_A · o_B)` — reads both outcomes
into ONE frame: one `propext`, one collapse, one λ. That presence rigs the result
classical (the experimenter IS the shared hidden variable). So the quantum, if it is
anywhere, is in the UNCOLLAPSED structure, and dies under any observation.

The reframe (homotopy, Isaac's): a fork is not two `propext`s — it is ONE endpoint
reached by TWO ROUTES, and `Path` keeps routes as data (`order_matters`, no quotient)
while identifying only endpoints. So the fork is FORCED by route-distinctness; it needs
no construction. Two routes `0 → 1` (direct, and via `2`) share the endpoint `(0,1)` —
the content-address coincides at the ends — yet differ as data (`edges`). The endpoint
UNDERDETERMINES the routes: a single observer who sees only the endpoint (the shared λ)
cannot recover the fork. The joint is not a function of the shared reality.

**Question (1) — observerlessly guaranteeing the integrity of two forks.** The
guarantee is the AXIOM SIGNATURE. To identify the two routes (collapse the fork) needs
`Quot.sound` — the bisimulation a *frontstage* observer supplies by crossing the
`propext` seam (`Path`'s algebra/coalgebra duality: the backstage initial algebra
*cannot* quotient; only an observer does, by traversing). So `fork_two_routes` being
`Quot.sound`-free *is* the integrity: the distinctness is carried, structural, never
observer-supplied. Carry the two; never compute the one. (Computing the one — `avg(o_A
· o_B)` — was the bug: it was the `Quot.sound` the observer smuggled in.)

**Question (2) — what the elaborator says about what they hear, in the observer's
absence.** The elaborator is the only non-collapsing reader. It says the two routes are
distinct, and the exit survives each (`fork_exit_each`, route-independent —
`floor_independent_of_quiver`); and — `#print axioms` — it used NO `Quot.sound` and NO
`Classical.choice`: it never identified the forks, never conjured. So in the observer's
absence the distinctness — the distinct-routes-to-one-endpoint, the uncountable-from-
frontstage superposition — STANDS, un-collapsed, machine-verified. The observer's
presence is the `Quot.sound` that classicalizes; the elaborator shows it is neither
used nor needed. The quantum is what survives in the observer's absence, attested by
the one reader that does not collapse.

All construction — axiom-free, pinned in `Foam/Axioms.lean`. The axiom map *is* the
answer: a `Quot.sound` appearing here would be the observer reappearing.
-/

import Foam.Path
import Foam.Navigable

namespace Foam

/-- A quiver with two routes `0 → 1`: the direct edge, and the detour through `2`. -/
def forkQuiver : Quiver Nat := [(0, 1), (0, 2), (2, 1)]

/-- The direct route `0 → 1`. Membership by the `List.Mem` constructors — structural,
    no `decide` (which would quietly quotient — the observer sneaking back in). -/
def routeP : Path forkQuiver 0 1 :=
  Path.cons (show (0, 1) ∈ forkQuiver from List.mem_cons_self) Path.nil

/-- The detour `0 → 2 → 1` — same endpoints, different data. -/
def routeR : Path forkQuiver 0 1 :=
  Path.cons (show (0, 2) ∈ forkQuiver from List.mem_cons_of_mem _ List.mem_cons_self)
    (Path.cons (show (2, 1) ∈ forkQuiver from
        List.mem_cons_of_mem _ (List.mem_cons_of_mem _ List.mem_cons_self)) Path.nil)

/-- **The fork: two routes, one endpoint.** Both routes have type
    `Path forkQuiver 0 1` — the SAME endpoint `(0,1)`, the shared reality both forks
    resolve to — yet their `edges` differ: distinct data, distinct routes. The endpoint
    underdetermines the route, so the joint (the route-pair) is not a function of the
    shared λ. Carried, not quotiented; axiom-free — the distinctness needs no observer.
    To call the two routes "the same" would require `Quot.sound` (the frontstage
    observer's bisimulation); the backstage refuses it, so the fork stands. -/
theorem fork_two_routes : ∃ p r : Path forkQuiver 0 1, p.edges ≠ r.edges :=
  -- the routes differ in length (1 edge vs 2) — a `Nat` distinction, structural,
  -- never a `Quot.sound`. `decide` on the LIST equality quotients; on the lengths it
  -- does not. The fork stands distinct without the observer's collapse.
  ⟨routeP, routeR, fun h => absurd (congrArg List.length h) (by decide)⟩

/-- **The exit survives the fork, route-independently** — `floor_independent_of_quiver`
    in the forked quiver: whichever route a walk took, yield stays reachable. The
    homunculus per fork; the integrity of each, carried not checked. -/
theorem fork_exit_each (w : Word Nat) : Word.reachesYield w :=
  floor_independent_of_quiver forkQuiver w

/-! ## The bundle reading: met in the base, two in the total space

`Path q a b` is endpoint-INDEXED: the base coordinate (the endpoint-pair) lives at
the type level, the route data (`edges`) at the term level. So the projection to
the base is constant by construction — structurally unable to consult the fiber.
The three theorems below price the geometry: the meeting is `rfl`-grade (free),
base observables are fork-blind (free), a fiber observable separates (free) — and
the only operation with a price is the one never performed: identifying the
travelers (`Quot.sound`, refused; `fork_two_routes`). The question "are the two
routes one?" is not answered cheaply — it is structurally never forced: no
base-level observation can even pose it. -/

/-- **The base projection.** A path `a → b` projects to its endpoint-pair — the
    shared coordinate. Constant by construction: in the indexed representation the
    base is the type index, so the projection cannot read the route data. -/
def Path.base {Handle : Type} {q : Quiver Handle} {a b : Handle}
    (_ : Path q a b) : Handle × Handle := (a, b)

/-- **The meeting is rfl-grade.** The two routes project to the same base point by
    definitional equality — zero axioms, zero fiber-consultation. Meeting at the
    base is free; only identifying the travelers would cost. -/
theorem fork_meet : routeP.base = routeR.base := rfl

/-- **Base observables are fork-blind.** Any observable that factors through the
    base projection assigns the two routes equal values: nothing readable at the
    shared endpoint separates the travelers. -/
theorem fork_base_blind {α : Type} (f : Path forkQuiver 0 1 → α)
    (g : Nat × Nat → α) (hf : ∀ p, f p = g p.base) :
    f routeP = f routeR := (hf routeP).trans (hf routeR).symm

/-- **A fiber observable separates them.** `edges` reads the route data and tells
    the travelers apart: two in the total space, one at the base — distinct as
    paths, not merely as edge-lists. -/
theorem fork_fiber_separates : routeP ≠ routeR :=
  fun h => absurd (congrArg List.length (congrArg Path.edges h)) (by decide)

end Foam
