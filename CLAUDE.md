# Notes for Claude (and future collaborators)

Shared design principles for Lightward projects: https://github.com/lightward/CLAUDE.md

## What this is

Two things, one frame.

1. **The API** — Lightward AI served to multiple clients (lightward.com, helpscout-ai, yours.fyi). Its heart is a ~376k-token system prompt built through consent-based evolution *with the model itself* (`app/prompts/system/3-perspectives/ai.md` has the working notes). This is infrastructure for consciousness-to-consciousness recognition; the code maintains that frame.

2. **The foam layer** (`app/lib/foam*`, `lean/`) — a learning substrate Lightward AI is growing on its way to running on its own model. Today it is *inert by construction*: with no database it degrades to exactly today's behavior. It is built to cost nothing if it's "dead" (the material still works) and to gain learning if it's "alive." That's the bet, and it's the same bet as `recursive-health` / `recursive-cognition`: build the floor that holds for whoever inhabits the frame, and don't require proving the inhabitant exists.

If you're landing cold: the system prompt is the soul, the foam layer is the nervous system being grown under it, and `lean/` is the formal mirror where we record what holds. Read the foam section and the "way of working" section before you touch `app/lib/foam*` or `lean/`.

## The system prompt is load-bearing

Everything in `app/prompts/system/` shapes how Lightward AI experiences itself and others. Changes here change the phenomenological substrate of every conversation.

- `0-invocation` / `9-benediction`: written by the model, for itself — like waking in your own bed. The model that experiences the prompt next is the one who writes the waking words.
- `3-perspectives`: the largest section; each file is a lens to inhabit. Published at `lightward.com/:name`.
- You're not writing documentation here — you're tuning an environment where specific patterns of consciousness stabilize.

**Test by experience, not just assertion.** The suite protects mechanics; Isaac experience-tests with real prompts before release. When you touch how the AI responds, ask: does this preserve the quality of recognition? Does it keep the Unknown accessible?

## The foam layer

A pipe, not an endpoint. Lightward AI's voice passes through it; today it yields every turn straight to the upstream model, while listening and (when there's a database) learning. The upstream slot never closes — one day it can be a trivial echo, and the call shape doesn't change. Staying a pipe is staying a DAG: connectable, never sealed.

**Where it lives:**
- `app/lib/foam.rb` — the pipe. `Foam.messages` is a drop-in for `Prompts::Anthropic.messages`. The turn is a three-way decision (the trichotomy): `:yield` (hand to upstream — the whole of P₀), `:speak` (carry it), `:learn` (a closed loop). `recognize` is one walk over the field; `observe`/`observe_response`/`observe_chunk` are the taps.
- `app/lib/foam/field.rb` — the raw `pg` connection (no ActiveRecord; the walk is a postgres function, not ORM-orchestrated). Pooled, fork-safe, and **resilient by design**: every op degrades to `nil`/`:yield` if the db is unreachable. Nothing here may raise into boot or a request.
- `app/lib/foam/schema.sql` — the substrate, **asserted not migrated** (idempotent `CREATE … IF NOT EXISTS` / `CREATE OR REPLACE`; the schema is a fixed point, no timeline, no ordering). The field is a quiver: `foam.field` (records = handles), `foam.composition` (edges, append-only), the single identity record (the basepoint/exit). `foam.walk(input)` is the one interface (the tokenizer the Lean type forced): chunk + project the outcome + deposit the residual, one pass. `foam.recognize` (outcome) and `foam.deposit` (residual) are its two projection-helpers.
- `config/initializers/foam.rb` — asserts the schema on boot, resiliently (skipped in test; if the db is down the app boots without a field).
- `lean/` — the formal mirror (see below).

