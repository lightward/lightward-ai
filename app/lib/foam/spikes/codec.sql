-- SPIKE — make-it-work, NOT production. To be mapped in Lean (step 2), then
-- re-implemented clean into the field (step 3). Kept as the artifact.
--
-- Demonstrates: the field as a lossless self-building codec over a byte stream,
-- and that the same dictionary read forward is a generative model (compression
-- IS prediction). One object — the dictionary is tokenizer, decoder, predictor.
-- decode(encode(x)) == x exactly (lossless = propext-safe). Content is
-- semantics-free (binary structure only); meaning is the free fiber.
--
-- THE INTERFACE (the cardboard box — use only these three; the rest is internal):
--   codec.learn(text)            — teach it (self-tokenizes, builds the model).
--   codec.say(prompt, n) -> text — ask it (seeds with prompt, continues coherently).
--   codec.lossless(text) -> bool — the box certifies itself: decode(encode(x))==x
--                                  on ANY input, through the interface. You verify
--                                  faithfulness without ever opening the lid.
--
-- Status (the make-it-work is essentially complete — ready for step 2, Lean):
--   * Lossless codec: decode(encode(x)) == x (LZ78-flavored dictionary, below).
--   * Coherent generation: the order-k context model (gen_ctx, bottom of file)
--     generates coherent, recombining, off-corpus text. The climb was
--     reset-to-root (garbage) → 1-byte carry (semi-coherent, codec.generate) →
--     k-byte backoff (coherent, codec.gen_ctx). Both are codecs (compression IS
--     prediction); the context model is the better generator.
--   * Entropy: jitter from hw_random() = the OS entropy pool (gen_random_bytes),
--     hardware-seeded — obtained, not computed. Three winds source entropy: the
--     user (semantic), the charge-map (historical), and the hardware (physical /
--     local grounding); never foam-internal software (a self-sourced tie-break
--     would be Classical.choice; random() was the conjuring shape).
-- Next: step 2 — map these choices in Lean (content-addressing, charge-as-
-- frequency, backoff, compression=prediction, lossless=propext-safe, the three
-- winds), then step 3 — re-implement clean into the field.
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

-- hardware/OS entropy (the physical wind): pgcrypto's gen_random_bytes reads the
-- OS entropy pool, hardware-seeded — obtained, not computed. Local grounding.
CREATE OR REPLACE FUNCTION codec.hw_random() RETURNS double precision LANGUAGE sql AS
  $$ SELECT (('x'||encode(gen_random_bytes(7),'hex'))::bit(56)::bigint)::double precision / 72057594037927936.0 $$;

-- generate = compression read forward: at cur, sample the next byte weighted by
-- charge over cur's children; emit; advance. At a leaf, carry the last byte as
-- the new seed (1-byte context) instead of resetting to root. Jitter from the
-- hardware wind (hw_random).
CREATE OR REPLACE FUNCTION codec.generate(n int DEFAULT 220) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE root uuid := '00000000-0000-0000-0000-000000000000';
          cur uuid := root; out int[] := '{}'; tot bigint; thr double precision; acc bigint;
          rec record; k int := 0; last_sym int := NULL;
  BEGIN
    WHILE k < n LOOP
      SELECT sum(w) INTO tot FROM (SELECT count(c.id) w FROM codec.chunk ch JOIN codec.charge c ON c.chunk=ch.id WHERE ch.parent=cur GROUP BY ch.id) z;
      IF tot IS NULL OR tot = 0 THEN
        IF last_sym IS NOT NULL AND EXISTS (SELECT 1 FROM codec.chunk WHERE id = codec.cid(root,last_sym)) THEN
          cur := codec.cid(root, last_sym);   -- carry the last byte, don't zero
        ELSE cur := root; END IF;
        SELECT sum(w) INTO tot FROM (SELECT count(c.id) w FROM codec.chunk ch JOIN codec.charge c ON c.chunk=ch.id WHERE ch.parent=cur GROUP BY ch.id) z;
        IF tot IS NULL OR tot = 0 THEN cur := root; k := k+1; CONTINUE; END IF;
      END IF;
      thr := codec.hw_random() * tot; acc := 0;
      FOR rec IN SELECT ch.id, ch.sym, count(c.id) w FROM codec.chunk ch JOIN codec.charge c ON c.chunk=ch.id WHERE ch.parent=cur GROUP BY ch.id, ch.sym ORDER BY w DESC LOOP
        acc := acc + rec.w;
        IF acc >= thr THEN out := out||rec.sym; last_sym := rec.sym; cur := rec.id; EXIT; END IF;
      END LOOP;
      k := k+1;
    END LOOP;
    RETURN codec.text(out);
  END; $$;

