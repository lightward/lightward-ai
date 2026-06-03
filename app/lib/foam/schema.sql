-- foam: the field substrate — a quiver.
--
-- Not migrated — asserted. Idempotent (CREATE ... IF NOT EXISTS / CREATE OR
-- REPLACE): running it any number of times leaves the same substrate, the schema
-- as a fixed point, not a timeline. No ordering, no time.
--
-- The field is a quiver, the operational face of the Lean floor
-- (lean/Foam/Floor.lean): records are the handles (generators), compositions are
-- the edges (which record composes after which), the identity record is the
-- terminal/basepoint (the exit). The recognition-walk is a path through it,
-- carried order-sensitively and terminated by no-revisit — the operational form
-- of `reachesYield_all`.
--
-- No CRUD, and append-only is *not* tidiness: merging or removing records would
-- quotient the path-space, which `order_matters` (in the Lean) forbids. The
-- quiver only ever grows edges; it never fuses or deletes nodes. So learning is
-- pure accretion (monotone, the same shape as recognition never retracting).
--
-- Dumpable: an empty field still works — the walk lands on yield (and the Ruby
-- layer degrades a NULL result to :yield), the upstream stays live. The field is
-- enhancement, never essential.
--
-- Free: what a record's interface and shape *are* is held open. Only the identity
-- record is defined — the EOF / fixed point / "nothing reduced here" — and it is
-- content-free by definition.

CREATE SCHEMA IF NOT EXISTS foam;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Records — the handles/generators of the quiver. The identity record is the
-- terminal/basepoint. Interface and shape attach here later; held free.
CREATE TABLE IF NOT EXISTS foam.field (
  id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identity boolean NOT NULL DEFAULT false
);

-- Exactly one identity record — a structural invariant, not a race-prone insert.
CREATE UNIQUE INDEX IF NOT EXISTS foam_field_single_identity
  ON foam.field (identity) WHERE identity;

-- The identity record itself. Idempotent: present after any number of boots,
-- inserted at most once.
INSERT INTO foam.field (identity)
SELECT true
WHERE NOT EXISTS (SELECT 1 FROM foam.field WHERE identity);

-- Compositions — the quiver's edges. `prev` composes into `next`. Append-only:
-- never UPDATE, never DELETE — that would quotient the path-space (order_matters
-- forbids it). The quiver only grows.
CREATE TABLE IF NOT EXISTS foam.composition (
  id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prev uuid NOT NULL REFERENCES foam.field (id),
  next uuid NOT NULL REFERENCES foam.field (id)
);

-- recognize — the path-carrying walk, a recursive CTE (the walk runs in the
-- substrate, not orchestrated from Ruby; one round-trip). From each record it
-- follows composition-edges, carrying the accumulated path order-sensitively and
-- refusing to revisit a record on the same path. That no-revisit is the
-- operational form of the Lean floor's termination (`reachesYield_all`): the walk
-- cannot loop, so it always lands.
--
-- P₀ — identity-only field, no edges — every walk is a single record that lands
-- immediately: 'yield'. 'speak' (an open path: residual returned) and 'learn' (a
-- closed path carrying holonomy) grow later, classified from the shape of `path`.
-- An empty field yields no landed paths → NULL → the Ruby layer degrades to
-- :yield. Either way the exit is never closed.
CREATE OR REPLACE FUNCTION foam.recognize() RETURNS text
  LANGUAGE sql STABLE
  AS $$
    WITH RECURSIVE walk(node, path) AS (
      -- seed: every record is a possible starting position
      SELECT f.id, ARRAY[f.id]
      FROM foam.field f
      UNION ALL
      -- step: compose forward along an edge, never revisiting (the floor's guard)
      SELECT c.next, w.path || c.next
      FROM walk w
      JOIN foam.composition c ON c.prev = w.node
      WHERE NOT (c.next = ANY (w.path))
    ),
    landed AS (
      -- terminal paths: the walk has nowhere left to compose (it has landed)
      SELECT w.path
      FROM walk w
      WHERE NOT EXISTS (
        SELECT 1
        FROM foam.composition c
        WHERE c.prev = w.node
          AND NOT (c.next = ANY (w.path))
      )
    )
    SELECT 'yield'::text
    FROM landed
    LIMIT 1;
  $$;

-- deposit — the engine's write-back. Append a record (a fresh node) and an edge
-- from the basepoint (identity) to it: the round-trip stepped out from the
-- origin, recorded as structure. Append-only (the field only grows — never
-- UPDATE, never DELETE, never merge); content-free (the node carries no shape;
-- held free); and agreement — what would identify this round-trip with an
-- existing handle and close a loop into learning — is left to come from outside.
-- The floor is edge-independent (lean/Foam/Engine.lean: floor_independent_of_
-- quiver), so this can never close the exit. Returns the new node id.
CREATE OR REPLACE FUNCTION foam.deposit() RETURNS uuid
  LANGUAGE plpgsql AS $$
  DECLARE
    node_id   uuid;
    basepoint uuid;
  BEGIN
    INSERT INTO foam.field (identity) VALUES (false) RETURNING id INTO node_id;
    SELECT id INTO basepoint FROM foam.field WHERE identity;
    IF basepoint IS NOT NULL THEN
      INSERT INTO foam.composition (prev, next) VALUES (basepoint, node_id);
    END IF;
    RETURN node_id;
  END;
  $$;

-- walk — the tokenizer, and the one interface the Lean type forced
-- (lean/Foam/Tokenizer.lean). One input-seeded pass over the field: chunk the
-- input against learned shortcuts, project the outcome, deposit the residual.
-- recognize and deposit are revealed as its two projections, not separate calls:
--   recognize = outcome(walk(input))   (the trichotomy, projected)
--   deposit   = walk(input).residual    (the un-recognized tail, learned)
--
-- P₀: no shortcuts → nothing chunks → the whole round-trip is residual → it's
-- deposited, and the outcome is 'yield'. 'speak'/'learn' grow as the match gate
-- (agreement, supplied from outside) begins to fire. `input` is the held path;
-- its content-free extraction is held free, so P₀ passes none.
CREATE OR REPLACE FUNCTION foam.walk(input uuid[] DEFAULT '{}') RETURNS text
  LANGUAGE plpgsql AS $$
  DECLARE
    outcome text;
  BEGIN
    -- chunk + project the outcome (P₀: nothing matches → yield)
    outcome := foam.recognize();
    -- learn: deposit the residual (P₀: the whole round-trip)
    PERFORM foam.deposit();
    RETURN outcome;
  END;
  $$;
