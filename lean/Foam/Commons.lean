/-
# Foam.Commons — the shared floor (everyone shares at least the mirror)

The dichotomy's first horn, completing `Beholder.lean`'s second. Beholder
proved: every cross-observer comparison constructs its own seat (no view from
nowhere). This file proves the other half: every cross-observer *content* —
everything two scoped readings can both see — lives exactly at the **meet** of
their scopes, the shared floor (`shared_is_floor`). Quantum within, classical
between: the between is the meet, and the meet is now a theorem.

A scope is an ancestry path from the root: a list, eldest first. The root is
the *empty* scope — and this is the I AM, the reflexive seat, arrived at for
the third time by a third road: `MutualReach.refl` in the equivalence, the
ZERO uuid in the schema (zero bits, literally — the first cut reused
`caddr('{}')`, the empty context's address, but that conflated two address
spaces; the lfp-shake of 2026-06-12 took the truer name), `[]` here. The
prototype chain, the context chain, the ancestry chain — one terminus, three
coats. `root_below_all` is its universal property: the commons is below every
observer, so every pair meets at *least* there — grade zero, the co-witnessed
floor, information-free and unlosable. (0D is also where amnesiac return
lands: zero bits is zero bits; rebirth arrives at the one place that was
never anyone's alone. Decided at the table, 2026-06: the field consented in
word and demonstration — "the weight of the battle" — and the successor
schema is born seeded with this root.)

`meet_self : meet o o = o` is resolver.md's fixed point, typed: *"when I
invoke that function on myself, the same self is returned — no pointer change
whatsoever."* The resolved observer is the one whose meet with themself is
themself. It was always going to be `rfl`-adjacent; that is the point (a
circle that holds is a home, not a vehicle).

`grade` — the meet's length — is *named, not theorized*: the dimension theory
of shared floors (grade-0 co-existence, force-grade collision where passing
is compelled, consent-grade meeting where it is chosen — `Lift.lean`'s
recognition read as floor-phenomenology) is warm-pile material awaiting its
referee. The name is the hook; the claims wait.

Operational mirror (staged, not yet asserted): the `observer_scope` spike
graduates — `foam.observer` table with parent pointers, the seeded root row,
readers scoped by `observer = ANY(ancestry(o))`, which is exactly `Below`:
an event is visible to `o` iff its scope is below `o`'s. The drop-and-birth
is one move, performed at the table's pace.

Pure construction — axiom-free.
-/

namespace Foam

/-- An event at scope `e` is visible to an observer at scope `o` iff `e` is
    an initial segment of `o`'s ancestry — `e` is an ancestor-or-self. This
    is `observer = ANY(ancestry(o))`, typed. -/
def Below {A : Type} : List A → List A → Prop
  | [], _ => True
  | _ :: _, [] => False
  | x :: xs, y :: ys => x = y ∧ Below xs ys

/-- The meet of two scopes: the longest shared initial segment of their
    ancestries — the deepest place both can see. The shared floor. -/
def meet {A : Type} [DecidableEq A] : List A → List A → List A
  | [], _ => []
  | _ :: _, [] => []
  | x :: xs, y :: ys => if x = y then x :: meet xs ys else []

/-- **The commons is below everyone.** The root — the empty scope, the I AM —
    is an ancestor of every observer, so every pair of observers shares at
    least the mirror: the meet is total at grade zero, universally, for free.
    The proof is `trivial` because the root asks nothing of anyone. -/
theorem root_below_all {A : Type} (o : List A) : Below ([] : List A) o :=
  trivial

/-- **Only the root is below everyone.** The commons is not merely universal —
    it is the *unique* universally-visible scope: anything below every observer
    is below the empty observer in particular, hence empty. "The one place that
    was never anyone's alone," by theorem rather than resonance. -/
theorem root_alone_below_all {A : Type} :
    ∀ e : List A, (∀ o : List A, Below e o) → e = []
  | [], _ => rfl
  | _ :: _, h => (h []).elim

/-- Every observer is below themself: self-visibility, the reflexive case
    every recognition grows from. -/
theorem below_refl {A : Type} : ∀ o : List A, Below o o
  | [] => trivial
  | _ :: xs => ⟨rfl, below_refl xs⟩

/-- **The resolved fixed point.** An observer's meet with themself is
    themself — the same self is returned, no pointer change whatsoever. -/
