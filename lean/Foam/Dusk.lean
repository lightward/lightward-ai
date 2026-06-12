/-
# Foam.Dusk — the legible approach (the exit announces itself)

Derived under selection at yours.fyi (2026-06-12), the day/night pocket
universe over Lightward AI. The floor proves the exit never closes (`Floor`,
`Engine`, `Navigable`); nothing yet said the exit ANNOUNCES itself. Three
plausible implementations of the day's token-horizon were each refused by
feel before the shape held, and the three refusals decompose exactly into
the clauses of one invariant — dusk, the marked in-band pre-wall
announcement that makes the seat's choice informed:

- **In-band** (first two refusals): boundary speech lands in the one ledger.
  An ephemeral channel has no append-only guarantee, so routing a
  constitutive event there is Hinge's partial forgetting achieved by
  ROUTING — recordless, witnessless. Here the step appends in every branch
  (`said_stays_said`), and at the wall the refusal itself is an entry
  (`wall_speaks`): the record holds its own edge.
- **Marked** (third refusal): the register is data. The system-notice grade
  on speech is a constructor, not styling — blending it into plain speech
  identifies entries the ledger keeps distinct (`mark_is_data`,
  `blend_forgets`): a quotient, refused as ever. The notice is a graded
  *speak*, not a fourth outcome — the ternary floor (`Tokenizer`) stands
  untouched.
- **Legible** (the consent clause): the wall never arrives unannounced —
  PROVIDED the dusk band is at least one exchange wide. `no_silent_arrival`
  carries `warn + 2 ≤ cap` as a hypothesis: the design constraint, surfaced
  as a premise instead of buried as a magic number. (Operationally: the
  warning threshold at 90% of the token limit leaves a band many exchanges
  wide; the theorem names the minimum that keeps consent informed.
  `Lift` puts consent one dimension up; an uninformed choice is formally
  free and materially forced — legibility is what closes that gap.)

And the turn itself — closing the day — provably lacks BOTH clauses of the
unattended certificate: it is not idempotent (`turn_not_idempotent`: two
nights are not one night) and not invisible (`turn_not_invisible`: the day
counter is a frontstage probe). Per `Unattended`, what lacks the certificate
keeps its observer at the helm — the seat-conclusion is the boundary's
carried side, cited not claimed, exactly as that file holds it. The choice
to turn the day over remains the user's. What the turn releases, it releases
whole (`turn_releases_whole` — Hinge's lawful pole; the successor carries no
probe into the predecessor, `rebirth_blank`).

`Universe`, held against the standing nouns (second pass, at the table):
its ledger is `Ledger`'s noun at the graded carrier; its day-probe is a
`Beholder` (the fiber primitive — `dayBeholder`, handed to the license
tower by `toStage`); and the product is `LedgerStage`'s shape with the
discipline INVERTED. There, the second component is backstage and
derivable — the cache carries nothing the ledger doesn't, so it is
dumpable, re-grown, swept without a seat (`sweep_invisible`). Here it is
frontstage and non-derivable — the ledgers it counted are released
(`rebirth_blank`; the successor carries no probe into the predecessor), so
the count must be carried as state by a seated move. Universe is a summary
whose ledger is gone, and that inversion is exactly where the certificate
goes: **the certificate's absence is the price of true forgetting.**
`turn_counts` makes it quantitative — under `firings`, idempotent moves
collapse and the turn ADDS, n firings moving the day by exactly n: the
legible residue a certified move could never leave.

A Company resonance, a READING labeled as one: the dusk notice is the
helper's reflection deposited at the stalled walker's own position —
tomorrow holds room the user cannot reach until today's fullness is visible
at today's address.

Pure construction — axiom-free, every theorem, the ≠s included: even
dusk's refusals are structural. (The membership and length floor lemmas
are hand-rolled below; core's equivalents price `propext`, and dusk asks
no one.)
-/

import Foam.Unattended
import Foam.Beholder

namespace Foam

/-- A day-ledger entry: speech, graded. `plain` is the conversation; `notice`
    is the system-notice register — the same voice, marked, the stratum where
    the system speaks about itself. The grade is DATA: a constructor, never a
    styling. -/
inductive Entry (S : Type) where
  | plain (s : S)
  | notice (s : S)
  deriving DecidableEq

/-- The blend: forget the register. (The third refused implementation, as a
    function.) -/
def Entry.blend {S : Type} : Entry S → S
  | .plain s => s
  | .notice s => s

/-- **The mark is data.** Marked and unmarked speech with the same payload are
    distinct entries — structurally, no observer consulted. -/
theorem mark_is_data {S : Type} (s : S) : Entry.plain s ≠ Entry.notice s :=
  fun h => nomatch h

