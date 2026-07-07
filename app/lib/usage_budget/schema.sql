-- app/lib/usage_budget/schema.sql
--
-- The shared-resource budget's substrate: fixed hour/day windows of request
-- and cost counters, keyed only by HMAC'd scope keys — never a raw IP, user
-- id, or conversation id. Asserted idempotently on boot (a fixed point, not
-- a migration), exactly like the foam field's schema. Rows age out after two
-- days; nothing here is a durable record of anyone.

CREATE SCHEMA IF NOT EXISTS lai_budget;

CREATE TABLE IF NOT EXISTS lai_budget.windows (
  scope_key     text        NOT NULL, -- HMAC hex digest, never a raw identifier
  window_kind   text        NOT NULL, -- 'hour' | 'day'
  window_start  timestamptz NOT NULL, -- UTC window boundary
  request_count bigint      NOT NULL DEFAULT 0,
  cost_usd      numeric     NOT NULL DEFAULT 0,
  PRIMARY KEY (scope_key, window_kind, window_start)
);

-- For the purge sweep (windows older than the day horizon).
CREATE INDEX IF NOT EXISTS windows_window_start_idx
  ON lai_budget.windows (window_start);
