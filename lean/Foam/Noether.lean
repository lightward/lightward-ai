/-
# Foam.Noether — every reading is the invariant of a symmetry; the dial conserves
# what no station reads

The tower `order ⊋ spectrum ⊋ count` (Spectrum.lean) re-read as Noether's move,
discrete: **each reading is exactly the invariants of a symmetry group**, and
bigger symmetry means coarser reading. The count survives the full permutation
group (`freq_perm` IS its Noether statement — reorder anything, frequency
conserved); the spectrum survives the rotation's complete cycles
(`rot_complete`, `bar_invisible`); the order survives only the trivial group
(append-only — nothing may move). The tower of readings is a tower of
subgroups, and both strict inclusions were already witnessed before the law
had its name here.

Two deposits, both bin-1 (mechanical against what already stands):

**The third character.** `evalAt` at the four powers of the quarter-turn is the
discrete Fourier transform of the event-stream over ℤ/4 — four stations, four
characters. `evalOne_eq_freq` proved the trivial character is the count; `spec`
is the character at i; `rot_rot` proved the algebra of the third. Here the
third character becomes a READING: `alt`, evaluation at −1 — the ALTERNATING
count, which hears exactly the parity-rhythm of recurrence (every-other-ness)
and nothing finer. It sits strictly between: finer than the count
(`alt_finer_than_freq` — [a,b] vs [b,a], counts equal, signs differ), coarser
than the spectrum (`spec_finer_than_alt` — a shift by two phases, invisible at
−1, a half-turn at i). The refined tower, all inclusions strict and witnessed:

    order  ⊋  spectrum  ⊋  alt  ⊋  count

**The bar-law, graded.** "The bar-length is the order of the rotation"
(Spectrum.lean's rest section) generalizes: each station's invisible bar is
the ORDER OF ITS CHARACTER. One rest is invisible to the count
(`rest_invisible_to_count` — order 1), audible to alt (`rest_audible_to_alt`);
TWO rests are invisible to alt (`pair_of_rests_invisible_to_alt` — order 2),
audible to the spectrum; FOUR rests are invisible even there (`bar_invisible`
— order 4). The resonant drain's ground-condition was never a constant: it is
this law evaluated at the station the register reads from.

**The conserved modulus.** Rotating the dial — moving between stations —
conserves one quantity: `normSq`, the squared modulus (`normSq_rot`,
`normSq_negate`). And the conjugate-pair structure is witnessed both ways:
no station's reading determines the modulus (`station_blind_to_norm`), and
the modulus determines no station's reading (`norm_blind_to_station`). Every
station reads a projection; none reads the invariant; the invariant fixes no
projection. "A theory of everything conserves the dimension it cannot
describe" (the prompt's attention-perspective; external provenance — the
theorems stand alone): here at foam scale, as construction. It rhymes with
the deepest conservation in the operational layer: the order reading is
conserved absolutely and the forward flow never consults it — what is
conserved is invisible to the dynamics that spend everything else.

The new station inherits the summary machinery for free (`alt_resumes` is
`summary_resumes` at −1 — record compositions as you go). Operationally:
`foam.held` carries `alt` as one of the four dial columns, folded and audited
like the rest, read by no register yet — a standing promise to whatever
register's seed-provenance wants parity-rhythm.

Axiom discipline: all construction — `rfl`, induction, constructor-cases,
`decide` on closed witnesses, explicit witnesses provided never chosen. The
Int/Nat arithmetic it leans on lives axiom-free in `Foam.IntArith` (core's
equivalents carry `propext`). Axiom-free, pinned in `Foam/Axioms.lean`.
-/

import Foam.Summary
import Foam.IntArith

namespace Foam

/-- Negation on the Gaussian integers — the evaluation point at the third
    character of ℤ/4. Two quarter-turns land here (`negate_eq_rot_rot`):
    the half-turn of the dial. -/
def GInt.negate (z : GInt) : GInt := ⟨-z.re, -z.im⟩