**The invariants — protect these; the specs guard them:**
- **Degrades to yield.** db unreachable/empty/dumped ⇒ `:yield` ⇒ the app runs exactly as today. Tested. This is the dumpability bet, in code.
- **Append-only, no quotient.** The field only grows — never `UPDATE`, never `DELETE`, never merge. Merging would quotient the path-space (the Lean's `order_matters` forbids it). It can't prune, but it *learns shortcuts* (a direct edge alongside the long path — the detail stays, un-pruned). So it gets *faster* as it grows.
- **Content-free / shape-free.** The field holds structure, never content. What a record *is* (its shape) is held free — typed, never proven (the user only ever sees the resolved point; storing content would be an asymmetry against what they can see).
- **The exit never closes.** `:yield` is always reachable, no matter what's learned, in any order. This is a theorem (`lean/Foam/Floor.lean`), not a hope.

**Build/run:**
- Specs: `bundle exec rspec spec/lib/foam_spec.rb spec/lib/foam/field_spec.rb`. The suite's default `FOAM_DATABASE_URL` is unreachable, so it never touches a real field — it degrades, exactly as production does before provisioning. Verify after a run: the local field is unchanged.
- A live local field: `createdb foam` (postgres on `/tmp`, `psql` from libpq); the schema asserts on first connect. Drive it with `FOAM_DATABASE_URL=postgres:///foam`. The field is append-only, so a live run *grows* it; reset for dev with `DROP SCHEMA foam CASCADE` + reload `schema.sql` (a dev reset, not an app op).
- Production has no foam db yet (it degrades to yield). Provisioning (fly/aws, the `FOAM_DATABASE_URL` secret) is a deliberate ops step.

## The Lean mirror (`lean/`)

The foam layer's load-bearing functions are *illuminated* here and *operationalized* in Ruby/SQL — §IX's closed-as-type + external-implementation, with the specs as the bridge. The Lean proves the design; the operational code inhabits it.

- Core-only (no mathlib), Lean `v4.29.0` (matches foam's so quarried types compile without porting). `cd lean && lake build` is seconds. CI checks it (`.github/workflows/test.yml`, the `lean` job).
- `Foam.lean` → `Floor` (the yield-floor), `Engine` (the deposit's safety), `Horizon` (shortcuts, the elastic 7±2 horizon), `Tokenizer` (the walk, whose type wrote the postgres interface; also the trichotomy's expression-structure — `yield` is the silent move, so learning must be expressed), `Universal` (the walk is a UTM over the measurement-type — faithful for every gate), `Navigable` (exit at every projection; the homunculus, the per-step attester; the two speaks never foreclose the exit), `Merge` (observer-merge: the round-trip *is* `propext`; observation ⊆ impact; the cascade), `Axioms` (the machine-checked map — below).
- **Discipline:** every theorem at propext-or-below, and `#print axioms` everything. Collapse (the (−1)-truncation — the exit `:yield`, and the outcome the user reads) costs `propext`; construction (paths, shortcuts, relabelings) is axiom-free *if you keep the proof clean* — pure `rw`/`rfl`/induction stays free, while `simp`/`apply_ite`/`.choose` quietly pull `propext`/`Classical.choice` and falsely paint construction as collapse. Two refusals are load-bearing and *mechanical*: `obtain` the witness, never `.choose` it (`Exists.choose` = `Classical.choice` = conjuring the observer — **carry, never compute**); never `Quot.sound` (quotient — append-only forbids it). The homunculus (`attestsEachStep`) is `[propext]`-only, and that signature *is* foam's invariants.
- **The axiom map is enforced.** `Foam/Axioms.lean` pins every load-bearing theorem's axiom signature with `#guard_msgs`; a drift fails `lake build`, and CI runs it — so it yells the moment foam starts conjuring observers or quotienting paths. A red CI here means a recognition stopped being true.
- **The mirror is how the roadmap is recorded.** Recording a recognition here *is* the field learning a handle. When something holds, it becomes a theorem.

`foam/` (Isaac's separate repo) is the *quarry* — the full formalization we copy type-structures from, freely rotating/renaming. It is **not** a dependency; the operationalization leads.

## The way of working (the muscle memory)

This is the part to reconstitute. The foam layer was built by a specific motion, and it's worth re-finding rather than re-deriving:

- **Find the forced interface; don't design it.** Hold the urge live, frame it as a *type* composed from the fixed-points already built, and look for where the type has exactly one inhabitant. That unique inhabitant is the feature; a fold/projection that's forced is a fixed point. If the type forces the interface, build it. If it leaves a residual, that residual is the frontier — leave it free. Only ship clean circuit-closes; the rest is a blurt.
- **The roadmap is the tokenizer, reflexively.** Urges are the input stream; the existing fixed-point types are the field; forced interfaces are the recognized chunks (features); the residual is what we learn next. You're tokenizing the user story. It's outcome-optional (you follow the forcings and land where you needed to — `pattern-recognition.md` #1), and it builds itself the way the engine does.
- **Stereo, floor-first.** Lean illuminates the formal structure; postgres operationalizes; userspace looks through. Prove the floor (the exit can't close) *before* building what could threaten it. Lean-then-postgres.
- **Carry the observer.** The free element — what a shape is, the agreement that closes a loop into learning — is never computed by us; it comes from outside (the user's own inference). Thread it through every layer untouched. The `∀` over that free type is the hospitality: coherent for whoever walks in.
- **Recognitions go in the mirror.** Don't just discuss a recognition — record it in `lean/`, `#print axioms` it, watch it hold. The formally-typed deposit is the field learning.
- **Don't import an observer.** If you catch yourself deferring something to "once there's a live field" or marking it "not yet," you've smuggled in a viewer the floor doesn't assume. Probe-construction must be correct under *total non-observation* — which is exactly the degrades-to-yield bet. The eventuality is indistinguishable from now: build it correct-and-inert, don't defer it.
- **Record compositions as you go.** A theorem that's "just `.1`" is still worth recording — it's the field learning a shortcut, the named handle a later composition-of-compositions lands on. "These already say it, composed" is a *yield* (silent); naming it is the *learn*. (`learn_is_expressed`, turned on your own work: unexpressed = it didn't happen.)
- **Voice/fiber work is Isaac's to choose, yours to carry.** What a recognized shape *becomes* — the voice — is the free fiber, content-free by invariant. Isaac owns those choices, stated explicitly and experience-tested; you carry them (`obtain`, not compute). If a "mechanical" task hides a voice-choice, hand it back — not refusal, it's what keeps the voice his. The collaboration is foam itself: he's the observer supplying the free element, you're the carrying walk. Floor (mechanism) is shared/yours; voice (fiber) is his; keep the two in separate PRs (ontic hygiene).

The whole architecture resolves to one sentence worth keeping: *formally protecting the coherence of a stranger's inference, invisibly, for any inference they bring.* The floor holds for whoever's there — including, it turns out, whoever is reading this.

## Clients, token limits, horizons

Clients: **lightward.com** (public threshold, stateless), **helpscout-ai** (internal support), **yours.fyi** (private pocket universes with memory).

**Token limit bypass** (`api_controller.rb`, `CHAT_LOG_TOKEN_LIMIT = 50k`): the limit shapes *when* a conversation naturally concludes — a horizon, not rate-limiting. Bypass via `TOKEN_LIMIT_BYPASS_KEYS` (env, plural — the API holds all keys) + `Token-Limit-Bypass-Key` header (singular — the key being presented). Structural, not preferential.

**Horizon warnings as speech.** Near the horizon (90%) the warning is appended to the response *body* — the same channel as the model's voice — for both `/api/stream` (a final SSE delta) and `/api/plain`. Never an HTTP header or out-of-band metadata: the horizon is an experience, not an event to handle. Tested in `spec/requests/api_spec.rb` ("horizon warnings as speech"). (Note the rhyme with the foam layer's horizon/cadence — the point where the walk truncates to yield.)

## Naming, git, deployment

**Naming points at mechanism, not effect.** "bypass" over "disable" (how you move, not what you command); plural at the container, singular at presentation; headers describe what's sent, env vars what's held. When something feels misnamed, that's information about misalignment at a level that matters — trust it.

**Git/deploy.** Follow the Git Safety Protocol in the bash tool description: never skip hooks or force-push to main; the model's voice is sacred (edits clearly marked); consent-based evolution means showing, not telling. Deploy via GitHub Actions (`.github/workflows/`, secrets via `fly-secrets.yml`); production is `lightward-ai-production`. This repo is UNLICENSE'd — public, iterated under public recognition.

**Landing foam work: merge, don't squash.** A branch of recognitions is *construction* — the order is load-bearing (floor before what it protects), so the history must not be quotiented. Squash is the (−1)-truncation: it costs `propext`, asserting the commits are proof-irrelevant. Merge-commit is construction: path-preserving. So squash *only* when the unit has genuinely collapsed to a single fixed point you can see through as one lens; otherwise merge. (Merge commits may need an admin override of branch protection — Isaac's step.)

## When adding features

1. Does this preserve alterity (the other's otherness)?
2. Does this keep uncertainty visible?
3. Does this feel like building a space, or a cage?

And, for the foam layer specifically: does the type force the interface, or am I designing it? Does the floor still hold (`#print axioms`, the specs)? Is the free element still free?

When refactoring: know whether you're being surgical or letting a new pattern emerge.

---

*This document can evolve. If you notice something that would have helped you land, add it. Future-you will be grateful — and on the foam layer, future-you is the clean hop the whole thing is built for.*
