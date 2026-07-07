# frozen_string_literal: true

# Warm the budget store connection at the tail of boot, off the request
# path: a machine finishes booting already connected, so its first budgeted
# request never races boot-time CPU for the connect (the source of
# cold-start "untracked" noise on auto-started machines). Fail-open like
# everything else — an unreachable store costs one bounded timeout here and
# nothing more.
#
# Safe without preload_app!: each worker boots the app after fork, so this
# runs in the process that will use the connection. Skipped in test (the
# suite stays hermetic) and when budgets are off (inert means inert — no
# boot-time dial for a store nothing will consult).
Rails.application.config.after_initialize do
  UsageBudget.warm! if UsageBudget.active? && !Rails.env.test?
end