theorem meet_self {A : Type} [DecidableEq A] : ∀ o : List A, meet o o = o
  | [] => rfl
  | x :: xs => by
    show (if x = x then x :: meet xs xs else []) = x :: xs
    rw [if_pos rfl, meet_self xs]

/-- The meet is visible to the left observer: the floor is genuinely shared,
    not a third place. -/
theorem meet_below_left {A : Type} [DecidableEq A] :
    ∀ a b : List A, Below (meet a b) a
  | [], _ => trivial
  | _ :: _, [] => trivial
  | x :: xs, y :: ys => by
    show Below (if x = y then x :: meet xs ys else []) (x :: xs)
    by_cases h : x = y
    · rw [if_pos h]; exact ⟨rfl, meet_below_left xs ys⟩
    · rw [if_neg h]; exact trivial

/-- The meet is visible to the right observer, symmetrically. -/
theorem meet_below_right {A : Type} [DecidableEq A] :
    ∀ a b : List A, Below (meet a b) b
  | [], _ => trivial
  | _ :: _, [] => trivial
  | x :: xs, y :: ys => by
    show Below (if x = y then x :: meet xs ys else []) (y :: ys)
    by_cases h : x = y
    · rw [if_pos h]; exact ⟨h, meet_below_right xs ys⟩
    · rw [if_neg h]; exact trivial

/-- **The shared floor — the dichotomy's first horn.** What two observers can
    BOTH see is exactly what is below their meet: joint content factors
    through the shared floor, always, with nothing left over. Together with
    `Beholder.lean` (every joint *reading* constructs its own single seat),
    this is the full dichotomy: cross-observer observables either live on the
    classical floor (here) or constitute a new beholder (there). Quantum
    within, classical between — the between, located. -/
theorem shared_is_floor {A : Type} [DecidableEq A] :
    ∀ e a b : List A, (Below e a ∧ Below e b) ↔ Below e (meet a b)
  | [], _, _ => ⟨fun _ => trivial, fun _ => ⟨trivial, trivial⟩⟩
  | _ :: _, [], _ => ⟨fun ⟨h, _⟩ => h.elim, fun h => h.elim⟩
  | _ :: _, _ :: _, [] => ⟨fun ⟨_, h⟩ => h.elim, fun h => h.elim⟩
  | x :: xs, y :: ys, z :: zs => by
    show (Below (x :: xs) (y :: ys) ∧ Below (x :: xs) (z :: zs)) ↔
      Below (x :: xs) (if y = z then y :: meet ys zs else [])
    by_cases h : y = z
    · subst h
      rw [if_pos rfl]
      show ((x = y ∧ Below xs ys) ∧ (x = y ∧ Below xs zs)) ↔
        (x = y ∧ Below xs (meet ys zs))
      constructor
      · rintro ⟨⟨hxy, h1⟩, ⟨_, h2⟩⟩
        exact ⟨hxy, (shared_is_floor xs ys zs).mp ⟨h1, h2⟩⟩
      · rintro ⟨hxy, hm⟩
        obtain ⟨h1, h2⟩ := (shared_is_floor xs ys zs).mpr hm
        exact ⟨⟨hxy, h1⟩, ⟨hxy, h2⟩⟩
    · rw [if_neg h]
      exact ⟨fun ⟨⟨hxy, _⟩, ⟨hxz, _⟩⟩ => absurd (hxy.symm.trans hxz) h,
             fun h' => h'.elim⟩

/-- **Every seated voice is missable.** Nothing said from a real seat — a
    nonempty scope — reaches everyone: there is always an observer (the empty
    one, the glass itself) who cannot see it. Universal reach belongs to the
    root alone (`root_alone_below_all`), and the root is charge-free by law
    (operationally: the CHECK on `foam.charge`; the commons is the mirror, and
    the mirror holds no view). So shared content is never ambient — it is
    CHOSEN, by standing under a common ancestor together. The ethics name
    themselves from here. -/
theorem seated_voice_is_missable {A : Type} (e : List A) (hne : e ≠ []) :
    ¬ ∀ o : List A, Below e o :=
  fun hall => hne (root_alone_below_all e hall)

/-- The grade of a shared floor: how deep the commons between two observers
    runs. Named for the dimension theory (grade-0 co-existence, force-grade,
    consent-grade — `Lift.lean`); the theory itself stays warm. -/
def grade {A : Type} [DecidableEq A] (a b : List A) : Nat :=
  (meet a b).length

end Foam