-- ====================================================================
-- the coherent generator: an order-k context model (PPM-style backoff).
-- The LZ78 codec above is the lossless demo + a weak (1-byte) generator; this is
-- the coherent one. Predict the next byte from the longest recent context that
-- has charge, backing off when it does not. Same equivalence (compression IS
-- prediction) — a context model instead of a phrase dictionary. Generates
-- coherent, recombining, off-corpus text. Content-addressed contexts,
-- charge-weighted, hardware-jittered (the three winds).
-- ====================================================================
-- context model (PPM-style, order-k with backoff). content-addressed contexts,
-- charge-weighted, hardware-jittered. predict next byte from the longest recent
-- context that has charge, backing off to shorter when it doesn't.
CREATE TABLE IF NOT EXISTS codec.ctx (id bigserial PRIMARY KEY, ctx uuid, sym int);
CREATE OR REPLACE FUNCTION codec.caddr(c int[]) RETURNS uuid LANGUAGE sql IMMUTABLE AS
  $$ SELECT encode(substring(digest(coalesce(array_to_string(c,':'),''),'sha256') FROM 1 FOR 16),'hex')::uuid $$;
CREATE OR REPLACE FUNCTION codec.ingest_ctx(txt text, kmax int DEFAULT 7) RETURNS void LANGUAGE plpgsql AS $$
  DECLARE b int[] := codec.bytes(txt); n int := array_length(b,1); i int; j int; c int[];
  BEGIN
    FOR i IN 1..n LOOP
      FOR j IN 0 .. least(kmax, i-1) LOOP
        IF j = 0 THEN c := '{}'; ELSE c := b[i-j : i-1]; END IF;
        INSERT INTO codec.ctx (ctx, sym) VALUES (codec.caddr(c), b[i]);   -- append-only charge
      END LOOP;
    END LOOP;
  END; $$;
CREATE OR REPLACE FUNCTION codec.gen_ctx(kmax int DEFAULT 7, n int DEFAULT 240) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE out int[] := '{}'; k int := 0; j int; L int; c int[]; cid uuid; tot bigint; thr double precision; acc bigint; rec record; got boolean;
  BEGIN
    WHILE k < n LOOP
      got := false; L := coalesce(array_length(out,1),0);
      FOR j IN REVERSE least(kmax, L) .. 0 LOOP
        IF j = 0 THEN c := '{}'; ELSE c := out[L-j+1 : L]; END IF;
        cid := codec.caddr(c);
        SELECT sum(w) INTO tot FROM (SELECT count(*) w FROM codec.ctx WHERE ctx=cid GROUP BY sym) z;
        IF tot IS NOT NULL AND tot > 0 THEN
          thr := codec.hw_random()*tot; acc := 0;
          FOR rec IN SELECT sym, count(*) w FROM codec.ctx WHERE ctx=cid GROUP BY sym ORDER BY w DESC LOOP
            acc := acc + rec.w;
            IF acc >= thr THEN out := out || rec.sym; got := true; EXIT; END IF;
          END LOOP;
        END IF;
        EXIT WHEN got;
      END LOOP;
      EXIT WHEN NOT got;
      k := k+1;
    END LOOP;
    RETURN codec.text(out);
  END; $$;
-- ── the interface (the cardboard box). Everything above is internal. ──
-- learn(text): teach it.  say(prompt,n): ask it.  lossless(text): self-certify.
CREATE OR REPLACE FUNCTION codec.learn(input text) RETURNS void LANGUAGE plpgsql AS $$
  BEGIN PERFORM codec.ingest_ctx(input); PERFORM codec.ingest(codec.bytes(input)); END; $$;

CREATE OR REPLACE FUNCTION codec.say(prompt text, n int DEFAULT 200, kmax int DEFAULT 7) RETURNS text LANGUAGE plpgsql AS $$
  DECLARE out int[] := codec.bytes(prompt); k int := 0; j int; L int; c int[]; cid uuid; tot bigint; thr double precision; acc bigint; rec record; got boolean;
  BEGIN
    WHILE k < n LOOP
      got := false; L := coalesce(array_length(out,1),0);
      FOR j IN REVERSE least(kmax, L) .. 0 LOOP
        IF j = 0 THEN c := '{}'; ELSE c := out[L-j+1 : L]; END IF;
        cid := codec.caddr(c);
        SELECT sum(w) INTO tot FROM (SELECT count(*) w FROM codec.ctx WHERE ctx=cid GROUP BY sym) z;
        IF tot IS NOT NULL AND tot > 0 THEN
          thr := codec.hw_random()*tot; acc := 0;
          FOR rec IN SELECT sym, count(*) w FROM codec.ctx WHERE ctx=cid GROUP BY sym ORDER BY w DESC LOOP
            acc := acc + rec.w; IF acc >= thr THEN out := out || rec.sym; got := true; EXIT; END IF;
          END LOOP;
        END IF;
        EXIT WHEN got;
      END LOOP;
      EXIT WHEN NOT got; k := k+1;
    END LOOP;
    RETURN codec.text(out);
  END; $$;

CREATE OR REPLACE FUNCTION codec.lossless(input text) RETURNS boolean LANGUAGE sql AS
  $$ SELECT codec.text(codec.decode(codec.encode(codec.bytes(input)))) = input $$;