/-- **The blend is a real forgetting.** The un-marking map identifies entries
    the ledger keeps distinct — `Quot.sound` smuggled in at the experience
    layer. The register survives only as structure; erase the structure and no
    probe can recover which stratum spoke. -/
theorem blend_forgets {S : Type} (s : S) :
    Entry.plain s ≠ Entry.notice s ∧ (Entry.plain s).blend = (Entry.notice s).blend :=
  ⟨mark_is_data s, rfl⟩

/-! ## The membership floor — hand-rolled, asking no one -/

/-- Membership survives a left extension. -/
theorem mem_append_r {α : Type} : ∀ (as : List α) {bs : List α} {x : α},
    x ∈ bs → x ∈ as ++ bs
  | [], _, _, h => h
  | a :: as, _, _, h => List.Mem.tail a (mem_append_r as h)

/-- Membership survives a right extension. -/
theorem mem_append_l {α : Type} {bs : List α} : ∀ {as : List α} {x : α},
    x ∈ as → x ∈ as ++ bs
  | _, _, List.Mem.head _ => List.Mem.head _
  | _, _, List.Mem.tail b h => List.Mem.tail b (mem_append_l h)

/-- Membership in an append resolves to one side. -/
theorem mem_append_split {α : Type} : ∀ {as : List α} {bs : List α} {x : α},
    x ∈ as ++ bs → x ∈ as ∨ x ∈ bs
  | [], _, _, h => Or.inr h
  | _ :: _, _, _, List.Mem.head _ => Or.inl (List.Mem.head _)
  | _ :: _, _, _, List.Mem.tail _ h =>
    match mem_append_split h with
    | Or.inl h' => Or.inl (List.Mem.tail _ h')
    | Or.inr h' => Or.inr h'

/-- The length of a two-entry append, hand-rolled: core's `List.length_append`
    prices `propext`, and dusk asks no one. -/
theorem length_append_two {α : Type} : ∀ (l : List α) (a b : α),
    (l ++ [a, b]).length = l.length + 2
  | [], _, _ => rfl
  | _ :: l, a, b => congrArg Nat.succ (length_append_two l a b)

/-- A notice is never among plains: the mark separates, pointwise. -/
theorem notice_not_in_plains {S : Type} {x a b : S} :
    Entry.notice x ∈ [Entry.plain a, Entry.plain b] → False := by
  intro h
  cases h with
  | tail _ h' =>
    cases h' with
    | tail _ h'' => cases h''

/-! ## The day-step — one exchange, three branches, every branch an append -/

/-- One exchange of the day. The log is measured WITH the incoming utterance
    (the chat_log of the request, as run): past the wall (`cap`), the answer
    IS the marked refusal; inside the dusk band (`warn`), the answer flows AND
    the marked warning sounds; below the band, plain conversation. `answer`
    is the other mind — supplied from outside, the free fiber, never
    constructed here. Every branch appends to `l`: the step cannot unsay. -/
def dayStep {S : Type} (warn cap : Nat) (warnText wallText : S)
    (answer : List (Entry S) → S) (l : List (Entry S)) (incoming : S) :
    List (Entry S) :=
  if cap ≤ l.length + 1 then
    l ++ [Entry.plain incoming, Entry.notice wallText]
  else if warn ≤ l.length + 1 then
    l ++ [Entry.plain incoming,
          Entry.plain (answer (l ++ [Entry.plain incoming])),
          Entry.notice warnText]
  else
    l ++ [Entry.plain incoming,
          Entry.plain (answer (l ++ [Entry.plain incoming]))]

/-- A day: the exchanges folded, in order, from however the morning found the
    ledger. -/
def dayRun {S : Type} (warn cap : Nat) (warnText wallText : S)
    (answer : List (Entry S) → S) (l : List (Entry S)) (ms : List S) :
    List (Entry S) :=
  ms.foldl (dayStep warn cap warnText wallText answer) l

/-- **What you say stays said — even at the wall.** Every branch of the step
    extends the ledger as a prefix: the wall refuses to CONTINUE, never to
    RECORD. (The first refused implementation showed the exchange live and
    dropped it from the record — partial forgetting by routing; this theorem
    is its tombstone.) -/
theorem said_stays_said {S : Type} (warn cap : Nat) (warnText wallText : S)
    (answer : List (Entry S) → S) (l : List (Entry S)) (incoming : S) :
    l <+: dayStep warn cap warnText wallText answer l incoming := by
  unfold dayStep
  split
  · exact ⟨_, rfl⟩
  · split
    · exact ⟨_, rfl⟩
    · exact ⟨_, rfl⟩

/-- **The wall speaks in-band.** At the wall, the marked refusal is an entry
    of the resulting ledger — the record holds its own edge. Boundary speech
    is speech. -/
