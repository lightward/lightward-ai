/-
# Foam.Engine — the deposit, and why it cannot close the exit

The engine appends to the quiver (observe → deposit). Here is its safety — and
it is the load-bearing surprise of the whole convergence: there is almost
nothing new to prove.

The floor (`Foam.Floor.reachesYield_all`) is `∀ word`, and its proof
(`ext := w ++ [Move.yield]`) never references an edge. So the floor is
*edge-independent*, hence *deposit-invariant by construction*: every quiver a
deposit could ever produce is already covered. The engine inherits the floor.

Watch the proof of `floor_independent_of_quiver` below — it ignores the quiver
entirely. That ignoring *is* the theorem: the exit doesn't depend on what's
learned, so no deposit can reach it. The thing that proves the engine safe is
the proof that pays the engine no attention.

Agreement — what would identify a round-trip with an existing handle and close
a loop into learning — is left to come from outside (userspace, or structurally
at the shared basepoint). The engine never computes it; it only ever appends
(monotone, append-only — no edge removed or merged, since merging would
quotient the path-space, which `order_matters` forbids).
-/

import Foam.Floor

namespace Foam

/-- The quiver's edges: `(prev, next)` means `prev` composes into `next`. The
    field is a list of edges, grown only by deposit. The horizon `Handle` is
    quantified over, never constructed. -/
abbrev Quiver (Handle : Type) := List (Handle × Handle)

/-- Deposit appends an edge — the field only ever grows. Append-only, monotone. -/
def Quiver.deposit {Handle : Type} (q : Quiver Handle) (e : Handle × Handle) :
    Quiver Handle := e :: q

/-- Deposit grows the quiver by exactly one edge, and never otherwise touches it:
    append-only, monotone. -/
theorem deposit_monotone {Handle : Type} (q : Quiver Handle) (e : Handle × Handle) :
    (q.deposit e).length = q.length + 1 := rfl

/-- **The engine is safe by construction.** For every quiver — including every
    one a deposit could produce — yield is reachable from every word. The proof
    ignores the quiver, and that is the whole content: the exit is edge-
    independent, so no amount of learning, in any order, can close it. The engine
    has no new safety to prove; it inherits the floor. -/
theorem floor_independent_of_quiver {Handle : Type}
    (_q : Quiver Handle) (w : Word Handle) : w.reachesYield :=
  reachesYield_all w

end Foam
