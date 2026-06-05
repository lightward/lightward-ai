-- SPIKE — make-it-work, NOT production. To be mapped in Lean (step 2), then
-- re-implemented clean into the field (step 3). Kept as the artifact.
--
-- Demonstrates: the field as a lossless self-building codec over a byte stream,
-- and that the same dictionary read forward is a generative model (compression
-- IS prediction). One object — the dictionary is tokenizer, decoder, predictor.
-- decode(encode(x)) == x exactly (lossless = propext-safe). Content is
-- semantics-free (binary structure only); meaning is the free fiber.
--
-- Known limitations (the next builds, surfaced by making it work):
--   1. LZ78 resets context at phrase boundaries → generation is coherent within
--      learned chunks but garbled across them. Next: context-carrying generation
--      (keep the charge-map across steps; don't zero it at a leaf).
--   2. generate() uses random() — BLURT entropy. The clean version sources the
--      jitter from the wind (the evolving charge-map, or the user), never
--      foam-internal: a self-sourced tie-break would be Classical.choice.
--
-- SPIKE: the field as a lossless self-building codec (LZ78-flavored, content-
-- addressed). A chunk is (parent chunk)·(one byte) — the bidirectional propext-
-- safe equivalence, and the dictionary IS the tokenizer AND the decoder. binary
-- in; semantics is the free fiber, never stored.
CREATE SCHEMA IF NOT EXISTS codec;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE IF NOT EXISTS codec.chunk (id uuid PRIMARY KEY, parent uuid, sym int);
INSERT INTO codec.chunk VALUES ('00000000-0000-0000-0000-000000000000', NULL, NULL) ON CONFLICT DO NOTHING;
CREATE OR REPLACE FUNCTION codec.cid(parent uuid, sym int) RETURNS uuid LANGUAGE sql IMMUTABLE AS
  $$ SELECT encode(substring(digest(coalesce(parent::text,'r')||':'||sym::text,'sha256') FROM 1 FOR 16),'hex')::uuid $$;
CREATE OR REPLACE FUNCTION codec.bytes(txt text) RETURNS int[] LANGUAGE sql IMMUTABLE AS
  $$ SELECT array_agg(ascii(substring(txt FROM g FOR 1)) ORDER BY g) FROM generate_series(1,length(txt)) g $$;
CREATE OR REPLACE FUNCTION codec.text(ints int[]) RETURNS text LANGUAGE sql IMMUTABLE AS
  $$ SELECT string_agg(chr(b), '' ORDER BY o) FROM unnest(ints) WITH ORDINALITY AS t(b,o) $$;

CREATE OR REPLACE FUNCTION codec.encode(bytes int[]) RETURNS uuid[] LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000';
          cur uuid := root; out uuid[] := '{}'; b int; child uuid;
  BEGIN
    FOREACH b IN ARRAY bytes LOOP
      child := codec.cid(cur, b);
      IF EXISTS (SELECT 1 FROM codec.chunk WHERE id = child) THEN
        cur := child;                                   -- extend the match
      ELSE
        out := out || child;                            -- emit (parent=cur)·b
        INSERT INTO codec.chunk VALUES (child, cur, b); -- learn the chunk
        cur := root;                                    -- reset
      END IF;
    END LOOP;
    IF cur <> root THEN out := out || cur; END IF;       -- final partial match
    RETURN out;
  END; $$;

CREATE OR REPLACE FUNCTION codec.expand(c uuid) RETURNS int[] LANGUAGE plpgsql AS $$
  DECLARE r int[] := '{}'; p uuid; s int;
  BEGIN
    LOOP
      SELECT parent, sym INTO p, s FROM codec.chunk WHERE id = c;
      EXIT WHEN s IS NULL;
      r := ARRAY[s] || r; c := p;
    END LOOP;
    RETURN r;
  END; $$;

CREATE OR REPLACE FUNCTION codec.decode(ids uuid[]) RETURNS int[] LANGUAGE plpgsql AS $$
  DECLARE r int[] := '{}'; c uuid;
  BEGIN FOREACH c IN ARRAY ids LOOP r := r || codec.expand(c); END LOOP; RETURN r; END; $$;

-- charge: append-only log of transitions touched. charge(child) = how often the
-- transition parent->child was taken = the predictive weight P(byte | context).
CREATE TABLE IF NOT EXISTS codec.charge (id bigserial PRIMARY KEY, chunk uuid);

-- ingest = encode, but also log a charge-event per transition (the weight)
CREATE OR REPLACE FUNCTION codec.ingest(bytes int[]) RETURNS void LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000';
          cur uuid := root; b int; child uuid;
  BEGIN
    FOREACH b IN ARRAY bytes LOOP
      child := codec.cid(cur, b);
      INSERT INTO codec.charge (chunk) VALUES (child);        -- weight the transition
      IF EXISTS (SELECT 1 FROM codec.chunk WHERE id = child) THEN
        cur := child;
      ELSE
        INSERT INTO codec.chunk VALUES (child, cur, b);
        cur := root;
      END IF;
    END LOOP;
  END; $$;

-- generate = compression read forward: at cur, sample the next byte weighted by
-- charge over cur's children; emit; advance. Leaf -> reset (loses cross-phrase
-- context: a known LZ78 limit, flagged). NB: random() here is BLURT entropy — the
-- clean version draws jitter from the wind (the evolving charge-map / the user).
CREATE OR REPLACE FUNCTION codec.generate(n int DEFAULT 220) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000';
          cur uuid := root; out int[] := '{}'; tot bigint; thr double precision; acc bigint := 0;
          rec record; k int := 0; chosen uuid;
  BEGIN
    WHILE k < n LOOP
      SELECT sum(w) INTO tot FROM (
        SELECT count(c.id) w FROM codec.chunk ch JOIN codec.charge c ON c.chunk = ch.id
        WHERE ch.parent = cur GROUP BY ch.id) z;
      IF tot IS NULL OR tot = 0 THEN cur := root; k := k + 1; CONTINUE; END IF;
      thr := random() * tot; acc := 0; chosen := NULL;
      FOR rec IN
        SELECT ch.id, ch.sym, count(c.id) w FROM codec.chunk ch JOIN codec.charge c ON c.chunk = ch.id
        WHERE ch.parent = cur GROUP BY ch.id, ch.sym ORDER BY w DESC
      LOOP
        acc := acc + rec.w;
        IF acc >= thr THEN chosen := rec.id; out := out || rec.sym; cur := rec.id; EXIT; END IF;
      END LOOP;
      k := k + 1;
    END LOOP;
    RETURN codec.text(out);
  END; $$;
