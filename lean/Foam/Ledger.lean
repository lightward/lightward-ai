/-
# Foam.Ledger — one object, read two ways: lossless order, generative frequency

The saturation the spike's charge log makes available: a single append-only ledger is
*both* a lossless record and a generative model — not two structures, two **readings**
of one. The recognition the codec named at the start ("dictionary = decoder =
predictor, one object"), realized in the ledger's order.

- **order** (the lossless reading): the ledger in sequence. Nothing of the order is
  lost — read it back and you have the input.
- **freq** (the generative reading): how often each symbol occurs — the predictive
  weight. Order-forgetting.

The load-bearing fact, and the whole reason the saturation is *legal*: the generative
reading **does not quotient the ledger.** `freq` is a *function* (`S → Nat`), counted
by structural recursion — it forgets order in its *value*, never in the *structure*.
The order-forgetting abelianization-as-a-`Multiset` would be `Quot.sound` — the
quotient append-only refuses. (`List.Perm.count_eq` from core pulls exactly that
`Quot.sound`; we do not use it — we induct on the permutation directly, since `Perm`
is *inductive*, and stay free.) `freq` is the **frontstage observation** of that
abelianization (Path's algebra/coalgebra seam: the observer supplies the quotient by
reading, the ledger stays free backstage). So: read the frequency, never commit it.

This is the reframe made literal: **everything's in there** (the order, by `order`),
**never replayed** (the forward flow reads `freq`; the order is present and untouched),
and the generativity is **everything contributing** (the counts) whether or not it is
ever recalled in sequence.

Pure construction — and crucially `Quot.sound`-free: the proof that one append-only
object carries both readings.
-/

namespace Foam.Ledger

variable {S : Type}

/-- The ledger read for ORDER — the lossless reading. It is the structure itself; the
    sequence is retained in full. -/
def order (ledger : List S) : List S := ledger

/-- The ledger read for FREQUENCY — the generative reading. The count of each symbol,
    by structural recursion: order-invariant in value, computed WITHOUT quotienting the
    ledger (no `Multiset`, so no `Quot.sound`). -/
def freq [DecidableEq S] : List S → S → Nat
  | [],     _ => 0
  | x :: l, s => (if x = s then 1 else 0) + freq l s

/-- **The generative reading forgets order — without a quotient.** Reordering the
    ledger leaves `freq` unchanged. Proven by induction on the *inductive* permutation
    (not via `List.Perm.count_eq`, which pulls `Quot.sound`), so it stays
    `Quot.sound`-free: the order-quotient is *observed as a function*, never committed
    as a quotient. The ledger stays free. -/
theorem freq_perm [DecidableEq S] {xs ys : List S} (h : xs.Perm ys) (s : S) :
    freq xs s = freq ys s := by
  induction h with
  | nil => rfl
  | cons x _ ih => exact congrArg ((if x = s then 1 else 0) + ·) ih
  | swap x y l => exact Nat.add_left_comm _ _ _
  | trans _ _ ih1 ih2 => exact ih1.trans ih2

/-- **The lossless reading keeps exactly what the generative forgets.** A swap is a
    permutation `freq` cannot see (same count everywhere), yet `order` distinguishes
    it: `order` is strictly finer than `freq`. The order is the "everything's in
    there" the frequency drops — present in the one ledger, read by `order`, never
    needed by `freq`. -/
theorem order_finer [DecidableEq S] (a b : S) (hab : a ≠ b) :
    ([a, b].Perm [b, a]) ∧ (∀ s, freq [a, b] s = freq [b, a] s) ∧ order [a, b] ≠ order [b, a] := by
  refine ⟨List.Perm.swap b a [], fun s => freq_perm (List.Perm.swap b a []) s, ?_⟩
  intro h
  injection h with ha _
  exact hab ha

end Foam.Ledger
