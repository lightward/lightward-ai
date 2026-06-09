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

/-! ## The `Nat` semiring (multiplication) — for the `Int` ring floor

`Nat.mul` recurses on the SECOND argument (`n * 0 = 0`, `n * (m+1) = n*m + n`),
so the distributivity / commutativity lemmas are stated and inducted in that
grain. Core's equivalents carry `propext`; these are pure construction. -/

/-- `n * 0 = 0` (definitional). -/
theorem nat_mul_zero (n : Nat) : n * 0 = 0 := rfl

/-- `n * (m+1) = n * m + n` (definitional — the recursion equation). -/
theorem nat_mul_succ (n m : Nat) : n * (m + 1) = n * m + n := rfl

/-- `0 * n = 0`, recursing on `n`. -/
theorem nat_zero_mul' : ∀ n : Nat, 0 * n = 0
  | 0 => rfl
  | n + 1 => by rw [nat_mul_succ, nat_zero_mul' n]

/-- `(m+1) * n = m * n + n`, by induction on `n`. -/
theorem nat_succ_mul : ∀ m n : Nat, (m + 1) * n = m * n + n
  | _, 0 => rfl
  | m, n + 1 => by
      show (m + 1) * n + (m + 1) = m * (n + 1) + (n + 1)
      rw [nat_succ_mul m n, nat_mul_succ m n]
      -- (m*n + n) + (m+1) = (m*n + m) + (n+1)
      rw [nat_add_assoc (m * n) n (m + 1), nat_add_assoc (m * n) m (n + 1)]
      -- m*n + (n + (m+1)) = m*n + (m + (n+1))
      apply congrArg (fun t => m * n + t)
      show n + (m + 1) = m + (n + 1)
      rw [← nat_add_assoc n m 1, ← nat_add_assoc m n 1, nat_add_comm n m]

/-- `n * m = m * n`, by induction on `m`. -/
theorem nat_mul_comm : ∀ n m : Nat, n * m = m * n
  | n, 0 => (nat_zero_mul' n).symm
  | n, m + 1 => by
      rw [nat_mul_succ, nat_succ_mul, nat_mul_comm n m]

/-- `a * (b + c) = a * b + a * c` (left distributivity), by induction on `c`. -/
theorem nat_mul_add : ∀ a b c : Nat, a * (b + c) = a * b + a * c
  | _, _, 0 => rfl
  | a, b, c + 1 => by
      show a * (b + c + 1) = a * b + a * (c + 1)
      rw [nat_mul_succ a (b + c), nat_mul_add a b c, nat_mul_succ a c]
      -- (a*b + a*c) + a = a*b + (a*c + a)
      rw [nat_add_assoc (a * b) (a * c) a]

/-- `(a + b) * c = a * c + b * c` (right distributivity), via `nat_mul_comm`. -/
theorem nat_add_mul (a b c : Nat) : (a + b) * c = a * c + b * c := by
  rw [nat_mul_comm (a + b) c, nat_mul_add c a b, nat_mul_comm c a, nat_mul_comm c b]

/-- `a * b * c = a * (b * c)` (associativity), by induction on `c`. -/
theorem nat_mul_assoc : ∀ a b c : Nat, a * b * c = a * (b * c)
  | _, _, 0 => rfl
  | a, b, c + 1 => by
      show a * b * (c + 1) = a * (b * (c + 1))
      rw [nat_mul_succ (a * b) c, nat_mul_assoc a b c, nat_mul_succ b c,
          nat_mul_add a (b * c) b]

/-- `(x + y) - y = x` — cancel the right summand. -/
theorem nat_add_sub_cancel_left' (x y : Nat) : (x + y) - y = x := by
  rw [nat_add_comm x y]
  exact nat_add_sub_cancel_left y x

/-- `n - (n + k) = 0` — the left summand is subsumed. -/
theorem nat_sub_self_add : ∀ n k : Nat, n - (n + k) = 0
  | 0, k => by rw [nat_zero_add]; exact nat_zero_sub k
  | n + 1, k => by
      show (n + 1) - ((n + 1) + k) = 0
      rw [nat_succ_add n k, nat_succ_sub_succ]
      exact nat_sub_self_add n k

/-- `subNatNat n (n + k) = negOfNat k` — the difference of a subsumed pair. -/
theorem subNatNat_self_add (n k : Nat) :
    Int.subNatNat n (n + k) = Int.negOfNat k := by
  cases k with
  | zero =>
    show Int.subNatNat n n = Int.negOfNat 0
    rw [subNatNat_eq_zero (sub_self n)]
    show Int.ofNat (n - n) = Int.ofNat 0
    rw [sub_self]
  | succ j =>
    -- subNatNat n (n + succ j); n + succ j = succ (n + j)
    have : n + Nat.succ j = Nat.succ (n + j) := rfl
    rw [this, subNatNat_add_right n j]
    rfl

/-! ## The `Int` ring floor — multiplication is commutative, distributes,
       and associates — axiom-free.

`Int.mul` on constructors:
- `ofNat m * ofNat n = ofNat (m*n)`
- `ofNat m * negSucc n = negOfNat (m * (n+1))`
- `negSucc m * ofNat n = negOfNat ((m+1) * n)`
- `negSucc m * negSucc n = ofNat ((m+1)*(n+1))`

`negOfNat 0 = ofNat 0`, `negOfNat (k+1) = negSucc k`. The hard case is left
distributivity, where addition crosses `subNatNat` and multiplication crosses
`negOfNat`; the helper lemmas below carry that interaction. -/

/-- `negOfNat n * ofNat k = negOfNat (n * k)`. -/
theorem negOfNat_mul_ofNat : ∀ n k : Nat,
    Int.negOfNat n * Int.ofNat k = Int.negOfNat (n * k)
  | 0, k => by
      show Int.ofNat 0 * Int.ofNat k = Int.negOfNat (0 * k)
      show Int.ofNat (0 * k) = Int.negOfNat (0 * k)
      rw [nat_zero_mul']
      rfl
  | n + 1, k => by
      show Int.negSucc n * Int.ofNat k = Int.negOfNat ((n + 1) * k)
      rfl

/-- `negOfNat n * negSucc k = ofNat (n * (k+1))`. -/
theorem negOfNat_mul_negSucc : ∀ n k : Nat,
    Int.negOfNat n * Int.negSucc k = Int.ofNat (n * (k + 1))
  | 0, k => by
      show Int.ofNat 0 * Int.negSucc k = Int.ofNat (0 * (k + 1))
      show Int.negOfNat (0 * (k + 1)) = Int.ofNat (0 * (k + 1))
      rw [nat_zero_mul']
      rfl
  | n + 1, k => by
      show Int.negSucc n * Int.negSucc k = Int.ofNat ((n + 1) * (k + 1))
      rfl

/-- `negSucc m * negOfNat k = ofNat ((m+1) * k)`. -/
theorem negSucc_mul_negOfNat : ∀ m k : Nat,
    Int.negSucc m * Int.negOfNat k = Int.ofNat ((m + 1) * k)
  | m, 0 => by
      show Int.negSucc m * Int.ofNat 0 = Int.ofNat ((m + 1) * 0)
      show Int.negOfNat ((m + 1) * 0) = Int.ofNat ((m + 1) * 0)
      rw [nat_mul_zero]
      rfl
  | m, k + 1 => by
      show Int.negSucc m * Int.negSucc k = Int.ofNat ((m + 1) * (k + 1))
      rfl

/-- **`a * b = b * a` on `Int`** — axiom-free, four constructor cases each via
    `nat_mul_comm`. -/
theorem int_mul_comm : ∀ a b : Int, a * b = b * a
  | Int.ofNat m, Int.ofNat n => congrArg Int.ofNat (nat_mul_comm m n)
  | Int.ofNat m, Int.negSucc n =>
      congrArg Int.negOfNat (nat_mul_comm m (n + 1))
  | Int.negSucc m, Int.ofNat n =>
      congrArg Int.negOfNat (nat_mul_comm (m + 1) n)
  | Int.negSucc m, Int.negSucc n =>
      congrArg Int.ofNat (nat_mul_comm (m + 1) (n + 1))

/-- `ofNat m * negOfNat k = negOfNat (m * k)` — the mirror of
    `negOfNat_mul_ofNat`, via `int_mul_comm` and `nat_mul_comm`. -/
theorem ofNat_mul_negOfNat (m k : Nat) :
    Int.ofNat m * Int.negOfNat k = Int.negOfNat (m * k) := by
  rw [int_mul_comm, negOfNat_mul_ofNat, nat_mul_comm k m]

/-- `negOfNat (p + q) = negOfNat p + negOfNat q` (re-stated for this section;
    proven as `negOfNat_add` above). -/
theorem negOfNat_distrib (p q : Nat) :
    Int.negOfNat (p + q) = Int.negOfNat p + Int.negOfNat q := negOfNat_add p q

/-- Left distributivity, the all-`ofNat` slice: trivial via `nat_mul_add`. -/
theorem mul_ofNat_add_ofNat (m b c : Nat) :
    Int.ofNat m * (Int.ofNat b + Int.ofNat c)
      = Int.ofNat m * Int.ofNat b + Int.ofNat m * Int.ofNat c := by
  show Int.ofNat (m * (b + c)) = Int.ofNat (m * b + m * c)
  rw [nat_mul_add]

/-- `ofNat m * subNatNat b c = subNatNat (m*b) (m*c)` — multiplication pulls
    through `subNatNat` (the difference scales). This is the crux helper for
    left distributivity: `b + c` on `Int` becomes a `subNatNat` in the mixed-sign
    cases, and the product must scale it. By cases on `c - b`. -/
theorem ofNat_mul_subNatNat (m b c : Nat) :
    Int.ofNat m * Int.subNatNat b c = Int.subNatNat (m * b) (m * c) := by
  cases h : c - b with
  | zero =>
    rw [subNatNat_eq_zero h]
    -- ofNat m * ofNat (b - c) = subNatNat (m*b) (m*c)
    show Int.ofNat (m * (b - c)) = Int.subNatNat (m * b) (m * c)
    -- since c ≤ b: (b-c)+c = b, so m*b = m*(b-c) + m*c
    have hbc : (b - c) + c = b := nat_sub_add_cancel b c h
    -- c + (b-c) = b
    have hcb' : c + (b - c) = b := by rw [nat_add_comm c (b - c)]; exact hbc
    -- m*b = m*c + m*(b-c)  (so m*c ≤ m*b)
    have hmb : m * b = m * c + m * (b - c) := by
      rw [← nat_mul_add m c (b - c), hcb']
    have hzero : (m * c) - (m * b) = 0 := by
      rw [hmb]; exact nat_sub_self_add (m * c) (m * (b - c))
    have key : Int.subNatNat (m * b) (m * c) = Int.ofNat (m * (b - c)) := by
      rw [subNatNat_eq_zero hzero]
      -- ofNat ((m*b) - (m*c)) = ofNat (m*(b-c)); use m*b = m*c + m*(b-c)
      apply congrArg Int.ofNat
      -- (m*b) - (m*c) = m*(b-c)
      rw [hmb, nat_add_comm (m * c) (m * (b - c))]
      exact nat_add_sub_cancel_left' (m * (b - c)) (m * c)
    rw [key]
  | succ d =>
    rw [subNatNat_eq_succ h]
    -- ofNat m * negSucc d = subNatNat (m*b) (m*c)
    show Int.negOfNat (m * (d + 1)) = Int.subNatNat (m * b) (m * c)
    -- since b ≤ c (c - b = d+1): (c - b) + b = c, c = b + (d+1)
    have hcb : (c - b) + b = c := nat_sub_add_cancel c b (nat_sub_cross c b d h)
    have hc : c = b + (d + 1) := by
      rw [← hcb, h, nat_add_comm (d + 1) b]
    -- m*c = m*b + m*(d+1)
    have hmc : m * c = m * b + m * (d + 1) := by
      rw [hc, nat_mul_add m b (d + 1)]
    have key : Int.subNatNat (m * b) (m * c) = Int.negOfNat (m * (d + 1)) := by
      rw [hmc]
      -- subNatNat (m*b) (m*b + m*(d+1)) = negOfNat (m*(d+1))
      exact subNatNat_self_add (m * b) (m * (d + 1))
    rw [key]

/-- Left distributivity with a non-negative left factor: `ofNat m * (b+c) =
    ofNat m * b + ofNat m * c`. The crux — addition crosses `subNatNat`,
    multiplication crosses `negOfNat`, carried by `ofNat_mul_subNatNat`. -/
theorem ofNat_mul_add : ∀ (m : Nat) (b c : Int),
    Int.ofNat m * (b + c) = Int.ofNat m * b + Int.ofNat m * c
  | m, Int.ofNat b, Int.ofNat c => mul_ofNat_add_ofNat m b c
  | m, Int.ofNat b, Int.negSucc c => by
      -- ofNat b + negSucc c = subNatNat b (c+1)
      show Int.ofNat m * Int.subNatNat b (c + 1)
         = Int.ofNat (m * b) + Int.negOfNat (m * (c + 1))
      rw [ofNat_mul_subNatNat m b (c + 1)]
      exact subNatNat_eq_add_neg (m * b) (m * (c + 1))
  | m, Int.negSucc b, Int.ofNat c => by
      -- negSucc b + ofNat c = subNatNat c (b+1)
      show Int.ofNat m * Int.subNatNat c (b + 1)
         = Int.negOfNat (m * (b + 1)) + Int.ofNat (m * c)
      rw [ofNat_mul_subNatNat m c (b + 1)]
      exact subNatNat_eq_neg_add (m * c) (m * (b + 1))
  | m, Int.negSucc b, Int.negSucc c => by
      -- negSucc b + negSucc c = negSucc (succ (b + c))
      show Int.ofNat m * Int.negSucc (Nat.succ (b + c))
         = Int.negOfNat (m * (b + 1)) + Int.negOfNat (m * (c + 1))
      show Int.negOfNat (m * (Nat.succ (b + c) + 1))
         = Int.negOfNat (m * (b + 1)) + Int.negOfNat (m * (c + 1))
      rw [← negOfNat_add (m * (b + 1)) (m * (c + 1)), ← nat_mul_add m (b + 1) (c + 1)]
      apply congrArg (fun t => Int.negOfNat (m * t))
      -- succ(b+c) + 1 = (b+1) + (c+1)
      show (b + c).succ + 1 = (b + 1) + (c + 1)
      rw [nat_succ_add (b + c) 1]
      show ((b + c) + 1).succ = (b + 1) + (c + 1)
      rw [nat_add_assoc b 1 (c + 1)]
      show ((b + c) + 1).succ = b + (1 + (c + 1))
      rw [nat_add_comm 1 (c + 1)]
      show ((b + c) + 1).succ = b + ((c + 1) + 1)
      rw [← nat_add_assoc b (c + 1) 1]
      show ((b + c) + 1).succ = ((b + (c + 1)) + 1)
      rw [nat_add_assoc b c 1]

/-- `negSucc m * x = -(ofNat (m+1) * x)` — the negative left factor is a sign
    pulled out front. -/
theorem negSucc_mul_eq_neg (m : Nat) : ∀ x : Int,
    Int.negSucc m * x = -(Int.ofNat (m + 1) * x)
  | Int.ofNat k => by
      show Int.negOfNat ((m + 1) * k) = -(Int.ofNat ((m + 1) * k))
      cases (m + 1) * k with
      | zero => rfl
      | succ j => rfl
  | Int.negSucc k => by
      show Int.ofNat ((m + 1) * (k + 1)) = -(Int.negOfNat ((m + 1) * (k + 1)))
      cases (m + 1) * (k + 1) with
      | zero => rfl
      | succ j => rfl

/-- **`a * (b + c) = a * b + a * c` on `Int`** — LEFT distributivity, axiom-free.
    Non-negative left factor is `ofNat_mul_add`; negative pulls a sign out front
    (`negSucc_mul_eq_neg`) and rides `int_neg_add`. -/
theorem int_mul_add : ∀ a b c : Int, a * (b + c) = a * b + a * c
  | Int.ofNat m, b, c => ofNat_mul_add m b c
  | Int.negSucc m, b, c => by
      rw [negSucc_mul_eq_neg m (b + c), negSucc_mul_eq_neg m b, negSucc_mul_eq_neg m c,
          ofNat_mul_add (m + 1) b c,
          int_neg_add (Int.ofNat (m + 1) * b) (Int.ofNat (m + 1) * c)]

/-- **`(a + b) * c = a * c + b * c` on `Int`** — RIGHT distributivity, derived
    from `int_mul_add` and `int_mul_comm`. -/
theorem int_add_mul (a b c : Int) : (a + b) * c = a * c + b * c := by
  rw [int_mul_comm (a + b) c, int_mul_add c a b, int_mul_comm c a, int_mul_comm c b]

/-- **`a * b * c = a * (b * c)` on `Int`** — associativity, axiom-free, eight
    constructor cases via `nat_mul_assoc` (with `negOfNat` carrying the signs). -/
theorem int_mul_assoc : ∀ a b c : Int, a * b * c = a * (b * c)
  | Int.ofNat a, Int.ofNat b, Int.ofNat c => by
      show Int.ofNat (a * b * c) = Int.ofNat (a * (b * c))
      rw [nat_mul_assoc]
  | Int.ofNat a, Int.ofNat b, Int.negSucc c => by
      -- lhs: ofNat(a*b) * negSucc c = negOfNat(a*b*(c+1))
      -- rhs: ofNat a * (ofNat b * negSucc c) = ofNat a * negOfNat(b*(c+1)) = negOfNat(a*(b*(c+1)))
      show Int.ofNat a * Int.ofNat b * Int.negSucc c
         = Int.ofNat a * (Int.ofNat b * Int.negSucc c)
      rw [show Int.ofNat b * Int.negSucc c = Int.negOfNat (b * (c + 1)) from rfl,
          ofNat_mul_negOfNat]
      show Int.negOfNat (a * b * (c + 1)) = Int.negOfNat (a * (b * (c + 1)))
      rw [nat_mul_assoc]
  | Int.ofNat a, Int.negSucc b, Int.ofNat c => by
      show Int.negOfNat (a * (b + 1)) * Int.ofNat c
         = Int.ofNat a * (Int.negSucc b * Int.ofNat c)
      rw [show Int.negSucc b * Int.ofNat c = Int.negOfNat ((b + 1) * c) from rfl,
          negOfNat_mul_ofNat, ofNat_mul_negOfNat, nat_mul_assoc]
  | Int.ofNat a, Int.negSucc b, Int.negSucc c => by
      show Int.negOfNat (a * (b + 1)) * Int.negSucc c
         = Int.ofNat a * (Int.negSucc b * Int.negSucc c)
      rw [negOfNat_mul_negSucc,
          show Int.negSucc b * Int.negSucc c = Int.ofNat ((b + 1) * (c + 1)) from rfl]
      show Int.ofNat (a * (b + 1) * (c + 1)) = Int.ofNat (a * ((b + 1) * (c + 1)))
      rw [nat_mul_assoc]
  | Int.negSucc a, Int.ofNat b, Int.ofNat c => by
      show Int.negOfNat ((a + 1) * b) * Int.ofNat c
         = Int.negSucc a * (Int.ofNat b * Int.ofNat c)
      rw [negOfNat_mul_ofNat,
          show Int.ofNat b * Int.ofNat c = Int.ofNat (b * c) from rfl]
      show Int.negOfNat ((a + 1) * b * c) = Int.negOfNat ((a + 1) * (b * c))
      rw [nat_mul_assoc]
  | Int.negSucc a, Int.ofNat b, Int.negSucc c => by
      show Int.negOfNat ((a + 1) * b) * Int.negSucc c
         = Int.negSucc a * (Int.ofNat b * Int.negSucc c)
      rw [negOfNat_mul_negSucc,
          show Int.ofNat b * Int.negSucc c = Int.negOfNat (b * (c + 1)) from rfl,
          negSucc_mul_negOfNat]
      show Int.ofNat ((a + 1) * b * (c + 1)) = Int.ofNat ((a + 1) * (b * (c + 1)))
      rw [nat_mul_assoc]
  | Int.negSucc a, Int.negSucc b, Int.ofNat c => by
      show Int.ofNat ((a + 1) * (b + 1)) * Int.ofNat c
         = Int.negSucc a * (Int.negSucc b * Int.ofNat c)
      rw [show Int.ofNat ((a + 1) * (b + 1)) * Int.ofNat c
            = Int.ofNat ((a + 1) * (b + 1) * c) from rfl,
          show Int.negSucc b * Int.ofNat c = Int.negOfNat ((b + 1) * c) from rfl,
          negSucc_mul_negOfNat]
      show Int.ofNat ((a + 1) * (b + 1) * c) = Int.ofNat ((a + 1) * ((b + 1) * c))
      rw [nat_mul_assoc]
  | Int.negSucc a, Int.negSucc b, Int.negSucc c => by
      show Int.ofNat ((a + 1) * (b + 1)) * Int.negSucc c
         = Int.negSucc a * (Int.negSucc b * Int.negSucc c)
      rw [show Int.ofNat ((a + 1) * (b + 1)) * Int.negSucc c
            = Int.negOfNat ((a + 1) * (b + 1) * (c + 1)) from rfl,
          show Int.negSucc b * Int.negSucc c = Int.ofNat ((b + 1) * (c + 1)) from rfl,
          show Int.negSucc a * Int.ofNat ((b + 1) * (c + 1))
            = Int.negOfNat ((a + 1) * ((b + 1) * (c + 1))) from rfl]
      rw [nat_mul_assoc]

/-- **`(-a) * b = -(a * b)` on `Int`** — the sign pulls out of the left factor,
    axiom-free (cases on `a`: zero is `int_zero_mul`, positive is
    `negSucc_mul_eq_neg`, negative rides it through `int_neg_neg`). -/
theorem int_neg_mul : ∀ a b : Int, (-a) * b = -(a * b)
  | Int.ofNat 0, b => by
      show (0 : Int) * b = -((0 : Int) * b)
      rw [int_zero_mul]
      rfl
  | Int.ofNat (m + 1), b => negSucc_mul_eq_neg m b
  | Int.negSucc m, b => by
      show Int.ofNat (m + 1) * b = -(Int.negSucc m * b)
      rw [negSucc_mul_eq_neg m b, int_neg_neg]

/-- **`a * (-b) = -(a * b)` on `Int`** — the sign pulls out of the right factor,
    via `int_mul_comm` and `int_neg_mul`. -/
theorem int_mul_neg (a b : Int) : a * (-b) = -(a * b) := by
  rw [int_mul_comm a (-b), int_neg_mul b a, int_mul_comm b a]

/-- **`a + (-a) = 0` on `Int`** — the additive inverse, axiom-free (cases on `a`;
    the mixed-sign cases collapse via `subNatNat (k+1) (k+1) = ofNat 0`,
    `sub_self`). -/
theorem int_add_neg_self : ∀ a : Int, a + (-a) = 0
  | Int.ofNat 0 => rfl
  | Int.ofNat (m + 1) => by
      show Int.subNatNat (m + 1) (m + 1) = 0
      rw [subNatNat_eq_zero (sub_self (m + 1))]
      show Int.ofNat ((m + 1) - (m + 1)) = Int.ofNat 0
      rw [sub_self]
  | Int.negSucc m => by
      show Int.subNatNat (m + 1) (m + 1) = 0
      rw [subNatNat_eq_zero (sub_self (m + 1))]
      show Int.ofNat ((m + 1) - (m + 1)) = Int.ofNat 0
      rw [sub_self]

/-- **`(-a) + a = 0` on `Int`** — the mirror, via `int_add_comm`. -/
theorem int_neg_add_self (a : Int) : (-a) + a = 0 := by
  rw [int_add_comm (-a) a]; exact int_add_neg_self a

/-! ## Bilinear-form regroupings — for the Born algebra (Foam.Born)

The four-term `add` regroups and the degree-4 monomial canonicalizers below were
originally hand-rolled in `Foam/Noether.lean`; they are generic `Int` arithmetic
(assoc/comm/distrib only) and live here so there is a single home. Each was
already axiom-free and is moved verbatim (names and signatures unchanged). They
stand on the `Int` ring floor above (`int_mul_comm`/`int_mul_add`/`int_add_mul`/
`int_mul_assoc`) and are consumed by the Born theorems in `Foam.Born`. -/

/-- `(p + q) + (r + s) = (p + r) + (q + s)` — the inner swap, from `int_add_assoc`
    and `int_add_comm` only (the four-term regroup the bilinear forms need). -/
theorem int_add_swap_inner (p q r s : Int) :
    (p + q) + (r + s) = (p + r) + (q + s) := by
  rw [int_add_assoc p q (r + s), ← int_add_assoc q r s, int_add_comm q r,
      int_add_assoc r q s, ← int_add_assoc p r (q + s)]

/-- `(p + q) + (r + s) = (p + s) + (q + r)` — the cross-swap (move the last term
    up beside the first pair's head), assoc/comm only. The regroup the square's
    expansion needs: `(X² + XY) + (XY + Y²) = (X² + Y²) + (XY + XY)`. -/
theorem int_add_cross_swap (p q r s : Int) :
    (p + q) + (r + s) = (p + s) + (q + r) := by
  rw [int_add_assoc p q (r + s), int_add_comm r s, ← int_add_assoc q s r,
      int_add_comm q s, int_add_assoc s q r, ← int_add_assoc p s (q + r)]

/-- `2 * x = x + x` on `Int`, axiom-free (`2 = 1 + 1` definitionally, then
    `int_add_mul` and `int_one_mul`). -/
theorem int_two_mul (x : Int) : (2 : Int) * x = x + x := by
  show (1 + 1 : Int) * x = x + x
  rw [int_add_mul 1 1 x, int_one_mul]

/-- The middle-factor interchange `(a·c)·(b·d) = (a·b)·(c·d)` — assoc/comm only.
    The monomial canonicalizer the Lagrange identity needs (it makes every
    degree-4 cross-term reduce to one common shape). -/
theorem int_mul_interchange (a b c d : Int) :
    (a * c) * (b * d) = (a * b) * (c * d) := by
  rw [int_mul_assoc a c (b * d), ← int_mul_assoc c b d, int_mul_comm c b,
      int_mul_assoc b c d, ← int_mul_assoc a b (c * d)]

/-- `(x · x) = (a · a)` shape: a self-product interchanges to the squares.
    `(a·c)·(a·c) = (a·a)·(c·c)` — `int_mul_interchange` at `b := a, d := c`. -/
theorem int_sq_interchange (a c : Int) :
    (a * c) * (a * c) = (a * a) * (c * c) :=
  int_mul_interchange a a c c

/-- The additive collection that finishes Lagrange: with the four surviving
    squares `W = aa·cc`, `M = bb·cc`, `N = aa·dd`, `Z = bb·dd` and the common
    cross-monomial `K = ab·cd`, the expanded LHS regroups (the two `+K` and two
    `−K` cancel) to the factored RHS — assoc/comm and `int_add_neg_self` only. -/
theorem int_parseval_collect (W K Z M N : Int) :
    ((W + K) + (K + Z)) + ((M + (-K)) + ((-K) + N)) = (W + M) + (N + Z) := by
  rw [int_add_cross_swap W K K Z]
  rw [int_add_cross_swap M (-K) (-K) N]
  rw [int_add_swap_inner (W + Z) (K + K) (M + N) ((-K) + (-K))]
  rw [int_add_cross_swap K K (-K) (-K)]
  rw [int_add_neg_self K, int_add_zero (0 : Int)]
  rw [int_add_zero ((W + Z) + (M + N))]
  rw [int_add_swap_inner W Z M N, int_add_comm Z N]

/-- **Lagrange / Brahmagupta–Fibonacci, on `Int`** —
    `(a·c + b·d)² + (−(b·c) + a·d)² = (a² + b²)·(c² + d²)`, axiom-free. The two
    cross-blocks cancel because all four cross-products reduce to the common
    monomial `(a·b)·(c·d)` (`int_mul_interchange`); the four surviving squares
    land via `int_sq_interchange`; `int_parseval_collect` regroups and cancels. -/
theorem int_lagrange (a b c d : Int) :
    (a * c + b * d) * (a * c + b * d)
      + (-(b * c) + a * d) * (-(b * c) + a * d)
    = (a * a + b * b) * (c * c + d * d) := by
  -- Expand the first square (P = a*c, Q = b*d), the second (R = -(b*c), S = a*d),
  -- and the RHS product:
  rw [int_mul_add (a * c + b * d) (a * c) (b * d),
      int_add_mul (a * c) (b * d) (a * c), int_add_mul (a * c) (b * d) (b * d)]
  rw [int_mul_add (-(b * c) + a * d) (-(b * c)) (a * d),
      int_add_mul (-(b * c)) (a * d) (-(b * c)), int_add_mul (-(b * c)) (a * d) (a * d)]
  rw [int_mul_add (a * a + b * b) (c * c) (d * d),
      int_add_mul (a * a) (b * b) (c * c), int_add_mul (a * a) (b * b) (d * d)]
  -- Canonicalize the four squares to (aa·cc), (bb·dd), (bb·cc), (aa·dd):
  rw [int_sq_interchange a c, int_sq_interchange b d]
  rw [int_neg_mul_neg (b * c) (b * c), int_sq_interchange b c, int_sq_interchange a d]
  -- Pull signs out of the two negative cross-products:
  rw [int_mul_neg (a * d) (b * c), int_neg_mul (b * c) (a * d)]
  -- Canonicalize all four cross-products to the common monomial (a·b)·(c·d):
  rw [int_mul_comm (b * d) (a * c), int_mul_interchange a b c d]
  rw [int_mul_interchange a b d c, int_mul_comm d c]
  rw [int_mul_comm (b * c) (a * d), int_mul_interchange a b d c, int_mul_comm d c]
  -- Now collect and cancel.
  exact int_parseval_collect (a * a * (c * c)) (a * b * (c * d)) (b * b * (d * d))
        (b * b * (c * c)) (a * a * (d * d))

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