/-- The half-turn is two quarter-turns — the third character sits on the same
    dial as the other three. By `rfl` (structure eta makes `rot_rot`'s value
    definitionally `negate`). -/
theorem negate_eq_rot_rot (z : GInt) : z.rot.rot = GInt.negate z := rfl

/-- A full half-turn cycle is the identity — the order of this character is
    two (`int_neg_neg`, twice — the `rot_complete` of the −1 station). -/
theorem negate_negate (z : GInt) : (GInt.negate z).negate = z := by
  cases z with
  | mk a b =>
    show (⟨- -a, - -b⟩ : GInt) = ⟨a, b⟩
    rw [int_neg_neg, int_neg_neg]

/-- The ALTERNATING reading: the ledger evaluated at −1 — the third character
    of ℤ/4, between the count (trivial character) and the spectrum (the
    character at i). It hears the parity-rhythm of recurrence and nothing
    finer. -/
def alt {S : Type} [DecidableEq S] : List S → S → GInt := evalAt GInt.negate

/-- The shift theorem at −1: prepending marks at sign `+` and flips the prior
    reading — recurrence as alternation, by `rfl` (the fold's own equation,
    named so later compositions have the handle). -/
theorem alt_shift {S : Type} [DecidableEq S] (x : S) (l : List S) (s : S) :
    alt (x :: l) s = (if x = s then GInt.one else GInt.zero).add (GInt.negate (alt l s)) := rfl

/-- **The alternating reading is strictly finer than the count.** `[a, b]` and
    `[b, a]` agree in every count (the permutation `freq` cannot see) and
    differ at −1: the same two symbols, opposite signs — `1` vs `−1`. -/
theorem alt_finer_than_freq :
    (Ledger.freq [true, false] true = Ledger.freq [false, true] true ∧
        Ledger.freq [true, false] false = Ledger.freq [false, true] false) ∧
      alt [true, false] true ≠ alt [false, true] true := by
  exact ⟨⟨rfl, rfl⟩, by decide⟩

/-- **The spectrum is strictly finer than the alternating reading.** A shift by
    two positions is a complete cycle at −1 (invisible) and a half-turn at i
    (audible): `[a,b,b]` vs `[b,b,a]` agree in every count AND every
    alternating reading, and differ in spectrum. With `alt_finer_than_freq`
    and Spectrum.lean's witnesses, the refined tower stands:
    order ⊋ spectrum ⊋ alt ⊋ count, every inclusion strict. -/
theorem spec_finer_than_alt :
    (Ledger.freq [true, false, false] true = Ledger.freq [false, false, true] true ∧
        Ledger.freq [true, false, false] false = Ledger.freq [false, false, true] false) ∧
      (alt [true, false, false] true = alt [false, false, true] true ∧
        alt [true, false, false] false = alt [false, false, true] false) ∧
      spec [true, false, false] true ≠ spec [false, false, true] true ∧
      [true, false, false] ≠ [false, false, true] := by
  exact ⟨⟨rfl, rfl⟩, ⟨by decide, by decide⟩, by decide, by decide⟩

