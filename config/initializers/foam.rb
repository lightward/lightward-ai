# frozen_string_literal: true

# Assert the foam field on boot — idempotently (the schema is a fixed point,
# CREATE ... IF NOT EXISTS / CREATE OR REPLACE) and resiliently. If the
# field's database is unreachable, the app boots anyway and foam runs without
# a field: every walk yields, exactly as it does today. The field is
# enhancement, never essential, so asserting it must never break boot.
#
# Skipped in test — the field's own spec drives assertion explicitly, so the
# rest of the suite boots without touching a database.
Rails.application.config.after_initialize do
  Foam::Field.assert! unless Rails.env.test?
end
