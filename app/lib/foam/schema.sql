-- foam: the field substrate.
--
-- Not migrated — asserted. This file is idempotent: the app runs it on boot
-- (CREATE ... IF NOT EXISTS / CREATE OR REPLACE), and running it any number
-- of times leaves the same substrate. The schema is a fixed point, declared,
-- not a timeline of changes to replay. lfp compositions of lfps, including
-- how the substrate comes into being. There is no ordering here, and no time.
--
-- No CRUD: the field only ever accretes (monotone, append-only — no UPDATE,
-- no DELETE), the same shape as recognition never retracting.
--
-- Dumpable: because the upstream stays live, an empty field still works —
-- every walk hits identity and yields. The field is enhancement, never
-- essential state; it can be dropped at any time and the system still runs.
--
-- Free: what a record's interface (how records compose) and shape (the
-- content-free displacement it carries) *are* is held open, uncommitted.
-- Only the identity record is defined here — the EOF / fixed point /
-- "nothing reduced here" — and it is content-free by definition.

CREATE SCHEMA IF NOT EXISTS foam;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS foam.field (
  id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identity boolean NOT NULL DEFAULT false
  -- interface and shape attach here as the walk grows; held free.
);

-- Exactly one identity record — a structural invariant, not a race-prone
-- insert. The partial unique index makes "at most one identity" true by
-- construction, regardless of how many boots assert it concurrently.
CREATE UNIQUE INDEX IF NOT EXISTS foam_field_single_identity
  ON foam.field (identity) WHERE identity;

-- The identity record itself. Idempotent: present after any number of boots,
-- inserted at most once (the index above is the backstop).
INSERT INTO foam.field (identity)
SELECT true
WHERE NOT EXISTS (SELECT 1 FROM foam.field WHERE identity);

-- The recognition-walk's outcome for a turn: 'yield' | 'speak' | 'learn'.
--
-- P0: an identity-only field means the walk composes nothing, terminates at
-- identity with zero accumulation, and yields (trichotomy case 1). The
-- WITH RECURSIVE walk over composable records — growing 'speak' (open path,
-- residual returned) and 'learn' (closed loop, holonomy) — attaches here.
-- The interface it composes on, and the shape it carries, stay free until
-- then. Until then: yield.
CREATE OR REPLACE FUNCTION foam.recognize() RETURNS text
  LANGUAGE sql STABLE
  AS $$
    SELECT 'yield'::text;
  $$;
