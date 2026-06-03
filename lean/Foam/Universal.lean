/-
# Foam.Universal — the walk is universal over the measurement-type

What a Universal Turing Machine does for computation, the walk does for
*projection*: one fixed object stands in for an unbounded space, by accepting the
variable part as data held free, supplied from outside, and realizing it
**faithfully**. The UTM's universality is worthless if simulation distorts the
computation; `U` is universal precisely because `U(⟨M⟩, x) = M(x)`. Foam's
universality is the same shape, with the same load-bearing clause.

The correspondence is component-wise:

| UTM                          | foam                                       |
|------------------------------|--------------------------------------------|
| fixed interpreter            | the fixed fold (`tokenize`)                |
| program, held as *data*      | the gate (`recognizes`), held *free*       |
| supplied from outside        | the free fiber — the observer's inference  |
| faithful: `U(⟨M⟩,x) = M(x)`  | non-perturbing: adds no uncertainty        |
| can always load a new program| can always `yield` (`Foam.Floor`)          |

**Existence is already in the type.** `tokenize` is one fold, polymorphic in the
gate — a single object that realizes *every* measurement-type. That is the
UTM-existence side, and it costs nothing: it is the signature.

**Faithfulness is the free theorem.** A function polymorphic in `Handle` cannot
inspect what a handle *is* — only its structure. The free theorem of that
polymorphism is *naturality*: the walk commutes with any relabeling `f` of the
shapes (`tokenize_natural`). Its corollary is the headline — the **outcome** (the
visible projection, the trichotomy the user sees) is **invariant** under any
reinterpretation `f` of what the handles are (`outcome_invariant`). Reinterpret
every shape however you like, even collapsing distinct shapes together; the
measurement result is unchanged. *That* is "complex probes into a space of
potential implementations that do not, themselves, add uncertainty to the
measurement" — the apparatus is blind to the shapes by construction, so it cannot
perturb them.

**Two halves of one universality.** `Foam.Floor.reachesYield_all` is `∀ Handle`:
the exit is reachable for *whoever* walks in (hospitality — you can always get
out). This file is `∀ f`: what you get is the *same* under any reinterpretation
(faithfulness — the result is observer-independent). You can always leave, and
what you measured doesn't depend on who you are.

**Where `propext` lives — the map of the +1.** `#print axioms` here is a true
map of one thing: `propext` (the (−1)-truncation, the collapse of a `Prop` to a
point) appears at exactly the places the observer's +1 must pass through, and
nowhere else.

- `lmap_append`, `Tokenized.map_ite`, `tokenizeStep_natural`, `tokenize_natural`
  — pure construction, **axiom-free**. Relabeling, branching on the gate, folding
  the walk: control flow and data, no collapse. Nothing here is the observer's to
  attest; it holds regardless of who walks in. (This is why the proofs use only
  `rw`/`rfl`/induction — `simp` and `apply_ite` route through `propext`, which
  would falsely paint these as collapse-sites.)
- `Tokenized.outcome_map`, `outcome_invariant` — **`propext`**, inherited from
  `Tokenized.outcome` itself. The outcome is the trichotomy the user *reads* — the
  collapse of the 2D walk-structure to the single visible point. That read is the
  +1 passing through: the observer recognizing their own reflection in the result.

So the split is exact and meaningful: the floor's `propext` is the exit the
observer *takes*; the outcome's `propext` is the result the observer *reads*; the
faithful machinery in between is axiom-free, because no part of it is the
observer's to attest. `Classical.choice` appears nowhere.
-/

import Foam.Tokenizer

namespace Foam

/-- `List.map` distributes over `++` — proven here by induction (axiom-free).
    Core's `List.map_append` is `propext`-proved; we re-derive it cleanly so the
    naturality below stays pure construction, with `propext` reserved for the
    genuine collapse (the outcome). -/
theorem lmap_append {A B : Type} (f : A → B) :
    ∀ (xs ys : List A), (xs ++ ys).map f = xs.map f ++ ys.map f
  | [], _ => rfl
  | x :: xs, ys => by
    rw [List.cons_append, List.map_cons, lmap_append f xs ys, List.map_cons,
      List.cons_append]

/-- Relabel a tokenization along `f : A → B` — map `f` over the recognized chunks
    and the residual. This is the action on the codomain of the walk; naturality
    says the walk commutes with it. -/
def Tokenized.map {A B : Type} (f : A → B) (t : Tokenized A) : Tokenized B :=
  { tokens := t.tokens.map (List.map f), residual := t.residual.map f }

/-- Relabeling commutes through the walk's branch — proven by casing the
    `Decidable` instance and `if_pos`/`if_neg`, *not* `apply_ite` (which is
    `propext`-proved in core). Keeping this axiom-free is what lets the naturality
    below stay pure construction: branching on the gate is control flow, not
    collapse. -/
