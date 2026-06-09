/-
# Foam — the formal mirror of the foam layer (`app/lib/foam*`)

The load-bearing functions of the foam layer are *illuminated* here and
*operationalized* in Ruby/SQL — the proofs design the floor; the operational
code inhabits it; userspace looks through. The horizon (what is *learned*) is
typed, never proven. See `lean/README.md` for the full map and the headline
results.

Core-only Lean (no mathlib), pinned to v4.29.0. `lake build` is seconds and
re-checks `Foam/Axioms.lean` — the machine-checked axiom map — so a drift in any
load-bearing theorem's axiom signature fails the build (CI runs it). The
discipline: **construction is axiom-free; collapse costs `propext` at exactly two
sites (the exit and the outcome); `Classical.choice` and `Quot.sound` never
appear** (carry the observer, never conjure it; append-only, never quotient).

What the mirror now holds, in one line: a learning substrate whose floor never
closes its exit, whose ledger is one append-only object read many ways, and
whose **measurement is provably the Born rule** — superposition, interference,
and entanglement, derived axiom-free (`Foam/Born.lean`).

`../foam` (Isaac's separate research repo) is the *quarry*, not a dependency —
type-structures are copied in and freely rotated as the operationalization
leads; the toolchain is pinned to match it so quarried types compile without
porting. The operationalization leads; the quarry supplies shapes.
-/

import Foam.Floor
import Foam.Engine
import Foam.Horizon
import Foam.Tokenizer
import Foam.Universal
import Foam.Navigable
import Foam.Merge
import Foam.Path
import Foam.Reversal
import Foam.Stream
import Foam.IntArith
import Foam.Axioms
import Foam.Born
