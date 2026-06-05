-- foam.field — a content-addressed chunk trie: the streaming codec's dictionary,
-- asserted (not migrated).
--
-- This is the operational inhabitant of the Lean formal layer (lean/Foam/). It is a
-- streaming implementation OF the proofs, not a port of the earlier spike
-- (app/lib/foam/spikes/codec.sql) — the spike provoked the formalism; the formalism
-- is the spec here. Each function below names the theorem it inhabits.
--
-- The whole file is idempotent (CREATE ... IF NOT EXISTS / CREATE OR REPLACE):
-- running it any number of times produces the same schema. Every claim in these
-- comments is meant to be checkable by running the file; nothing here describes
-- behavior the functions below don't actually produce.
--
-- Structure: `field` is a trie of chunks. A chunk is (parent, sym): its expansion
-- (the bytes it decodes to) is its parent's expansion followed by the one byte
-- `sym`. The single root (parent NULL, sym NULL) is the basepoint/exit. Append-only
-- — never UPDATE, never DELETE, never merge; the trie only grows. Chunks are
-- content-addressed: an id is a deterministic digest of (parent, sym), so identical
-- structure maps to the same row and repeated or concurrent writes deduplicate.
--
-- Content-free: a chunk stores its byte (`sym`) — binary *structure*, never
-- meaning. The codec is lossless over the bit stream; what those bits *mean* is the
-- free fiber, never stored here (decode reproduces the bytes; the reading is
-- whoever's who reads them).
--
-- Degrades safely: with only the root and no chunks, `recognize` returns 'yield'.
-- (The Ruby caller maps a NULL/absent result to :yield, so an unreachable or empty
-- database behaves as a pass-through.)

CREATE SCHEMA IF NOT EXISTS foam;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Chunks. A chunk is (parent, sym); the root has parent NULL, sym NULL. Non-root
-- ids are content-addressed (see foam.cid), not random.
CREATE TABLE IF NOT EXISTS foam.field (
  id     uuid PRIMARY KEY,
  parent uuid REFERENCES foam.field (id),
  sym    int
);

-- Exactly one root (the single node with no parent) — enforced structurally.
CREATE UNIQUE INDEX IF NOT EXISTS foam_field_single_root
  ON foam.field ((parent IS NULL)) WHERE parent IS NULL;

-- Find a chunk's children quickly (the recognize walk, and the encode match).
CREATE INDEX IF NOT EXISTS foam_field_parent ON foam.field (parent);

-- The root: a fixed id so the content-address is globally deterministic — the same
-- bytes map to the same chunk ids in any field (connection, not proliferation;
-- proven in lean/Foam/Path.lean). Inserted once, idempotent.
INSERT INTO foam.field (id, parent, sym)
  VALUES ('00000000-0000-0000-0000-000000000000', NULL, NULL)
  ON CONFLICT (id) DO NOTHING;

-- cid — the content-address of a chunk (parent, sym): a deterministic 16-byte
-- sha256 digest of the pair. The id is recursive through `parent`, so it encodes
-- the chunk's whole path from the root — identical paths address to the same id,
-- Merkle-style (lean/Foam/Path.lean, Path.edges_comp). The digest is of structure
-- (a parent id and a byte), never of meaning.
CREATE OR REPLACE FUNCTION foam.cid(parent uuid, sym int) RETURNS uuid
  LANGUAGE sql IMMUTABLE AS $$
    SELECT encode(
      substring(digest(coalesce(parent::text, 'root') || ':' || sym::text, 'sha256') FROM 1 FOR 16),
      'hex')::uuid
  $$;

-- charge — a SIGNED append-only log over trie transitions: +1 when the input walks a
-- transition (learn), −1 when the output drains it (speak). net(chunk) = sum(delta) =
-- the un-drained charge on the transition into `chunk`. Charge is a Nat: ground (0) is
-- the floor and the drain only removes positive charge — "relax toward ground, never
-- force past it" is the type, not a rule (proven in lean/Foam/Drain.lean). Append-only,
-- so the field stays LOSSLESS: every chunk and every charge-event remains in the
-- structure, contributing to what the field says, whether or not it is ever recalled
-- in order. Everything is in there, generative; nothing is replayed.
CREATE TABLE IF NOT EXISTS foam.charge (id bigserial PRIMARY KEY, chunk uuid, delta int);
CREATE INDEX IF NOT EXISTS foam_charge_chunk ON foam.charge (chunk);

CREATE OR REPLACE FUNCTION foam.net(chunk uuid) RETURNS bigint LANGUAGE sql STABLE AS
  $$ SELECT coalesce(sum(delta), 0) FROM foam.charge WHERE chunk = $1 $$;

-- the wind: OS entropy (hardware-seeded), obtained not computed — the discharge's
-- tie-break (never a foam-internal choice).
CREATE OR REPLACE FUNCTION foam.hw_random() RETURNS double precision LANGUAGE sql AS
  $$ SELECT (('x'||encode(gen_random_bytes(7),'hex'))::bit(56)::bigint)::double precision / 72057594037927936.0 $$;

-- recognize — walk the trie forward (a node to its children) and return 'yield' at
-- any node that cannot be left (a leaf). Content-addressing makes the trie acyclic
-- (a child's id depends on its parent's, so no edge can climb back up the path), so
-- the no-revisit walk always terminates. With only the root, the root is a leaf, so
-- an empty field yields. Currently 'yield' is the only outcome produced; others are
-- designed, not implemented here. (Termination/floor proven in lean/Foam/Floor.lean.)
CREATE OR REPLACE FUNCTION foam.recognize() RETURNS text
  LANGUAGE sql STABLE AS $$
    WITH RECURSIVE walk(node, path) AS (
      -- seed: every chunk is a possible starting position
      SELECT f.id, ARRAY[f.id] FROM foam.field f
      UNION ALL
      -- step: descend to a child, never revisiting a node on this path
      SELECT child.id, w.path || child.id
      FROM walk w
      JOIN foam.field child ON child.parent = w.node
      WHERE NOT (child.id = ANY (w.path))
    ),
    landed AS (
      -- terminal paths: no un-revisited child left to descend to
      SELECT w.path FROM walk w
      WHERE NOT EXISTS (
        SELECT 1 FROM foam.field child
        WHERE child.parent = w.node AND NOT (child.id = ANY (w.path))
      )
    )
    SELECT 'yield'::text FROM landed LIMIT 1;
  $$;

-- walk — the recognition turn's outcome projection (recognize). With the current
-- pipe, `input` is always empty; the residual deposit for a turn is the codec's job
-- (foam.encode_step over the byte stream, wired at the streaming tap), not this
-- call — so walk is exactly recognize. Kept for the Ruby caller's signature.
CREATE OR REPLACE FUNCTION foam.walk(input uuid[] DEFAULT '{}') RETURNS text
  LANGUAGE sql STABLE AS $$ SELECT foam.recognize() $$;

-- encode_step — one streaming pass of the emitting fold over a chunk of `bytes`,
-- resuming from `cursor` (the partial match carried across chunks; NULL starts at
-- the root). For each byte: form the candidate child = cid(cursor, byte); if the
-- trie knows it, extend the match (carry, emit nothing); else emit the candidate,
-- deposit it (append-only), and reset the cursor to the root. Returns the new
-- cursor and the emitted chunk ids. The dictionary (foam.field) grows append-only.
-- ← lean/Foam/Stream.lean (output = runEmit·runState), Codec.lean (encStep),
--   Engine.lean (append-only deposit). The flush is separate (foam.encode_flush,
--   EOS only), which is what lets the stream resume losslessly across chunks
--   (Stream.lean, output_resumes: carry the un-flushed cursor, flush at end only).
CREATE OR REPLACE FUNCTION foam.encode_step(cursor uuid, bytes int[],
                                            OUT next_cursor uuid, OUT emitted uuid[])
  LANGUAGE plpgsql AS $$
  DECLARE
    root  uuid := '00000000-0000-0000-0000-000000000000';
    cur   uuid;
    b     int;
    child uuid;
  BEGIN
    cur := coalesce(cursor, root);
    emitted := '{}';
    FOREACH b IN ARRAY coalesce(bytes, '{}') LOOP
      child := foam.cid(cur, b);
      INSERT INTO foam.charge (chunk, delta) VALUES (child, 1);  -- wind up +charge (learn)
      IF EXISTS (SELECT 1 FROM foam.field WHERE id = child) THEN
        cur := child;                                          -- extend the match
      ELSE
        emitted := emitted || child;                           -- emit (cur · b)
        INSERT INTO foam.field (id, parent, sym) VALUES (child, cur, b)
          ON CONFLICT (id) DO NOTHING;                         -- deposit, append-only
        cur := root;                                           -- reset
      END IF;
    END LOOP;
    next_cursor := cur;
  END;
  $$;

-- encode_flush — at end-of-stream, emit the leftover partial match (the `cursor`
-- chunk) if it is not the root. Valid ONLY at EOS: flushing mid-stream would emit a
-- different chunk sequence (lean/Foam/Stream.lean, output_resumes — the flush
-- belongs at the true end only). Zero or one chunk id.
CREATE OR REPLACE FUNCTION foam.encode_flush(cursor uuid) RETURNS uuid[]
  LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE
      WHEN cursor IS NULL OR cursor = '00000000-0000-0000-0000-000000000000'
        THEN '{}'::uuid[]
      ELSE ARRAY[cursor]
    END
  $$;

-- encode — the full (run-to-completion) encode of a byte array: the streaming fold
-- over the whole input, then the terminal flush. encode = runEmit ++ flush(final
-- state) — the blocking case is the streaming case taken to EOS (lean/Foam/Stream.lean,
-- output). Built from the streaming primitives, not beside them.
CREATE OR REPLACE FUNCTION foam.encode(bytes int[]) RETURNS uuid[]
  LANGUAGE plpgsql AS $$
  DECLARE step record; root uuid := '00000000-0000-0000-0000-000000000000';
  BEGIN
    SELECT * INTO step FROM foam.encode_step(root, bytes);
    RETURN step.emitted || foam.encode_flush(step.next_cursor);
  END;
  $$;

-- expand — the bytes a chunk decodes to: walk parent pointers to the root,
-- collecting syms (root has sym NULL, the exit). ← lean/Foam/Codec.lean, decode's
-- per-chunk inverse.
CREATE OR REPLACE FUNCTION foam.expand(chunk uuid) RETURNS int[]
  LANGUAGE plpgsql STABLE AS $$
  DECLARE r int[] := '{}'; p uuid; s int; c uuid := chunk;
  BEGIN
    LOOP
      SELECT parent, sym INTO p, s FROM foam.field WHERE id = c;
      EXIT WHEN s IS NULL;                 -- reached the root
      r := ARRAY[s] || r;
      c := p;
    END LOOP;
    RETURN r;
  END;
  $$;

-- decode — the bytes a chunk-id stream decodes to: expand each, concatenate.
-- ← lean/Foam/Codec.lean (decode = joinB). The round-trip decode(encode(x)) = x is
-- lossless_codec (dictionary-independent) — the box certifying itself.
CREATE OR REPLACE FUNCTION foam.decode(chunks uuid[]) RETURNS int[]
  LANGUAGE plpgsql STABLE AS $$
  DECLARE r int[] := '{}'; c uuid;
  BEGIN
    FOREACH c IN ARRAY coalesce(chunks, '{}') LOOP
      r := r || foam.expand(c);
    END LOOP;
    RETURN r;
  END;
  $$;

-- bytes / text — the text<->byte boundary (UTF-8). The codec works on bytes; the
-- voice arrives as text. Pure, structural.
CREATE OR REPLACE FUNCTION foam.bytes(txt text) RETURNS int[]
  LANGUAGE plpgsql IMMUTABLE AS $$
  DECLARE bin bytea := convert_to(txt, 'UTF8'); r int[] := '{}'; i int;
  BEGIN
    FOR i IN 0 .. octet_length(bin) - 1 LOOP r := r || get_byte(bin, i); END LOOP;
    RETURN r;
  END;
  $$;

CREATE OR REPLACE FUNCTION foam.text(ints int[]) RETURNS text
  LANGUAGE plpgsql IMMUTABLE AS $$
  DECLARE bin bytea := ''; v int;
  BEGIN
    FOREACH v IN ARRAY coalesce(ints, '{}') LOOP
      bin := bin || set_byte('\x00'::bytea, 0, v);
    END LOOP;
    RETURN convert_from(bin, 'UTF8');
  END;
  $$;

-- lossless — the box certifies itself: decode(encode(x)) = x on ANY input, through
-- the interface, without opening the lid. ← lean/Foam/Codec.lean, lossless_codec.
-- Compared at the byte level (the codec's fundamental claim). The encode (which
-- deposits) and the decode (which reads it back) are separate statements on
-- purpose: decode is STABLE, so it must run after encode's writes to see them —
-- exactly how real usage runs (the tap writes per chunk; reads come later).
CREATE OR REPLACE FUNCTION foam.lossless(input text) RETURNS boolean
  LANGUAGE plpgsql AS $$
  DECLARE src int[]; ids uuid[];
  BEGIN
    src := foam.bytes(input);
    ids := foam.encode(src);          -- write: tokenize + deposit
    RETURN foam.decode(ids) = src;    -- read: expand, seeing the deposit
  END;
  $$;

-- speak — discharge: drain charge into a voice. From the root, sample the next byte by
-- net charge over the current node's charged children (sample, never argmax — argmax
-- traps in the dominant cycle); emit it; drain it (−1); advance. On a stall, carry the
-- last byte (a 1-byte context); stop at ground (nothing charged) or the ceiling. The
-- emitted bytes are the voice; the residual is what was not drained. WEAK by design
-- (root-anchored, 1-byte context — the starting-weakly step); coherent suffix-context
-- generation is a later refinement. ← lean/Foam/Drain.lean (charge as Nat, drain toward
-- ground), Generator.lean (the fold read forward). hw_random is the wind, obtained.
CREATE OR REPLACE FUNCTION foam.speak(max_steps int DEFAULT 400) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000'; cur uuid := root; out int[] := '{}';
          tot bigint; thr double precision; acc bigint; rec record; k int := 0; last_sym int := NULL;
  BEGIN
    WHILE k < max_steps LOOP
      SELECT sum(foam.net(ch.id)) INTO tot FROM foam.field ch
       WHERE ch.parent = cur AND foam.net(ch.id) > 0;
      IF tot IS NULL OR tot = 0 THEN
        IF last_sym IS NOT NULL AND EXISTS (SELECT 1 FROM foam.field WHERE id = foam.cid(root, last_sym)) THEN
          cur := foam.cid(root, last_sym);                     -- carry the last byte
          SELECT sum(foam.net(ch.id)) INTO tot FROM foam.field ch
           WHERE ch.parent = cur AND foam.net(ch.id) > 0;
        END IF;
        IF tot IS NULL OR tot = 0 THEN EXIT; END IF;           -- drained to ground / stalled
      END IF;
      thr := foam.hw_random() * tot; acc := 0;
      FOR rec IN SELECT ch.id, ch.sym, foam.net(ch.id) w FROM foam.field ch
                 WHERE ch.parent = cur AND foam.net(ch.id) > 0 ORDER BY w DESC LOOP
        acc := acc + rec.w;
        IF acc >= thr THEN
          out := out || rec.sym; last_sym := rec.sym;
          INSERT INTO foam.charge (chunk, delta) VALUES (rec.id, -1);  -- drain (−charge)
          cur := rec.id; EXIT;
        END IF;
      END LOOP;
      k := k + 1;
    END LOOP;
    RETURN foam.text(out);
  END;
  $$;

-- outcome — the trichotomy for a turn (currently a weak gate): 'speak' if the field has
-- drainable charge (it can carry the turn from what it has learned), else 'yield' (hand
-- to the upstream — a living ancestor, or an echo). 'learn' (residual 0 — the round-trip
-- closed) is the post-discharge state, reached when speaking drains the charge to ground.
-- Degrades to 'yield' on an empty/unreachable field. The gate is structural (charge
-- presence), never a measure of meaning — that is the user's (lean/Foam, the razor).
CREATE OR REPLACE FUNCTION foam.outcome() RETURNS text LANGUAGE sql STABLE AS
  $$ SELECT CASE WHEN EXISTS (SELECT 1 FROM foam.field WHERE foam.net(id) > 0)
                 THEN 'speak' ELSE 'yield' END $$;
