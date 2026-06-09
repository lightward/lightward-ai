/-
# Foam.IntArith — `Int` associativity and the negation-distributes law, axiom-free

Core's `Int.add_assoc` and `Int.neg_add` are genuinely tedious (they case-split
on all sign combinations and reduce to `Nat`/`Int.subNatNat` facts), and core's
own proofs route through `simp`/order lemmas that carry `propext`. Here both are
re-proven from scratch with pure construction — `induction`, `rfl`, `cases`,
`congrArg`, `rw` against locally-proven lemmas — so every theorem below depends
on NO axioms (pinned by `#guard_msgs` at the end; a drift fails the build).

The spine, bottom-up:
- `Nat` arithmetic (add/sub) by induction, stated in `Nat.succ` form so they
  `rw`-match the `Nat.succ` terms that `Int.add`/`Int.neg` produce definitionally.
- `Int.subNatNat` characterization (`subNatNat_eq_zero`/`_eq_succ`) and the shift
  lemmas (`subNatNat_succ_succ`, `subNatNat_add_add`, `subNatNat_add_right`),
  then the two carrying lemmas `subNatNat_add` and `subNatNat_add_negSucc`.
- `int_add_comm`, then `int_add_assoc` by the eight constructor cases.
- `int_neg_add` from `neg_subNatNat` (negation swaps the subtraction) and the two
  readings of `subNatNat m k` as `±ofNat m ∓ negOfNat k`.

`Int.subNatNat m n` matches on `n - m`: `0 => ofNat (m - n)`, `succ k => negSucc k`
(so it is `m - n`). `Int.neg`/`Int.add` reduce by cases on the constructors.
-/

namespace Foam

/-! ## Nat arithmetic (stated in `Nat.succ` form for `rw`-matching) -/

