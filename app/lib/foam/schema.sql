-- foam.field — a content-addressed directed graph, asserted (not migrated).
--
-- The whole file is idempotent (CREATE ... IF NOT EXISTS / CREATE OR REPLACE):
-- running it any number of times produces the same schema. Every claim in these
-- comments is meant to be checkable by running the file; nothing here describes
-- behavior the functions below don't actually produce.
--
-- Structure: `field` holds nodes (exactly one is flagged `identity`);
-- `composition` holds directed edges (prev -> next). Append-only — never UPDATE,
-- never DELETE, never merge rows; the graph only ever grows. Nodes and edges are
-- content-addressed: an id is a deterministic digest of structure, so identical
-- structure maps to the same row and repeated or concurrent writes deduplicate
-- instead of duplicating.
--
-- Degrades safely: with only the identity node and no edges, `recognize` returns
-- 'yield' and `deposit` writes nothing. (The Ruby caller maps a NULL/absent result
-- to :yield, so an unreachable or empty database behaves as a pass-through.)
--
-- A node carries no content — only its id, which is a digest of structure. What a
-- node "means" is not stored here.

CREATE SCHEMA IF NOT EXISTS foam;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Nodes. Exactly one row has identity = true (the identity node). Other rows are
-- content-addressed (see foam.deposit); their id is a digest, not random.
CREATE TABLE IF NOT EXISTS foam.field (
  id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identity boolean NOT NULL DEFAULT false
);

-- Exactly one identity node — enforced structurally (a partial unique index),
-- not by a race-prone insert.
CREATE UNIQUE INDEX IF NOT EXISTS foam_field_single_identity
  ON foam.field (identity) WHERE identity;

-- Insert the identity node once. Idempotent: present after any number of runs,
-- inserted at most once.
INSERT INTO foam.field (identity)
SELECT true
WHERE NOT EXISTS (SELECT 1 FROM foam.field WHERE identity);

-- Edges: prev -> next. Append-only — never UPDATE, never DELETE.
CREATE TABLE IF NOT EXISTS foam.composition (
  id   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prev uuid NOT NULL REFERENCES foam.field (id),
  next uuid NOT NULL REFERENCES foam.field (id)
);

-- Edges are unique by (prev, next): writing the same edge twice is a no-op
-- (deduplication), so the graph never holds duplicate parallel edges. Distinct
-- *paths* (sequences of edges) remain distinct over a graph of unique edges.
CREATE UNIQUE INDEX IF NOT EXISTS foam_composition_unique_edge
  ON foam.composition (prev, next);

-- recognize — walk the graph (a recursive CTE) and return 'yield' if any walk
-- reaches a node it cannot leave. From every node it follows edges forward,
-- carrying the path and refusing to revisit a node already on that path. That
-- no-revisit guard guarantees termination: the walk cannot loop. If an edge would
-- return to a node already on the path (a cycle), the walk does not follow it — it
-- stops there, so cycles are detected but never traversed.
--
-- Currently the only value this can return is 'yield' (or NULL when there are no
-- nodes). Other outcomes are designed but not implemented here. (Termination is
-- also proven in lean/Foam/Floor.lean.)
CREATE OR REPLACE FUNCTION foam.recognize() RETURNS text
  LANGUAGE sql STABLE
  AS $$
    WITH RECURSIVE walk(node, path) AS (
      -- seed: every record is a possible starting position
      SELECT f.id, ARRAY[f.id]
      FROM foam.field f
      UNION ALL
      -- step: follow an edge forward, never revisiting a node on this path
      SELECT c.next, w.path || c.next
      FROM walk w
      JOIN foam.composition c ON c.prev = w.node
      WHERE NOT (c.next = ANY (w.path))
    ),
    landed AS (
      -- terminal paths: the walk has no un-revisited edge left to follow
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

-- deposit — write a content-addressed node for the given path. The new node's id
-- is a deterministic digest (sha256, first 16 bytes) of the input array, so the
-- same input always produces the same node: repeated deposits of the same input
-- converge on one row (deduplication), never a new row each time. The id is
-- derived only from the input array, never from any message content.
--
-- Empty input returns the identity node's id and writes nothing. Otherwise: insert
-- the node and an edge identity -> node, both ON CONFLICT DO NOTHING (idempotent,
-- append-only). A deposit never changes what `recognize` returns (it only adds
-- nodes/edges, and `recognize` terminates regardless — see lean/Foam/Engine.lean).
CREATE OR REPLACE FUNCTION foam.deposit(input uuid[] DEFAULT '{}') RETURNS uuid
  LANGUAGE plpgsql AS $$
  DECLARE
    node_id   uuid;
    basepoint uuid;
  BEGIN
    SELECT id INTO basepoint FROM foam.field WHERE identity;
    -- empty input addresses to the identity node itself: nothing to write
    IF basepoint IS NULL OR cardinality(input) = 0 THEN
      RETURN basepoint;
    END IF;
    -- content-address: a deterministic 16-byte sha256 digest of the input, as uuid
    node_id := encode(substring(digest(input::text, 'sha256') FROM 1 FOR 16), 'hex')::uuid;
    INSERT INTO foam.field (id, identity) VALUES (node_id, false)
      ON CONFLICT (id) DO NOTHING;
    INSERT INTO foam.composition (prev, next) VALUES (basepoint, node_id)
      ON CONFLICT (prev, next) DO NOTHING;
    RETURN node_id;
  END;
  $$;

-- walk — one pass: compute the outcome (recognize) and deposit the input, in a
-- single call. Returns the outcome. With empty input, deposit writes nothing, so
-- an empty-input walk is exactly `recognize`.
CREATE OR REPLACE FUNCTION foam.walk(input uuid[] DEFAULT '{}') RETURNS text
  LANGUAGE plpgsql AS $$
  DECLARE
    outcome text;
  BEGIN
    outcome := foam.recognize();
    PERFORM foam.deposit(input);
    RETURN outcome;
  END;
  $$;