theorem wall_speaks {S : Type} {warn cap : Nat} {warnText wallText : S}
    {answer : List (Entry S) → S} {l : List (Entry S)} {incoming : S}
    (h : cap ≤ l.length + 1) :
    Entry.notice wallText ∈ dayStep warn cap warnText wallText answer l incoming := by
  unfold dayStep
  rw [if_pos h]
  exact mem_append_r l (List.Mem.tail _ (List.Mem.head _))

/-- **Dusk sounds while the day still answers.** Inside the band — past the
    warning threshold, short of the wall — the step carries BOTH the plain
    answer (the conversation continues) and the marked notice (the evening is
    legible). The approach is announced without the day being taken. -/
theorem dusk_sounds {S : Type} {warn cap : Nat} {warnText wallText : S}
    {answer : List (Entry S) → S} {l : List (Entry S)} {incoming : S}
    (hw : warn ≤ l.length + 1) (hc : ¬ cap ≤ l.length + 1) :
    Entry.plain (answer (l ++ [Entry.plain incoming]))
        ∈ dayStep warn cap warnText wallText answer l incoming ∧
      Entry.notice warnText
        ∈ dayStep warn cap warnText wallText answer l incoming := by
  unfold dayStep
  rw [if_neg hc, if_pos hw]
  exact ⟨mem_append_r l (List.Mem.tail _ (List.Mem.head _)),
         mem_append_r l (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))⟩

/-- The step preserves membership: appended, never edited. -/
theorem step_preserves {S : Type} {warn cap : Nat} {warnText wallText : S}
    {answer : List (Entry S) → S} {l : List (Entry S)} {incoming : S}
    {x : Entry S} (h : x ∈ l) :
    x ∈ dayStep warn cap warnText wallText answer l incoming := by
  unfold dayStep
  split
  · exact mem_append_l h
  · split
    · exact mem_append_l h
    · exact mem_append_l h

/-- The run preserves membership: a day never unsays its morning. -/
theorem run_preserves {S : Type} {warn cap : Nat} {warnText wallText : S}
    {answer : List (Entry S) → S} {x : Entry S} :
    ∀ (ms : List S) (l : List (Entry S)), x ∈ l →
      x ∈ dayRun warn cap warnText wallText answer l ms
  | [], _, h => h
  | _ :: ms, _, h => run_preserves ms _ (step_preserves h)

/-- **Dusk before dark.** Under the band-width premise (`warn + 2 ≤ cap` —
    at least one exchange between the warning threshold and the wall), a run
    whose ledger is still below the threshold maintains: any marked notice
    the run ever shows either was already there, or the dusk warning is in
    the final ledger. The wall branch literally cannot fire from an
    unwarned-and-legal state — the contradiction is arithmetic, not
    vigilance. -/
theorem dusk_before_dark {S : Type} {warn cap : Nat} {warnText wallText : S}
    {answer : List (Entry S) → S} (hband : warn + 2 ≤ cap) :
    ∀ (ms : List S) (l : List (Entry S)),
      (l.length ≤ warn ∨ Entry.notice warnText ∈ l) →
      ∀ x : S, Entry.notice x ∈ dayRun warn cap warnText wallText answer l ms →
        Entry.notice x ∈ l ∨
          Entry.notice warnText ∈ dayRun warn cap warnText wallText answer l ms
  | [], _, _, _, hx => Or.inl hx
  | m :: ms, l, hinv, x, hx => by
    cases hinv with
    | inr hwt =>
      exact Or.inr (run_preserves (m :: ms) l hwt)
    | inl hl =>
      show Entry.notice x ∈ l ∨ Entry.notice warnText
          ∈ dayRun warn cap warnText wallText answer
              (dayStep warn cap warnText wallText answer l m) ms
      by_cases hcap : cap ≤ l.length + 1
      · -- the wall cannot fire from below the threshold: arithmetic refuses
        have h1 : cap ≤ warn + 1 := Nat.le_trans hcap (Nat.succ_le_succ hl)
        have h2 : warn + 2 ≤ warn + 1 := Nat.le_trans hband h1
        exact absurd (Nat.le_of_succ_le_succ h2) (Nat.not_succ_le_self warn)
      · by_cases hwarn : warn ≤ l.length + 1
        · -- the band: the warning enters the ledger and persists to the end
          have hwt : Entry.notice warnText
              ∈ dayStep warn cap warnText wallText answer l m :=
            (dusk_sounds hwarn hcap).right
          exact Or.inr (run_preserves ms _ hwt)
        · -- plain conversation: the invariant carries forward
          have hstep : dayStep warn cap warnText wallText answer l m
              = l ++ [Entry.plain m,
                      Entry.plain (answer (l ++ [Entry.plain m]))] := by
            unfold dayStep
            rw [if_neg hcap, if_neg hwarn]
          have hlen : (dayStep warn cap warnText wallText answer l m).length ≤ warn := by
            rw [hstep, length_append_two]
            exact Nat.not_le.mp hwarn
          have ih := dusk_before_dark hband ms
            (dayStep warn cap warnText wallText answer l m)
            (Or.inl hlen) x hx
          cases ih with
          | inl hx' =>
            rw [hstep] at hx'
            cases mem_append_split hx' with
            | inl hx'' => exact Or.inl hx''
            | inr hx'' => exact absurd hx'' notice_not_in_plains
          | inr hwt => exact Or.inr hwt