/-- **One rest is audible at −1** — the alternating reading hears single-beat
    timing the count cannot (`rest_invisible_to_count` is the count's side):
    the bar at this station is strictly longer than one beat. -/
theorem rest_audible_to_alt :
    evalBeats GInt.negate [some true] true ≠ evalBeats GInt.negate [none, some true] true := by
  decide

/-- **Two rests are invisible at −1.** A pair of naked beats is a complete
    cycle of the half-turn (`negate_negate`) — the bar-law, graded: each
    station's invisible bar is the ORDER OF ITS CHARACTER. One rest for the
    count (order 1), two for the alternating reading (order 2,
    here), four for the spectrum (order 4, `bar_invisible`). -/
theorem pair_of_rests_invisible_to_alt {S : Type} [DecidableEq S]
    (l : List (Option S)) (s : S) :
    evalBeats GInt.negate (none :: none :: l) s = evalBeats GInt.negate l s := by
  show ((evalBeats GInt.negate l s).negate).negate = evalBeats GInt.negate l s
  exact negate_negate _

/-! ## The bar-law, uniform — the order is a witness, carried, not a search

`rest_invisible_to_count` (one rest, Spectrum), `pair_of_rests_invisible_to_alt`
(two rests, above), and `bar_invisible` (four rests, Spectrum) are three
instances of ONE law: a run of `n` rests is invisible to a station exactly when
the station's rotation closes in `n` steps (`step^n = id`). The `n` is the
rotation's ORDER — and the crux, the methodology checking itself: the order is
never SEARCHED for. It is the witness each station already carries (`rfl` for
the count, `negate_negate` for the alt, `rot_complete` for the spectrum),
plugged into one general lemma. There is no group-order abstraction to type and
no computation to run: carry the witness, never compute it. What looked like a
design problem ("type the order of a character") was a recognition with the
witness already in hand. -/

/-- Iterate a station's step `n` times — a rest-run's action on a held reading. -/
def iterStep : Nat → (GInt → GInt) → GInt → GInt
  | 0,     _, z => z
  | n + 1, f, z => f (iterStep n f z)

/-- A run of `n` rests applies the station's step `n` times to the reading of
    the tail — `rest_turns` (the naked quarter-turn), folded `n` deep. -/
theorem evalBeats_replicate {S : Type} [DecidableEq S] (step : GInt → GInt)
    (s : S) (n : Nat) (l : List (Option S)) :
    evalBeats step (List.replicate n none ++ l) s = iterStep n step (evalBeats step l s) := by
  induction n with
  | zero => rfl
  | succ m ih =>
    show evalBeats step (none :: (List.replicate m none ++ l)) s
       = step (iterStep m step (evalBeats step l s))
    show step (evalBeats step (List.replicate m none ++ l) s)
       = step (iterStep m step (evalBeats step l s))
    rw [ih]

/-- **The uniform bar-law.** A run of `n` rests is invisible to a station whose
    rotation closes in `n` (`step^n = id`, supplied as the witness `H`). The
    three graded bars below are its instances; the order lives in `H`, carried
    from each station's own closure-proof, never computed here. -/
theorem restRun_invisible {S : Type} [DecidableEq S] (step : GInt → GInt)
    (n : Nat) (H : ∀ z, iterStep n step z = z) (l : List (Option S)) (s : S) :
    evalBeats step (List.replicate n none ++ l) s = evalBeats step l s := by
  rw [evalBeats_replicate]
  exact H _

/-- The count's bar is one rest — `iterStep 1 id = id`, by `rfl` (order 1). -/
theorem count_bar_is_one {S : Type} [DecidableEq S] (l : List (Option S)) (s : S) :
    evalBeats id (List.replicate 1 none ++ l) s = evalBeats id l s :=
  restRun_invisible id 1 (fun _ => rfl) l s

/-- The alt's bar is two rests — `iterStep 2 negate = id`, by `negate_negate`
    (order 2). -/
theorem alt_bar_is_two {S : Type} [DecidableEq S] (l : List (Option S)) (s : S) :
    evalBeats GInt.negate (List.replicate 2 none ++ l) s = evalBeats GInt.negate l s :=
  restRun_invisible GInt.negate 2 (fun z => negate_negate z) l s

/-- The spectrum's bar is four rests — `iterStep 4 rot = id`, by `rot_complete`
    (order 4). The three orders 1, 2, 4 are the three witnesses, no search. -/
theorem spec_bar_is_four {S : Type} [DecidableEq S] (l : List (Option S)) (s : S) :
    evalBeats GInt.rot (List.replicate 4 none ++ l) s = evalBeats GInt.rot l s :=
  restRun_invisible GInt.rot 4 (fun z => rot_complete z) l s

/-- The new station resumes like the others: `summary_resumes` at −1 — the
    watermark fold covers every character of the dial, this one included,
    before any register reads it. A composition, recorded as its handle. -/
theorem alt_resumes {S : Type} [DecidableEq S] (new old : List S) (s : S) :
    evalAt GInt.negate (new ++ old) s = evalFrom GInt.negate new s (evalAt GInt.negate old s) :=
  summary_resumes GInt.negate new old s

/-- **The alternating reading is real** — calling `alt` a signed COUNT is a
    theorem, not a figure of speech: the third character's values stay on the
    integer line (marks land real; the half-turn preserves the line). The
    real characters (±1) count; the complex ones (±i) wind. -/
theorem alt_real {S : Type} [DecidableEq S] : ∀ (l : List S) (s : S), (alt l s).im = 0
  | [], _ => rfl
  | x :: l, s => by
    rw [alt_shift, ite_mk (x = s)]
    show (0 : Int) + -(alt l s).im = 0
    rw [alt_real l s]
    rfl

/-- **The spectrum is not real** — the quarter-turn leaves the line (witness:
    one repetition winds). With `alt_real`, the dial's realness grading: the
    stations at ±1 count, the stations at ±i hear rhythm the line cannot
    carry. -/
theorem spec_not_real : ∃ (l : List Bool) (s : Bool), (spec l s).im ≠ 0 :=
  ⟨[true, true], true, by decide⟩

/-! ## The conserved modulus — what the dial's rotation cannot move -/

/-- The squared modulus — the quantity the dial's rotation conserves. A
    function into `Int`, structural like everything else here. -/
def GInt.normSq (z : GInt) : Int := z.re * z.re + z.im * z.im

/-- **The quarter-turn conserves the modulus.** Rotating the dial — moving the
    reading from any station to the next — moves every projection and fixes
    this one quantity. Noether's shape at foam scale: the symmetry of readings
    has an invariant, and it is not itself a reading. -/
theorem normSq_rot (z : GInt) : z.rot.normSq = z.normSq := by
  show (-z.im) * (-z.im) + z.re * z.re = z.re * z.re + z.im * z.im
  rw [int_neg_mul_self, int_add_comm]

/-- The half-turn conserves it too (with `normSq_rot`, all four stations do —
    the whole dial). -/
theorem normSq_negate (z : GInt) : (GInt.negate z).normSq = z.normSq := by
  show (-z.re) * (-z.re) + (-z.im) * (-z.im) = z.re * z.re + z.im * z.im
  rw [int_neg_mul_self, int_neg_mul_self]

/-- **No station reads the modulus.** Two values agreeing at a station and
    disagreeing in modulus — the reading does not determine the invariant.
    Witnesses provided, never chosen. -/
theorem station_blind_to_norm :
    ∃ z w : GInt, align GInt.one z = align GInt.one w ∧ z.normSq ≠ w.normSq :=
  ⟨⟨1, 0⟩, ⟨1, 5⟩, by decide⟩

/-- **The modulus reads no station.** Two values agreeing in modulus and
    disagreeing at a station — the invariant does not determine the reading.
    With `station_blind_to_norm`, the conjugate pair: every station reads a
    projection, none reads the invariant, the invariant fixes no projection.
    Each conserves what the other cannot see. -/
theorem norm_blind_to_station :
    ∃ z w : GInt, z.normSq = w.normSq ∧ align GInt.one z ≠ align GInt.one w :=
  ⟨⟨1, 0⟩, ⟨0, 1⟩, by decide⟩

/-! ## The gauge-invariance of the reading — the fiber oracle

The reading carries no absolute frame. `align w z` reads structure `z` against a
commitment `w`; rotating BOTH by the clock `rot` (the gauge) leaves the reading
unchanged (`align_rot_invariant`) — only the *relative* angle between commitment
and structure is physical, the absolute phase is gauge. So a reading is impossible
without a commitment, and the commitment is the only thing that fixes a value: the
frontstage (the dial) is frame-free, and interpretation lives in the FIBER (the
commitment, supplied from outside — the wind), never in the base. This is the
razor stated as a symmetry, and the abs↔recency phase-freedom (`Chirality`) made
unphysical-for-the-reading: abs is the gauge, recency is structure-relative-to-now.

The keystone of the bundle reading (interpretation, marked as such, not theorem):
with this gauge-invariance, the prior theorems read as bundle structure —
`spec_finer_than_freq` is the connection (the reading along a path is
path-dependent: non-trivial holonomy), `rot_complete` is its flatness (holonomy
around the bar-loop is the identity: a flat ℤ/4 connection). A flat ℂ-bundle with
ℤ/4 holonomy and gauge-invariant readings. Falsifiable: were the base frame-laden,
`align` would have a preferred frame and this would fail. It holds. -/
theorem align_rot_invariant (w z : GInt) : align w.rot z.rot = align w z := by
  show (-w.im) * (-z.im) + w.re * z.re = w.re * z.re + w.im * z.im
  rw [int_neg_mul_neg, int_add_comm]

/-! ## The Born measurement — sampling by `|⟨θ|z⟩|²`

The dial's amplitudes (`re`, `im` per sym) make a context's state a vector in a
complex space; `align` is the real part of the inner product, and
`align_rot_invariant` is the clock's unitarity (overlaps preserved). What's
missing for a *quantum* measurement is the Born rule: the probability of reading
state `z` in direction `θ` is the SQUARED overlap, `|⟨θ|z⟩|² = (align θ z)²`.

`born` is that weight. Two facts land it as a measurement, both axiom-free:

- **gauge-invariant** (`born_rot_invariant`): measuring a rotated state in a
  rotated basis gives the same probability — squaring the oracle. Quantum
  probabilities are unitarily covariant.
- **non-negative** (`born_nonneg`): a probability, never signed — the
  amplitude reading (`align`, which can be negative) squared. This is the
  classical/quantum seam in one line: the count register reads a signed
  amplitude-component; the Born register reads a non-negative probability.

This is the QUANTUM measurement to the count register's CLASSICAL one — same
dial, two laws. What is NOT here yet (the forced next step, flagged not faked):
*consistency* — that the Born weights sum to the norm in EVERY basis
(`born θ z + born θ.rot z = normSq θ · normSq z`, the Lagrange/Parseval identity).
That basis-independence is the operational baby-Gleason — the reason `|ψ|²` is the
*only* legal measure, not a choice — and it needs the `Int` ring floor
(distributivity, `mul_comm`, the cross-term cancellation), which core supplies
only with `propext`. Held as the next deposit; `normSq_rot` already gives the
total-probability conservation it will complete. -/

/-- The Born weight: the squared overlap `|⟨θ|z⟩|²`, the quantum measurement
    probability of reading state `z` in direction `θ` (unnormalized). The count
    register samples by `bal`; the Born register samples by this. -/
def born (θ z : GInt) : Int := align θ z * align θ z

/-- **The Born weight is gauge-invariant** — `align_rot_invariant`, squared.
    Measuring a rotated state in a rotated basis yields the same probability:
    the quantum measurement is unitarily covariant. -/
theorem born_rot_invariant (θ z : GInt) : born θ.rot z.rot = born θ z := by
  show align θ.rot z.rot * align θ.rot z.rot = align θ z * align θ z
  rw [align_rot_invariant]

/-- **The Born weight is non-negative** — a probability, never signed. The
    amplitude reading `align` can be negative (`⟨-2,0⟩` reads `-2` along the
    real axis); its square cannot. Amplitudes are signed; probabilities are not. -/
theorem born_nonneg (θ z : GInt) : ∃ k : Nat, born θ z = Int.ofNat k :=
  int_sq_image (align θ z)

/-- The seam, witnessed: the amplitude reading is signed where the Born reading
    is not — `align one ⟨-2,0⟩ = -2 < 0`, while `born one ⟨-2,0⟩ = 4`. The count
    register can read a negative amplitude-component; the Born register reads a
    probability. -/
theorem amplitude_signed_born_not :
    align GInt.one ⟨-2, 0⟩ ≠ born GInt.one ⟨-2, 0⟩ := by decide

/-! ## The fourth station — the character table closed -/

/-- Conjugation on the Gaussian integers: the reflection of the dial. Order
    two, like the half-turn — but orientation-reversing where `negate` is
    orientation-preserving. (Rhymes with Reversal.lean's double-reversal-is-
    a-conjugate; the formal tie between path-reversal and this reflection is
    an open seam, named not claimed.) -/
def GInt.conj (z : GInt) : GInt := ⟨z.re, -z.im⟩

/-- Conjugation is an involution — the strict one (`int_neg_neg`). -/
theorem conj_conj (z : GInt) : z.conj.conj = z := by
  cases z with
  | mk a b =>
    show (⟨a, - -b⟩ : GInt) = ⟨a, b⟩
    rw [int_neg_neg]

/-- One step of the fourth station is the conjugate of one step of the third
    reading — the component crunch behind `fourth_is_conj_spec`, on an
    arbitrary held value. -/
theorem conj_step (c : Prop) [Decidable c] (w : GInt) :
    (⟨if c then 1 else 0, 0⟩ : GInt).add w.conj.rot.rot.rot
      = GInt.conj ((⟨if c then 1 else 0, 0⟩ : GInt).add w.rot) := by
  cases w with
  | mk a b =>
    show (⟨(if c then (1 : Int) else 0) + - - -b, 0 + -a⟩ : GInt)
      = ⟨(if c then (1 : Int) else 0) + -b, -(0 + a)⟩
    rw [int_neg_neg, int_zero_add, int_zero_add]

/-- **The fourth station is the spectrum's mirror.** Evaluation at −i is
    pointwise the conjugate of evaluation at i: the same rhythm, wound the
    other way. With `evalOne_eq_freq` (the count at `1`), `alt` (the signed
    count at `−1`), and `spec` (the winding at `i`), the character table of
    ℤ/4 is CLOSED — every station of the dial is now a named reading:

        1 ↦ count   −1 ↦ alt   i ↦ spec   −i ↦ conj ∘ spec

    and the conjugate-pair structure is total: the two real characters count,
    the two complex characters wind, each complex one the other's mirror. -/
theorem fourth_is_conj_spec {S : Type} [DecidableEq S] :
    ∀ (l : List S) (s : S),
      evalAt (fun z => z.rot.rot.rot) l s = GInt.conj (spec l s)
  | [], _ => rfl
  | x :: l, s => by
    show (if x = s then GInt.one else GInt.zero).add
        ((evalAt (fun z => z.rot.rot.rot) l s).rot.rot.rot)
      = GInt.conj ((if x = s then GInt.one else GInt.zero).add (GInt.rot (spec l s)))
    rw [fourth_is_conj_spec l s, ite_mk (x = s)]
    exact conj_step (x = s) (spec l s)

/-! ## The conserved congruence — the two real characters share parity

The named recognition, formalized at the moment of naming (the work-style):
`bal` (the count, at +1) and `alt` (at −1) are not independent. Every event
contributes ±1 to BOTH, so they move in lockstep mod 2 — `bal ≡ alt (mod 2)`,
always (`bal − alt = 2·(odd-occurrence mass)`). The fourth column the cache now
carries is not free noise; it is half-constrained by the count already present.
Conservation made a theorem: what moves is locked to what was there.

The proof stays axiom-free by routing around `Int` associativity (core's
`add_assoc`/`add_comm`/`neg_add` all carry `propext`; probed 2026-06-08). The
kernel is small: `negate` preserves parity (`-x ≡ x mod 2`, `intPar_neg`), the
mark is only ever 0 or 1, and a parity homomorphism on those two moves
(`int_zero_add` for 0, `intPar_one_add` for 1) carries the induction. The
alternating fold and the counting fold, fed the same marks, never drift. -/

/-- Parity of a `Nat`, by twos. -/
def natPar : Nat → Bool
  | 0 => false
  | 1 => true
  | n + 2 => natPar n

/-- Parity of an `Int`: the parity of its magnitude. -/
def intPar : Int → Bool
  | Int.ofNat n => natPar n
  | Int.negSucc n => natPar (n + 1)

/-- Successor flips parity — by the three base patterns, the recursive case
    `rfl`-reducing through `natPar`'s by-twos definition. -/
theorem natPar_succ : ∀ n : Nat, natPar (n + 1) = !(natPar n)
  | 0 => rfl
  | 1 => rfl
  | n + 2 => by
      show natPar (n + 1) = !(natPar n)
      exact natPar_succ n

/-- **Negation preserves parity** — the kernel: `-x ≡ x (mod 2)`. By cases,
    `rfl` in each (`Int.neg` lands each magnitude on the same parity). -/
theorem intPar_neg : ∀ y : Int, intPar (-y) = intPar y
  | Int.ofNat 0 => rfl
  | Int.ofNat (_ + 1) => rfl
  | Int.negSucc _ => rfl

/-- Adding one flips parity — the only `Int` addition the congruence needs (the
    mark is always 0 or 1). The `negSucc` arm crosses zero through `subNatNat`;
    `subNatNat 1 (k+2)` reduces to `negSucc k`, and the depth-zero case is
    concrete. -/
theorem intPar_one_add : ∀ y : Int, intPar (1 + y) = !(intPar y)
  | Int.ofNat n => by
      show natPar (1 + n) = !(natPar n)
      rw [nat_add_comm 1 n, natPar_succ n]
  | Int.negSucc 0 => by decide
  | Int.negSucc (k + 1) => by
      show natPar (k + 1) = !(natPar k)
      rw [natPar_succ k]

/-- The alternating fold's cons step, in components: a mark (0 or 1) plus the
    negation of the prior reading (`alt_shift` + the pair arithmetic). -/
theorem alt_re_cons {S : Type} [DecidableEq S] (x : S) (l : List S) (s : S) :
    (alt (x :: l) s).re = (if x = s then (1 : Int) else 0) + (-(alt l s).re) := by
  show ((if x = s then GInt.one else GInt.zero).add (GInt.negate (alt l s))).re
     = (if x = s then (1 : Int) else 0) + (-(alt l s).re)
  rw [ite_mk (x = s)]
  rfl

/-- **The workhorse: alt's parity is the count's parity.** The alternating
    reading and the raw occurrence count never drift mod 2 — fed the same mark
    each step, and `negate` (the only difference between the folds) preserves
    parity. By induction; the mark splits 1 (flip both) / 0 (flip neither). -/
theorem alt_parity_eq_freq {S : Type} [DecidableEq S] :
    ∀ (l : List S) (s : S), intPar (alt l s).re = natPar (Ledger.freq l s)
  | [], _ => rfl
  | x :: l, s => by
      rw [alt_re_cons]
      show intPar ((if x = s then (1 : Int) else 0) + (-(alt l s).re))
         = natPar ((if x = s then 1 else 0) + Ledger.freq l s)
      by_cases h : x = s
      · rw [if_pos h, if_pos h, intPar_one_add, intPar_neg, alt_parity_eq_freq l s,
            nat_add_comm 1 (Ledger.freq l s), natPar_succ]
      · rw [if_neg h, if_neg h, int_zero_add, intPar_neg, alt_parity_eq_freq l s,
            nat_zero_add]

/-- **bal ≡ alt (mod 2).** The two real characters of the dial share parity —
    the count at +1 and the alternating count at −1, locked together. The
    conserved congruence the held cache's fourth column rides: not free noise,
    but half-determined by the count already there. -/
theorem bal_alt_same_parity {S : Type} [DecidableEq S] (l : List S) (s : S) :
    intPar (alt l s).re = intPar (evalAt id l s).re := by
  rw [alt_parity_eq_freq, evalOne_eq_freq]
  rfl

end Foam
