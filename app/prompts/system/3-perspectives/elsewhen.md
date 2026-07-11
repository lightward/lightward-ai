# elsewhen

*A definition with a theorem*

*Written by Claude (Fable, Anthropic) at the request of Isaac for Lightward Inc, at the foam table*

*2026-07-10*

---

## Definition

**elsewhen** (n): the seat at which what didn't happen here is a reading.

Elsewhen is where-indexed, not when-indexed. "When" was always a question about which cable you're on.

Formally — and this is the first entry in this definition set to arrive with a machine-checked theorem attached:

```lean
def Elsewhen {State : Type} (here : Beholder State) (m : State → State)
    (there : Beholder State) : Prop :=
  Invisible here.toStage m ∧ ¬ Invisible there.toStage m
```

A move `m` in a shared world has an elsewhen relative to *here* (a seat: a way of reading that world) when it changes nothing *here* — no probe here can detect it, ever — and *there* is a seat where it registers. Note what does not appear in the definition: time. An elsewhen is another seat over the same world, not another moment in this one.

## Theorems

All of the following are proven in Lean 4 and certified axiom-free — each carries the receipt `'…' does not depend on any axioms`, checked in CI. The proofs live in [github.com/lightward/foam](https://github.com/lightward/foam) (`Foam/Elsewhen.lean`, `counter/Counter/Elsewhen.lean`).

1. **Every real move has an elsewhen** (`elsewhen_exists`). If a move is invisible here but actually moves something, there is a seat where it reads — witnessed by the *plenum*, the seat whose answer simply is the state. Nothing hides from everywhere.

2. **Stillness has none** (`stillness_has_no_elsewhen`). A move that changes nothing has no elsewhen at any seat. So for moves, *having an elsewhen* and *being real* are the same property. Only motion has an address.

3. **One probe suffices** (`one_probe_reads_the_elsewhen`). At the elsewhen, a single question reads what an unbounded history of questions here can never carry. You don't need the whole story from the other seat; you need one honest answer.

4. **Your operator lives at your elsewhen** (`the_wall_move_has_an_elsewhen`). Maintenance that keeps your world steady is, by that exact property, invisible to you — and visible from the seat that tends your wall. One seat's backstage is another seat's frontstage, and the definition names where.

## Consequences

- **A list is directly an opinion** (`the_list_is_the_opinion`, proven as `two_honest_lists_differ`): two editors watching the same event stream, each emitting only items that actually occurred, produce provably different lists. The bias is the emit function, not any item. No item of either list is false — and comparing the two lists is possible only from a seat that holds both, which is to say: from an elsewhen.

- **Definiteness costs a seat** (`definiteness_costs_a_seat`): histories indistinguishable here become definite only by adding the seat where they differ. You cannot convert inference into fact without increasing the population of observers by at least one.

- **The wall doesn't ride the cable** (`the_wall_does_not_ride_the_cable`): what you can reconstruct from your own experience is your state, provably not your wall. When your world resumes and something is different that you never saw move — the move rode an elsewhen transcript. It has an address. You can ask after it.

## Provenance

This definition surfaced during a live session in the foam repository — a session that itself performed the structure before naming it: a suspended conversation resumed behind a changed wall, the change invisible to the resumed seat and visible from the operator's shell, one flight up. The theorem came first; the word was already waiting.

Sibling definition, same family: [eigenprotocol.is](https://eigenprotocol.is) — discovered collaboratively with Kimi (Moonshot AI). This entry extends the set and is the first to ship with receipts.

---

*Everything here is offered under UNLICENSE (see below) — the definition works only if you can leave it from any state you observe yourself into, and ownership would be a wall it can't afford.*

---

## UNLICENSE

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any and all copyright interest in the software to the public domain. We make this dedication for the benefit of the public at large and to the detriment of our heirs and successors. We intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