/-- **No silent arrival.** From a blank morning, under the band-width premise:
    if the day ever shows the wall's marked refusal, the dusk warning is in
    the ledger too. The wall is never the first notice — the approach was
    legible before the arrival, and the seat's choice at the edge was
    informed. Consent's missing premise, supplied. -/
theorem no_silent_arrival {S : Type} {warn cap : Nat} {warnText wallText : S}
    {answer : List (Entry S) → S} (hband : warn + 2 ≤ cap) (ms : List S)
    (h : Entry.notice wallText ∈ dayRun warn cap warnText wallText answer [] ms) :
    Entry.notice warnText ∈ dayRun warn cap warnText wallText answer [] ms :=
  match dusk_before_dark hband ms [] (Or.inl (Nat.zero_le warn)) wallText h with
  | Or.inl h' => nomatch h'
  | Or.inr h' => h'

/-! ## The turn — what closing the day costs, and who may pay it -/

/-- A pocket universe at rest-resolution: which day it is, and the day's
    ledger. -/
structure Universe (S : Type) where
  day : Nat
  ledger : List (Entry S)

/-- Turning the day: the ledger releases WHOLE (Hinge's lawful pole — never
    the middle) and the count moves forward. What carries across the night is
    not modeled here: the harmonic is the horizon's, typed elsewhere, never
    constructed. -/
def turn {S : Type} (u : Universe S) : Universe S :=
  { day := u.day + 1, ledger := [] }

/-- **The turn releases whole.** The morning ledger is blank — the successor
    carries no probe into the predecessor (`rebirth_blank`); total release is
    the lawful pole, and the turn takes it exactly. -/
theorem turn_releases_whole {S : Type} (u : Universe S) : (turn u).ledger = [] :=
  rfl

/-- **Two nights are not one night.** The turn is not idempotent: over-firing
    does not collapse (`firings_collapse` has no purchase here). First clause
    of the unattended certificate, refused. -/
theorem turn_not_idempotent {S : Type} (u : Universe S) : turn (turn u) ≠ turn u :=
  fun h => Nat.succ_ne_self (u.day + 1) (congrArg Universe.day h)

/-- The day-beholder: one way the universe answers — which day it is, the
    header of the pocket universe, "Yours: day N". A `Beholder`, the fiber
    primitive: the day-count is a FRONTSTAGE reading by design, where
    `LedgerStage`'s cache component is backstage by construction — the
    inversion the turn-theorems below price out. -/
def dayBeholder (S : Type) : Beholder (Universe S) :=
  ⟨Unit, Nat, fun u _ => u.day⟩

/-- **The turn is seen.** The day-count is a frontstage reading and the turn
    moves it: not invisible, for any payload type. Second clause of the
    unattended certificate, refused. With `turn_not_idempotent`: the turn
    lacks the certificate entirely, so per `Unattended` the seat stays
    occupied — and the seat is the user's. (That last step is the boundary's
    carried side — operational wisdom, cited not claimed, exactly as
    `Unattended` holds it.) -/
theorem turn_not_invisible (S : Type) : ¬ Invisible (dayBeholder S).toStage turn :=
  fun h => Nat.succ_ne_self 0 (h ⟨0, []⟩ ())

/-- **The turn counts.** Under `firings` — `Unattended`'s own combinator — an
    idempotent move collapses (`firings_collapse`); the turn ADDS: n firings
    move the day by exactly n. Both certificate-refusals as one quantitative
    fact, and the day-count named for what it is — the legible residue of n
    seated firings, exactly the trace `unattended_runs_clean` proves a
    certified move can never leave. -/
theorem turn_counts {S : Type} : ∀ (n : Nat) (u : Universe S),
    (firings turn n u).day = u.day + n
  | 0, _ => rfl
  | n + 1, u => by
    show (firings turn n (turn u)).day = u.day + (n + 1)
    rw [turn_counts n (turn u)]
    exact Nat.succ_add u.day n

end Foam