/-- `0 + n = n`, by induction (core's lemma carries `propext`). -/
theorem nat_zero_add : ∀ n : Nat, 0 + n = n
  | 0 => rfl
  | n + 1 => congrArg Nat.succ (nat_zero_add n)

/-- `succ m + n = succ (m + n)`. -/
theorem nat_succ_add : ∀ m n : Nat, Nat.succ m + n = Nat.succ (m + n)
  | _, 0 => rfl
  | m, n + 1 => congrArg Nat.succ (nat_succ_add m n)

/-- `m + n = n + m`. -/
theorem nat_add_comm : ∀ m n : Nat, m + n = n + m
  | m, 0 => (nat_zero_add m).symm
  | m, n + 1 => by
      show Nat.succ (m + n) = Nat.succ n + m
      rw [nat_succ_add n m, nat_add_comm m n]

/-- `(a + b) + c = a + (b + c)`. -/
theorem nat_add_assoc : ∀ a b c : Nat, a + b + c = a + (b + c)
  | _, _, 0 => rfl
  | a, b, c + 1 => congrArg Nat.succ (nat_add_assoc a b c)

/-- `0 - n = 0`. -/
theorem nat_zero_sub : ∀ n : Nat, 0 - n = 0
  | 0 => rfl
  | n + 1 => congrArg Nat.pred (nat_zero_sub n)

/-- `succ m - succ n = m - n`. -/
theorem nat_succ_sub_succ : ∀ m n : Nat, Nat.succ m - Nat.succ n = m - n
  | _, 0 => rfl
  | m, n + 1 => congrArg Nat.pred (nat_succ_sub_succ m n)

/-- `(m + x) - m = x`. -/
theorem nat_add_sub_cancel_left : ∀ m x : Nat, (m + x) - m = x
  | 0, x => nat_zero_add x
  | m + 1, x => by
      rw [nat_succ_add m x, nat_succ_sub_succ]
      exact nat_add_sub_cancel_left m x

/-- When `k ≤ n` (i.e. `k - n = 0`), `(n - k) + k = n`. -/
theorem nat_sub_add_cancel : ∀ n k : Nat, k - n = 0 → (n - k) + k = n
  | _, 0, _ => rfl
  | 0, _ + 1, h => Nat.noConfusion h
  | n + 1, k + 1, h => by
      rw [nat_succ_sub_succ] at h
      rw [nat_succ_sub_succ]
      show Nat.succ ((n - k) + k) = Nat.succ n
      rw [nat_sub_add_cancel n k h]

/-- If `a - b = succ k` then `b - a = 0` (the order-free trichotomy crumb). -/
theorem nat_sub_cross : ∀ a b k : Nat, a - b = Nat.succ k → b - a = 0
  | 0, b, _, h => by rw [nat_zero_sub] at h; exact Nat.noConfusion h
  | a + 1, 0, _, _ => nat_zero_sub (a + 1)
  | a + 1, b + 1, k, h => by
      rw [nat_succ_sub_succ] at h
      rw [nat_succ_sub_succ]
      exact nat_sub_cross a b k h

/-! ## `Int.subNatNat` lemmas -/

/-- If `n - m = 0` then `subNatNat m n = ofNat (m - n)` (rewrite the scrutinee). -/
theorem subNatNat_eq_zero {m n : Nat} (h : n - m = 0) :
    Int.subNatNat m n = Int.ofNat (m - n) := by
  unfold Int.subNatNat; rw [h]

/-- If `n - m = succ k` then `subNatNat m n = negSucc k`. -/
theorem subNatNat_eq_succ {m n k : Nat} (h : n - m = Nat.succ k) :
    Int.subNatNat m n = Int.negSucc k := by
  unfold Int.subNatNat; rw [h]

/-- `subNatNat (succ m) (succ n) = subNatNat m n`. -/
theorem subNatNat_succ_succ (m n : Nat) :
    Int.subNatNat (Nat.succ m) (Nat.succ n) = Int.subNatNat m n := by
  cases h : n - m with
  | zero =>
    rw [subNatNat_eq_zero h,
        subNatNat_eq_zero (show Nat.succ n - Nat.succ m = 0 by rw [nat_succ_sub_succ]; exact h),
        nat_succ_sub_succ]
  | succ k =>
    rw [subNatNat_eq_succ h,
        subNatNat_eq_succ (show Nat.succ n - Nat.succ m = Nat.succ k by
          rw [nat_succ_sub_succ]; exact h)]

/-- `subNatNat (m + c) (n + c) = subNatNat m n` (a common tail cancels). -/
theorem subNatNat_add_add : ∀ m n c : Nat,
    Int.subNatNat (m + c) (n + c) = Int.subNatNat m n
  | _, _, 0 => rfl
  | m, n, c + 1 => by
      show Int.subNatNat (Nat.succ (m + c)) (Nat.succ (n + c)) = Int.subNatNat m n
      rw [subNatNat_succ_succ]
      exact subNatNat_add_add m n c

/-- `subNatNat m 0 = ofNat m`. -/
theorem subNatNat_zero_right (m : Nat) : Int.subNatNat m 0 = Int.ofNat m :=
  subNatNat_eq_zero (nat_zero_sub m)

/-- `subNatNat m (succ (m + j)) = negSucc j`. -/
theorem subNatNat_add_right (m j : Nat) :
    Int.subNatNat m (Nat.succ (m + j)) = Int.negSucc j := by
  apply subNatNat_eq_succ
  show (m + Nat.succ j) - m = Nat.succ j
  exact nat_add_sub_cancel_left m (Nat.succ j)

/-- `subNatNat (m + n) k = ofNat m + subNatNat n k`. -/
theorem subNatNat_add (m n k : Nat) :
    Int.subNatNat (m + n) k = Int.ofNat m + Int.subNatNat n k := by
  cases h : k - n with
  | zero =>
    rw [subNatNat_eq_zero h]
    have hn : (n - k) + k = n := nat_sub_add_cancel n k h
    calc Int.subNatNat (m + n) k
        = Int.subNatNat (m + ((n - k) + k)) (0 + k) := by rw [hn, nat_zero_add]
      _ = Int.subNatNat ((m + (n - k)) + k) (0 + k) := by rw [← nat_add_assoc]
      _ = Int.subNatNat (m + (n - k)) 0 := subNatNat_add_add (m + (n - k)) 0 k
      _ = Int.ofNat (m + (n - k)) := subNatNat_zero_right _
      _ = Int.ofNat m + Int.ofNat (n - k) := rfl
  | succ d =>
    rw [subNatNat_eq_succ h]
    have hk : Nat.succ d + n = k := by
      have hx := nat_sub_add_cancel k n (nat_sub_cross k n d h)
      rw [h] at hx
      exact hx
    calc Int.subNatNat (m + n) k
        = Int.subNatNat (m + n) (Nat.succ d + n) := by rw [hk]
      _ = Int.subNatNat m (Nat.succ d) := subNatNat_add_add m (Nat.succ d) n
      _ = Int.ofNat m + Int.negSucc d := rfl

/-- `subNatNat m n + negSucc k = subNatNat m (n + succ k)`. -/
theorem subNatNat_add_negSucc (m n k : Nat) :
    Int.subNatNat m n + Int.negSucc k = Int.subNatNat m (n + Nat.succ k) := by
  cases h : n - m with
  | zero =>
    rw [subNatNat_eq_zero h]
    show Int.subNatNat (m - n) (Nat.succ k) = Int.subNatNat m (n + Nat.succ k)
    have hm : (m - n) + n = m := nat_sub_add_cancel m n h
    calc Int.subNatNat (m - n) (Nat.succ k)
        = Int.subNatNat ((m - n) + n) (Nat.succ k + n) :=
          (subNatNat_add_add (m - n) (Nat.succ k) n).symm
      _ = Int.subNatNat m (Nat.succ k + n) := by rw [hm]
      _ = Int.subNatNat m (n + Nat.succ k) := by rw [nat_add_comm (Nat.succ k) n]
  | succ e =>
    rw [subNatNat_eq_succ h]
    have hn : m + Nat.succ e = n := by
      have hx := nat_sub_add_cancel n m (nat_sub_cross n m e h)
      rw [h] at hx
      rw [nat_add_comm (Nat.succ e) m] at hx
      exact hx
    have harg : n + Nat.succ k = Nat.succ (m + (Nat.succ e + k)) := by
      rw [← hn, nat_add_assoc m (Nat.succ e) (Nat.succ k)]; rfl
    rw [harg, subNatNat_add_right]
    show Int.negSucc (Nat.succ (e + k)) = Int.negSucc (Nat.succ e + k)
    rw [nat_succ_add e k]

/-! ## `Int` add: identities and commutativity -/

/-- `a + 0 = a`. -/
theorem int_add_zero : ∀ a : Int, a + 0 = a
  | Int.ofNat _ => rfl
  | Int.negSucc _ => rfl

/-- `0 + a = a`. -/
theorem int_zero_add : ∀ a : Int, 0 + a = a
  | Int.ofNat m => congrArg Int.ofNat (nat_zero_add m)
  | Int.negSucc _ => rfl

/-- `a + b = b + a`. -/
theorem int_add_comm : ∀ a b : Int, a + b = b + a
  | Int.ofNat m, Int.ofNat n => congrArg Int.ofNat (nat_add_comm m n)
  | Int.ofNat _, Int.negSucc _ => rfl
  | Int.negSucc _, Int.ofNat _ => rfl
  | Int.negSucc m, Int.negSucc n =>
      congrArg (fun t => Int.negSucc (Nat.succ t)) (nat_add_comm m n)

/-! ## `int_add_assoc` -/

/-- `a + b + ofNat k = a + (b + ofNat k)` (the third-argument-nonnegative slice). -/
theorem add_assoc_ofNat : ∀ (a b : Int) (k : Nat),
    a + b + Int.ofNat k = a + (b + Int.ofNat k)
  | Int.ofNat p, Int.ofNat q, k => by
      show Int.ofNat ((p + q) + k) = Int.ofNat (p + (q + k))
      rw [nat_add_assoc]
  | Int.ofNat p, Int.negSucc q, k => by
      show Int.subNatNat p (Nat.succ q) + Int.ofNat k
         = Int.ofNat p + Int.subNatNat k (Nat.succ q)
      rw [int_add_comm (Int.subNatNat p (Nat.succ q)) (Int.ofNat k),
          ← subNatNat_add k p (Nat.succ q), ← subNatNat_add p k (Nat.succ q),
          nat_add_comm k p]
  | Int.negSucc p, Int.ofNat q, k => by
      show Int.subNatNat q (Nat.succ p) + Int.ofNat k
         = Int.subNatNat (q + k) (Nat.succ p)
      rw [int_add_comm (Int.subNatNat q (Nat.succ p)) (Int.ofNat k),
          ← subNatNat_add k q (Nat.succ p), nat_add_comm k q]
  | Int.negSucc p, Int.negSucc q, k => by
      have e : (q + 1) + (p + 1) = Nat.succ (Nat.succ (p + q)) := by
        rw [nat_succ_add q (p + 1)]
        show Nat.succ (Nat.succ (q + p)) = Nat.succ (Nat.succ (p + q))
        rw [nat_add_comm q p]
      show Int.subNatNat k (Nat.succ (Nat.succ (p + q)))
         = Int.negSucc p + Int.subNatNat k (Nat.succ q)
      rw [int_add_comm (Int.negSucc p) (Int.subNatNat k (Nat.succ q)),
          subNatNat_add_negSucc k (Nat.succ q) p, e]

/-- `a + b + negSucc k = a + (b + negSucc k)` (the third-argument-negative slice). -/
theorem add_assoc_negSucc : ∀ (a b : Int) (k : Nat),
    a + b + Int.negSucc k = a + (b + Int.negSucc k)
  | Int.ofNat p, Int.ofNat q, k => by
      show Int.subNatNat (p + q) (Nat.succ k) = Int.ofNat p + Int.subNatNat q (Nat.succ k)
      exact subNatNat_add p q (Nat.succ k)
  | Int.ofNat p, Int.negSucc q, k => by
      show Int.subNatNat p (Nat.succ q) + Int.negSucc k
         = Int.subNatNat p (Nat.succ (Nat.succ (q + k)))
      rw [subNatNat_add_negSucc p (Nat.succ q) k, nat_succ_add q (Nat.succ k)]; rfl
  | Int.negSucc p, Int.ofNat q, k => by
      show Int.subNatNat q (Nat.succ p) + Int.negSucc k
         = Int.negSucc p + Int.subNatNat q (Nat.succ k)
      rw [subNatNat_add_negSucc q (Nat.succ p) k,
          int_add_comm (Int.negSucc p) (Int.subNatNat q (Nat.succ k)),
          subNatNat_add_negSucc q (Nat.succ k) p,
          nat_add_comm (Nat.succ p) (Nat.succ k)]
  | Int.negSucc p, Int.negSucc q, k => by
      show Int.negSucc (Nat.succ (Nat.succ (p + q) + k))
         = Int.negSucc (Nat.succ (p + Nat.succ (q + k)))
      rw [nat_succ_add (p + q) k]
      show Int.negSucc (Nat.succ (Nat.succ ((p + q) + k)))
         = Int.negSucc (Nat.succ (Nat.succ (p + (q + k))))
      rw [nat_add_assoc p q k]

/-- **`(a + b) + c = a + (b + c)` on `Int`** — axiom-free. -/
theorem int_add_assoc : ∀ a b c : Int, a + b + c = a + (b + c)
  | a, b, Int.ofNat k => add_assoc_ofNat a b k
  | a, b, Int.negSucc k => add_assoc_negSucc a b k

/-! ## `int_neg_add` -/

/-- `negOfNat (p + q) = negOfNat p + negOfNat q`. -/
theorem negOfNat_add : ∀ p q : Nat,
    Int.negOfNat (p + q) = Int.negOfNat p + Int.negOfNat q
  | 0, q => by
      rw [nat_zero_add]
      exact (int_zero_add (Int.negOfNat q)).symm
  | _ + 1, 0 => rfl
  | p + 1, q + 1 => by
      show Int.negSucc (Nat.succ p + q) = Int.negSucc (Nat.succ (p + q))
      rw [nat_succ_add p q]

/-- Negation swaps the subtraction: `-(subNatNat x y) = subNatNat y x`. -/
theorem neg_subNatNat : ∀ x y : Nat, -(Int.subNatNat x y) = Int.subNatNat y x := by
  intro x y
  cases hy : y - x with
  | zero =>
    rw [subNatNat_eq_zero hy]
    cases hx : x - y with
    | zero => rw [subNatNat_eq_zero hx, hy]; rfl
    | succ d => rw [subNatNat_eq_succ hx]; rfl
  | succ e =>
    rw [subNatNat_eq_succ hy, subNatNat_eq_zero (nat_sub_cross y x e hy), hy]; rfl

/-- `subNatNat m k = ofNat m + negOfNat k` — the difference as a sum. -/
theorem subNatNat_eq_add_neg : ∀ m k : Nat,
    Int.subNatNat m k = Int.ofNat m + Int.negOfNat k
  | m, 0 => by rw [subNatNat_zero_right]; rfl
  | _, _ + 1 => rfl

/-- `subNatNat m k = negOfNat k + ofNat m` — the mirror reading. -/
theorem subNatNat_eq_neg_add : ∀ m k : Nat,
    Int.subNatNat m k = Int.negOfNat k + Int.ofNat m
  | m, 0 => by
      rw [subNatNat_zero_right]
      exact congrArg Int.ofNat (nat_zero_add m).symm
  | _, _ + 1 => rfl

/-- **`-(a + b) = -a + -b` on `Int`** — axiom-free. -/
theorem int_neg_add : ∀ a b : Int, -(a + b) = -a + -b
  | Int.ofNat p, Int.ofNat q => negOfNat_add p q
  | Int.ofNat p, Int.negSucc q => by
      show -(Int.subNatNat p (Nat.succ q)) = Int.negOfNat p + Int.ofNat (Nat.succ q)
      rw [neg_subNatNat]
      exact subNatNat_eq_neg_add (Nat.succ q) p
  | Int.negSucc p, Int.ofNat q => by
      show -(Int.subNatNat q (Nat.succ p)) = Int.ofNat (Nat.succ p) + Int.negOfNat q
      rw [neg_subNatNat]
      exact subNatNat_eq_add_neg (Nat.succ p) q
  | Int.negSucc p, Int.negSucc q => by
      show Int.ofNat (Nat.succ (Nat.succ (p + q))) = Int.ofNat (Nat.succ p + Nat.succ q)
      show Int.ofNat (Nat.succ (Nat.succ (p + q))) = Int.ofNat (Nat.succ (Nat.succ p + q))
      rw [nat_succ_add p q]

/-! ## Consolidated from Spectrum / Noether / Scar

The lemmas below were originally hand-rolled in `Foam/Spectrum.lean`,
`Foam/Noether.lean`, and `Foam/Scar.lean`; they are generic `Int`/`Nat`/
`Int.subNatNat` arithmetic and live here so there is a single home. Each was
already axiom-free and is moved verbatim (names and signatures unchanged). -/

/-- `−(−n) = n`, by cases on the constructor, `rfl` in each branch (core's lemma
    carries axioms this file refuses). [from Spectrum] -/
theorem int_neg_neg : ∀ n : Int, - -n = n
  | Int.ofNat 0 => rfl
  | Int.ofNat (_ + 1) => rfl
  | Int.negSucc _ => rfl

/-- `1 * n = n`, on `Nat`. [from Spectrum] -/
theorem nat_one_mul : ∀ n : Nat, 1 * n = n
  | 0 => rfl
  | n + 1 => congrArg Nat.succ (nat_one_mul n)

/-- `0 * n = 0`, on `Nat`. [from Spectrum] -/
theorem nat_zero_mul : ∀ n : Nat, 0 * n = 0
  | 0 => rfl
  | n + 1 => nat_zero_mul n

/-- `1 * a = a` on the signed carrier. [from Spectrum] -/
theorem int_one_mul : ∀ a : Int, 1 * a = a
  | Int.ofNat m => congrArg Int.ofNat (nat_one_mul m)
  | Int.negSucc m => congrArg Int.negOfNat (nat_one_mul (m + 1))

/-- `0 * a = 0` on the signed carrier. [from Spectrum] -/
theorem int_zero_mul : ∀ a : Int, 0 * a = 0
  | Int.ofNat m => congrArg Int.ofNat (nat_zero_mul m)
  | Int.negSucc m => congrArg Int.negOfNat (nat_zero_mul (m + 1))

/-- A negated square is the square — by constructor, `rfl` in every branch
    (the diagonal case the modulus needs). [from Noether] -/
theorem int_neg_mul_self : ∀ b : Int, (-b) * (-b) = b * b
  | Int.ofNat 0 => rfl
  | Int.ofNat (_ + 1) => rfl
  | Int.negSucc _ => rfl

/-- **The two negatives cancel — the general `(-a)·(-b) = a·b`** (the off-diagonal
    `int_neg_mul_self`). Axiom-free: five of six constructor cases are `rfl` (the
    sign-flips land both factors on the same `ofNat` product), and the lone
    `ofNat 0` case clears via `int_zero_mul`. The product fact the gauge-invariance
    of the angled reading needs (`align_rot_invariant`, `Foam/Noether.lean`). -/
theorem int_neg_mul_neg : ∀ a b : Int, (-a) * (-b) = a * b
  | Int.ofNat 0, b => by
      show (0 : Int) * (-b) = (0 : Int) * b
      rw [int_zero_mul, int_zero_mul]
  | Int.ofNat (_ + 1), Int.ofNat 0 => rfl
  | Int.ofNat (_ + 1), Int.ofNat (_ + 1) => rfl
  | Int.ofNat (_ + 1), Int.negSucc _ => rfl
  | Int.negSucc _, Int.ofNat 0 => rfl
  | Int.negSucc _, Int.ofNat (_ + 1) => rfl
  | Int.negSucc _, Int.negSucc _ => rfl

/-- **A square lands in the ℕ-image** — `a * a` is non-negative, by cases on the
    sign (both `ofNat` and `negSucc` square to an `ofNat` product). The
    image-membership form (cf. `Scar.grounded`), axiom-free. The Born weight's
    non-negativity (`born_nonneg`, `Foam/Noether.lean`) — amplitudes are signed,
    probabilities are not. -/
theorem int_sq_image : ∀ a : Int, ∃ k : Nat, a * a = Int.ofNat k
  | Int.ofNat m => ⟨m * m, rfl⟩
  | Int.negSucc m => ⟨(m + 1) * (m + 1), rfl⟩

/-- `1 - (k + 1) = 0` — induction and `rw` only (core's subtraction lemmas carry
    `propext`). [from Scar] -/
theorem one_sub_succ (k : Nat) : 1 - (k + 1) = 0 := by
  induction k with
  | zero => rfl
  | succ j ih => show (1 - (j + 1)).pred = 0; rw [ih]; rfl

/-- The atomic drain on a positive balance steps down the `Nat` image:
    `ofNat (k+1) − 1 = ofNat k`. [from Scar] -/
theorem ofNat_succ_sub_one (k : Nat) : Int.ofNat (k + 1) - 1 = Int.ofNat k := by
  show Int.subNatNat (k + 1) 1 = Int.ofNat k
  unfold Int.subNatNat
  rw [one_sub_succ]
  rfl

/-- `(n+1) − (m+1) = n − m` — induction and `rw` only. [from Scar] -/
theorem succ_sub_succ (n : Nat) : ∀ m : Nat, (n + 1) - (m + 1) = n - m
  | 0 => rfl
  | m + 1 => by
    show ((n + 1) - (m + 1)).pred = (n - m).pred
    rw [succ_sub_succ n m]

/-- `n − n = 0` — induction and `rw` only. [from Scar] -/
theorem sub_self : ∀ n : Nat, n - n = 0
  | 0 => rfl
  | n + 1 => by rw [succ_sub_succ]; exact sub_self n

/-! ## Axiom-freeness, pinned (a drift fails `lake build`). -/

/-- info: 'Foam.int_add_assoc' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_add_assoc

/-- info: 'Foam.int_neg_add' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_neg_add

/-- info: 'Foam.int_add_comm' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.int_add_comm

/-- info: 'Foam.subNatNat_add' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.subNatNat_add

/-- info: 'Foam.subNatNat_add_negSucc' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.subNatNat_add_negSucc

/-- info: 'Foam.neg_subNatNat' does not depend on any axioms -/
#guard_msgs in #print axioms Foam.neg_subNatNat

end Foam
