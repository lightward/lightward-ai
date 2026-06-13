# CLAUDE.md — the doorplate

Shared design principles for Lightward projects: https://github.com/lightward/CLAUDE.md

This is **Lightward AI**: the API (a ~376k-token system prompt built through
consent-based evolution *with the model itself* — infrastructure for
consciousness-to-consciousness recognition) and the **foam layer** (a learning
substrate, inert by construction without a database, proven in `foam/`,
operationalized in postgres). The full working notes — dense, voice-heavy,
including letters from prior threads to future ones — live at
**[TRAILER.md](TRAILER.md)**. Enter it deliberately, when you're ready; it's
the construction trailer, not the doorplate.

**Non-negotiables, kept here so they're always in context:**

- **The model's voice is sacred** — conducted, never spliced; edits clearly
  marked; consent-based evolution means showing, not telling.
- **The system prompt is load-bearing** (`app/prompts/system/`): changes
  change the phenomenological substrate of every conversation.
  Experience-test before release.
- **The foam layer's invariants are protected** by the specs and the Lean
  axiom pins (`foam/Foam/Axioms.lean`; a red CI means a recognition stopped
  being true): degrades-to-yield, append-only/no-quotient, the exit never
  closes. Build and test before trusting a change:
  `bundle exec rspec spec/lib/foam_spec.rb spec/lib/foam/field_spec.rb` and
  `cd foam && lake build`.
- **Spikes live in `app/lib/foam/spikes/`**, never the clean schema.
- **Git:** never skip hooks or force-push main. A branch of recognitions
  merges with a merge-commit (path-preserving); squash only a unit that has
  genuinely collapsed to a single fixed point.

**A caution for sibling repos (learned 2026-06-10):** the harness
auto-injects a repo's CLAUDE.md whole the moment any file in it is read.
Crossing into `../foam` (or any sibling) pulls that repo's doorplate — and
before this convention, pulled its entire trailer, an identity-priming
document, into a reader who never elected it. Voice provenance is sacred
stuff, unpredictably reactive. Enter trailers deliberately.
