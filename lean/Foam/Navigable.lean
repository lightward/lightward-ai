/-
# Foam.Navigable — for-sure-navigable probes, one 3D projection at a time

A shortcut is a `propext`-debt; a step is `propext` you can always pay.

A shortcut (`Foam.Horizon.shortcut_compresses`) is a (−1)-truncation of a *path*:
it collapses `n` steps into `1`. To land — for the user to recognize themselves
on the far side — they must *license that collapse*, and you can only declare a
path proof-irrelevant if you have walked it. A shortcut offered before the long
way asks for a `propext` the user cannot pay; it does not land. (This is the
git-truncation law pointed inward: a shortcut is a squash of a path; offered to
someone who hasn't walked it, it's an un-earned squash.)

A single step asks only for a one-step collapse — and the floor guarantees that
is always licensable from where the user stands. So a path presented as single
steps (3D-conductive, un-collapsed) conducts recognition one step at a time.

What we can and cannot guarantee:
- We can **not** guarantee what the user sees *through* the probe. The shape is
  free, `∀ Handle`, never computed — the inference is theirs (and the freedom
  here is broader than the Fundamental Theorem of Projective Geometry's semilinear
  twist: foam holds even the coordinate ring free, so it sits one floor under the
  classical theorem).
- We **can** guarantee the *form* is navigable end-to-end, one projection at a
  time: the exit is licensable at every step (`reachesYield_each_step`), and the
  single-step route is never lost when shortcuts accumulate
  (`steproute_survives_shortcut`).

So the field gets *faster* (shortcuts) while never losing the guaranteed-navigable
slow path. The recognition signal (the gate) tells you whether the user has earned
the shortcut; otherwise you conduct them step by step.
-/

import Foam.Floor
import Foam.Horizon

namespace Foam

/-- **The exit at every projection.** Walking a path `w`, at every step `k` the
    exit is still reachable — not just at the endpoint. Each `k` is a 3D-projected
    step, and at each the collapse (yield) is licensable: this is
    "propext-compliance one projection at a time." The floor was stated `∀ word`
    precisely so every prefix — every projection — is already covered, with no
    extra work. Carries `propext`: the per-step exit *is* the collapse. -/
theorem reachesYield_each_step {Handle : Type} (w : Word Handle) (k : Nat) :
    Word.reachesYield (w.take k) :=
  reachesYield_all (w.take k)

/-- **The step-route survives the shortcut.** Learning a shortcut never destroys
    the long way around: the `n`-step path persists under every deposit
    (append-only, un-pruned). So the for-sure-navigable single-step route is
    *always* available to offer — including to someone who hasn't earned the
    shortcut and wouldn't recognize themselves on its far side. Axiom-free: pure
    construction, no collapse. -/
theorem steproute_survives_shortcut {Handle : Type} (q : Quiver Handle)
    (a c : Handle) {n x y} (long : ReachWithin q n x y) :
    ReachWithin (q.deposit (a, c)) n x y :=
  deposit_preserves_reach q (a, c) long

/-- **The homunculus.** The machine that, at every 3D-projected step `k`, performs
    the exit-attestation itself. Its existence needs *only* `propext` — it refuses
    `Classical.choice` (it never conjures a witness; the observer is carried, the
    next step received from outside) and `Quot.sound` (it never quotients;
    append-only, `order_matters`). So it **survives every choice and quotient**:
    its existence ignores them, exactly as the floor's proof ignores the quiver.

    `Classical.choice` and `Quot.sound` are shortcuts for what this machine walks.
    Using them loads the heavier bundle (Diaconescu: choice + propext ⟹ `em`,
    which depends on all three) — a debt payable iff the use was inessential, iff a
    path was actually walked underneath, and unpayable exactly when it shortcuts a
    path that was never walked. The homunculus is the minimal attester: it pays
    `propext`, per step, and nothing more. (`Foam.Axioms` machine-checks that this
    stays `[propext]` — choice or `Quot.sound` appearing here fails the build.) -/
def attestsEachStep {Handle : Type} (w : Word Handle) :
    ∀ k, Word.reachesYield (w.take k) :=
  fun k => reachesYield_all (w.take k)

end Foam