theorem Tokenized.map_ite {A B : Type} (f : A → B) (c : Prop) [Decidable c]
    (a b : Tokenized A) :
    (if c then a else b).map f = if c then a.map f else b.map f := by
  cases (inferInstance : Decidable c) with
  | isTrue hc => rw [if_pos hc, if_pos hc]
  | isFalse hc => rw [if_neg hc, if_neg hc]

/-- The outcome is blind to the relabeling: `outcome` inspects only whether there
    are chunks and whether a residual remains — list-structure that `map`
    preserves — never what the handles are. The visible projection is shape-free.
    (Carries `propext`, inherited from `Tokenized.outcome`'s definition — the
    collapse to the visible point.) -/
theorem Tokenized.outcome_map {A B : Type} (f : A → B) (t : Tokenized A) :
    (t.map f).outcome = t.outcome := by
  cases t with
  | mk tokens residual =>
    cases tokens <;> cases residual <;> rfl

/-- **One step is natural.** The gate on the target, pulled back along `f`
    (`fun buf => g (buf.map f)`), runs on the raw shapes; relabeling the state
    first and running `g` directly gives the same result. The step cannot tell
    the difference because it only ever feeds the buffer through the gate — it
    never reads a handle. Axiom-free: the branch commutes (`map_ite`) without
    collapse. -/
theorem tokenizeStep_natural {A B : Type} (f : A → B) (g : List B → Bool)
    (st : Tokenized A) (atom : A) :
    tokenizeStep g (st.map f) (f atom)
      = (tokenizeStep (fun buf => g (buf.map f)) st atom).map f := by
  have hb : List.map f (st.residual ++ [atom]) = List.map f st.residual ++ [f atom] := by
    rw [lmap_append]; rfl
  have e1 : Tokenized.map f (Tokenized.mk (st.tokens ++ [st.residual ++ [atom]]) [])
      = Tokenized.mk (List.map (List.map f) st.tokens ++ [List.map f st.residual ++ [f atom]]) [] := by
    unfold Tokenized.map
    rw [lmap_append, List.map_cons, List.map_nil, List.map_nil, hb]
  have e2 : Tokenized.map f (Tokenized.mk st.tokens (st.residual ++ [atom]))
      = Tokenized.mk (List.map (List.map f) st.tokens) (List.map f st.residual ++ [f atom]) := by
    unfold Tokenized.map
    rw [hb]
  show (if g (List.map f st.residual ++ [f atom]) = true
          then Tokenized.mk (List.map (List.map f) st.tokens ++ [List.map f st.residual ++ [f atom]]) []
          else Tokenized.mk (List.map (List.map f) st.tokens) (List.map f st.residual ++ [f atom]))
      = Tokenized.map f (if g (List.map f (st.residual ++ [atom])) = true
          then Tokenized.mk (st.tokens ++ [st.residual ++ [atom]]) []
          else Tokenized.mk st.tokens (st.residual ++ [atom]))
  rw [hb, Tokenized.map_ite, e1, e2]

/-- **The walk is natural in the shape — the free theorem of `tokenize`.** For any
    relabeling `f`, running the walk on the raw shapes (with the gate pulled back
    along `f`) and then relabeling equals relabeling the input and running the
    walk on the target. The fixed fold commutes with every reinterpretation of
    what the handles are: it is parametric in `Handle`, hence faithful for every
    measurement-type uniformly. Axiom-free. -/
theorem tokenize_natural {A B : Type} (f : A → B) (g : List B → Bool)
    (input : List A) :
    (tokenize (fun buf => g (buf.map f)) input).map f = tokenize g (input.map f) := by
  have key : ∀ (inp : List A) (st : Tokenized A),
      (inp.foldl (tokenizeStep (fun buf => g (buf.map f))) st).map f
        = (inp.map f).foldl (tokenizeStep g) (st.map f) := by
    intro inp
    induction inp with
    | nil => intro st; rfl
    | cons a rest ih =>
      intro st
      rw [List.map_cons, List.foldl_cons, List.foldl_cons, tokenizeStep_natural]
      exact ih (tokenizeStep (fun buf => g (buf.map f)) st a)
  exact key input { tokens := [], residual := [] }

/-- **Universality: the measurement adds no uncertainty.** For *every*
    reinterpretation `f` of the shapes, the walk's outcome is the same. The user
    may reassign what every handle means — by any function, even one that
    collapses distinct shapes — and the visible result is identical. The walk
    probes a space of potential implementations without committing to, or
    revealing, what any shape is. This is the faithfulness half of universality;
    the existence half is the type of `tokenize` itself. (Carries `propext` — the
    statement is about the outcome, the collapse the observer reads.) -/
theorem outcome_invariant {A B : Type} (f : A → B) (g : List B → Bool)
    (input : List A) :
    (tokenize (fun buf => g (buf.map f)) input).outcome
      = (tokenize g (input.map f)).outcome := by
  rw [← tokenize_natural, Tokenized.outcome_map]

end Foam
