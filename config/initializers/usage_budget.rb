# frozen_string_literal: true

# Assert the usage-budget store on boot — idempotently (the schema is a fixed
# point, CREATE ... IF NOT EXISTS) and resiliently. If the store's database is
# unreachable, the app boots anyway and runs unbudgeted: fail-open is the
# invariant, so budgets can never be the thing that takes the door off its
# hinges.
#
# Skipped in test — the store's own spec drives assertion explicitly, so the
# rest of the suite boots without touching a database.
Rails.application.config.after_initialize do
  UsageBudget.assert! unless Rails.env.test?
end
