-- SPIKE — OBSERVER-SCOPED ledger: inheritable scope, and the honest boundary it has.
-- NOT production (the production form adds observer/ancestor columns to foam.charge and
-- threads one scope filter through the reads). Honest make-it-work record. Two things
-- live here: a real, clean MECHANISM (a genuine product feature), and a pressure-test
-- that found where it does NOT reach.
--
-- THE MECHANISM. Each charge is tagged with its observer and that observer's ancestor;
-- the ancestry tree is SELF-DESCRIBED by the ledger (append-only, no separate mutable
-- table). A read at observer o sees o's records AND all its ancestors' — one extra
-- filter, observer = ANY(ancestry(o)). The whole foam read (depth/spectrum/born/speak)
-- composes the same way. Demonstrated below:
--   * a TRAINING ancestor T holds shared vocab; user observers A, B inherit it;
--   * A and B each have PRIVATE records, invisible to each other and to T (distinct
--     ontics as a WHERE clause; no downward leak);
--   * a row tagged observer=A is readable only inside A's scope — no replay/shotgun
--     across observers; terms inter-compose only along a legal ancestry.
-- This is the product shape: English-trained ancestor, per-user observer levels,
-- isolated and replay-proof — yours.fyi's private universes with a shared training root.
--
-- THE BOUNDARY (the pressure-test, measured not asserted). It is tempting to read this
-- as the native bipartite substrate for a two-observer quantum test (two private foams,
-- "no shared λ" → Bell-existence dissolved → the anti-distinguisher could crack into
-- ψ-ontic). It is NOT. A and B share ancestor T, and they both READ T — so T's records
-- ARE a shared classical λ. Bell binds: two observers measuring the shared inherited
-- form with independent winds give CHSH ≈ √2 (measured, foam.observer_chsh below) —
-- classical, ≤ 2, no crack. The observer-scoping relocates the shared λ to the
-- ancestor; it does not remove it. (Hand-constructing the PBR anti-distinguisher would
-- "succeed" by construction — that is the imposed-tensor artifact, not the foam.)
--
-- WHERE THE FOAM'S QUANTUM ACTUALLY IS. First-person. Each observer's OWN frontstage
-- has genuine Born interference — the dark fringe, count says present / Born says
-- silent (spikes/born_voice.sql, proven in lean/Foam/Born.lean). That is real and it
-- stands. What does NOT exist is an observer-INDEPENDENT, God's-eye multi-observer
-- quantum state to violate Bell — and that absence is the RAZOR, not a gap: the
-- other's foam is opaque (the foam-sim), you only ever read your own projection, and
-- any A-vs-B comparison happens inside ONE observer's frontstage. The foam is
-- relational this way: quantum WITHIN an observer, classical BETWEEN them; the shared
-- reality is the classical floor — the indistinguishability level where projections
-- coincide (the propext endpoint, the shared ancestor). (Frame named for the next
-- conversation, not asserted as proven — the interpretation is Isaac's to source.)

CREATE TABLE IF NOT EXISTS foam.charge_scoped (
  id bigserial PRIMARY KEY, observer uuid NOT NULL, ancestor uuid,
  ctx uuid NOT NULL, sym int NOT NULL, delta int NOT NULL
);

CREATE OR REPLACE FUNCTION foam.ancestor_of(o uuid) RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT ancestor FROM foam.charge_scoped WHERE observer = o AND ancestor IS NOT NULL LIMIT 1; $$;

-- the ancestry chain UP from o (self + all ancestors) — the read scope
CREATE OR REPLACE FUNCTION foam.ancestry(o uuid) RETURNS uuid[] LANGUAGE sql STABLE AS $$
  WITH RECURSIVE chain(obs) AS (
    SELECT o
    UNION
    SELECT foam.ancestor_of(chain.obs) FROM chain WHERE foam.ancestor_of(chain.obs) IS NOT NULL
  ) SELECT array_agg(obs) FROM chain; $$;

-- the core read, observer-scoped: a continuation's balance AS SEEN BY observer o
CREATE OR REPLACE FUNCTION foam.scoped_bal(o uuid, ctxbytes int[], s int) RETURNS bigint LANGUAGE sql STABLE AS $$
  SELECT coalesce(sum(delta),0) FROM foam.charge_scoped
   WHERE observer = ANY(foam.ancestry(o)) AND ctx = foam.caddr(ctxbytes) AND sym = s; $$;

-- THE BOUNDARY, measured: two observers sharing ancestor T each Born-measure the shared
-- inherited form with independent winds. Returns CHSH — ≈ √2, classical, no crack.
CREATE OR REPLACE FUNCTION foam.observer_chsh(form text) RETURNS double precision LANGUAGE plpgsql AS $$
  DECLARE n int := length(form);
          e00 double precision; e01 double precision; e10 double precision; e11 double precision;
  BEGIN
    WITH t AS (SELECT (substr(form,g,1))::int AS m FROM generate_series(1,n) g),
         o AS (SELECT  -- A reads T, B reads T (same shared form); each its own wind/basis
           CASE WHEN foam.hw_random() < power(cos(0       - m*pi()/2),2) THEN 1 ELSE -1 END a0,
           CASE WHEN foam.hw_random() < power(cos(pi()/4  - m*pi()/2),2) THEN 1 ELSE -1 END a1,
           CASE WHEN foam.hw_random() < power(cos(pi()/8  - m*pi()/2),2) THEN 1 ELSE -1 END b0,
           CASE WHEN foam.hw_random() < power(cos(-pi()/8 - m*pi()/2),2) THEN 1 ELSE -1 END b1 FROM t)
    SELECT avg(a0*b0),avg(a0*b1),avg(a1*b0),avg(a1*b1) INTO e00,e01,e10,e11 FROM o;
    RETURN e00 + e01 + e10 - e11;
  END; $$;

-- run the mechanism demo:
--   T,A,B as observers; T trains shared vocab; A,B inherit it, isolated from each other.
--   SELECT foam.ancestry('<A>'::uuid);                              -- {A, T}
--   SELECT foam.scoped_bal('<A>'::uuid, foam.bytes('hi'), ascii('t'));  -- inherited from T
-- run the boundary:
--   SELECT round(foam.observer_chsh((SELECT string_agg((random()<0.5)::int::text,'') FROM generate_series(1,4000)))::numeric, 3);
--   → ≈ 1.41 (√2): classical. The shared ancestor is a shared λ; the scoping does not crack it.
