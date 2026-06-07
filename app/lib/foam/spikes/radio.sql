-- SPIKE — the RADIO: the drain re-weighted by an angled reading. NOT production.
-- Lives in spikes/ on purpose — the proven floor (yield always reachable,
-- append-only, drains spend only positive count-charge) is the license to cook;
-- to be mapped in Lean where it isn't already, then re-implemented clean if it
-- sings. The mapped part precedes it this time: the gate-as-pairing is landed
-- (lean/Foam/Spectrum.lean: align / align_one / align_i / align_one_evalOne —
-- the dial of readings is a circle, the wind a point of it, the gate the
-- pairing floored at ground).
--
-- THE MODEL: every ledger event carries a phase — its position in the order,
-- mod 4 (the lossless order's own clock), as an angle k·π/2. The complex charge
-- of a continuation is its events' delta-signed unit-phases, summed. The TUNED
-- weight at wind-angle θ is the positive part of the projection along θ:
--
--   w_θ(ctx, sym) = max(0, Σ delta · cos(π/2·(id mod 4) − θ))
--
-- Sampling: among syms whose COUNT-balance is positive (the floor stays the
-- floor — the drain spends only positive count-charge; the radio re-weights
-- SELECTION, never the books), weighted by w_θ. Nothing loud at this angle ⇒
-- fall through the backoff: silent at this station, never negatively probable
-- (the Re-clamp is posPart generalized to every angle). θ is the WIND's —
-- supplied per call, never computed in here; a foam-internal choice of θ would
-- be the conjured observer.
--
-- Note the relation to the standing drain: foam.speak reads the PHASE-BLIND
-- charge (evaluation at 1 — align_one_evalOne: the pairing of the unit against
-- the id-evaluation IS the count). The stations here are projections of the
-- PHASED charge (evaluation at the quarter-turn). The legacy station and the
-- circle of new ones, one dial.

CREATE SCHEMA IF NOT EXISTS radio;

CREATE OR REPLACE FUNCTION radio.speak_tuned(seed int[], theta double precision,
    kmax int DEFAULT 7, max_steps int DEFAULT 600) RETURNS int[]
  LANGUAGE plpgsql AS $$
  DECLARE cb int[] := coalesce(seed,'{}'); out int[] := '{}'; k int := 0; j int; l int;
          c int[]; cid uuid; tot double precision; thr double precision;
          acc double precision; rec record; got boolean;
  BEGIN
    WHILE k < max_steps LOOP
      got := false; l := coalesce(array_length(cb,1),0);
      FOR j IN REVERSE least(kmax,l)..0 LOOP
        IF j = 0 THEN c := '{}'; ELSE c := cb[l-j+1 : l]; END IF;
        cid := foam.caddr(c);
        SELECT coalesce(sum(w), 0) INTO tot FROM (
          SELECT sym, sum(delta) AS bal,
                 greatest(0, sum(delta * cos(pi()/2 * (id % 4) - theta))) AS w
          FROM foam.charge WHERE ctx = cid GROUP BY sym
        ) z WHERE z.bal > 0 AND z.w > 0;
        IF tot > 0 THEN
          thr := foam.hw_random() * tot; acc := 0;
          FOR rec IN
            SELECT sym, w FROM (
              SELECT sym, sum(delta) AS bal,
                     greatest(0, sum(delta * cos(pi()/2 * (id % 4) - theta))) AS w
              FROM foam.charge WHERE ctx = cid GROUP BY sym
            ) z WHERE z.bal > 0 AND z.w > 0 ORDER BY w DESC
          LOOP
            acc := acc + rec.w;
            IF acc >= thr THEN
              out := out || rec.sym; cb := cb || rec.sym; got := true;
              INSERT INTO foam.charge (ctx, sym, delta) VALUES (cid, rec.sym, -1);  -- spends COUNT-charge, as ever
              EXIT;
            END IF;
          END LOOP;
        END IF;
        EXIT WHEN got;
      END LOOP;
      EXIT WHEN NOT got;                       -- silent at this station (or ground)
      k := k + 1;
    END LOOP;
    RETURN out;
  END; $$;
