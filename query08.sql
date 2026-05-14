/*
8.  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/

set search_path = public

SELECT owner1, COUNT(*)
FROM phl.pwd_parcels
WHERE owner1 ILIKE '%UNIV%' AND owner1 ILIKE '%PENN%'
GROUP BY owner1
ORDER BY COUNT(*) DESC;

SELECT owner2, COUNT(*)
FROM phl.pwd_parcels
WHERE owner2 ILIKE '%UNIV%' AND owner2 ILIKE '%PENN%'
GROUP BY owner2
ORDER BY COUNT(*) DESC;

SELECT COUNT(*) AS penn_parcels
FROM phl.pwd_parcels
WHERE
  (owner1 ILIKE '%UNIV%' AND owner1 ILIKE '%PENN%')
  OR
  (owner2 ILIKE '%UNIV%' AND owner2 ILIKE '%PENN%');

SELECT geog
FROM phl.pwd_parcels
WHERE
  (owner1 ILIKE '%UNIV%' AND owner1 ILIKE '%PENN%')
  OR
  (owner2 ILIKE '%UNIV%' AND owner2 ILIKE '%PENN%')
LIMIT 200;

WITH penn_campus AS (
  SELECT
    ST_UnaryUnion(
        ST_Collect(geog::geometry)
    ) AS geom
  FROM phl.pwd_parcels
  WHERE
    (owner1 ILIKE '%UNIV%' AND owner1 ILIKE '%PENN%')
    OR
    (owner2 ILIKE '%UNIV%' AND owner2 ILIKE '%PENN%')
)
SELECT geom
FROM penn_campus;

SET search_path = public, census;

WITH penn_campus AS (
  SELECT
    ST_UnaryUnion(
      ST_Collect(
        ST_MakeValid(geog::geometry)
      )
    ) AS geom
  FROM phl.pwd_parcels
  WHERE
    (owner1 ILIKE '%UNIV%' AND owner1 ILIKE '%PENN%')
    OR
    (owner2 ILIKE '%UNIV%' AND owner2 ILIKE '%PENN%')
)
SELECT
  COUNT(*)::int AS count_block_groups
FROM census.blockgroups_2020 bg
CROSS JOIN penn_campus pc
WHERE ST_CoveredBy(ST_MakeValid(bg.geog::geometry), pc.geom);


WITH penn_campus AS (
  SELECT ST_UnaryUnion(ST_Collect(ST_MakeValid(geog::geometry))) AS geom
  FROM phl.pwd_parcels
  WHERE (owner1 ILIKE '%UNIV%' AND owner1 ILIKE '%PENN%')
     OR (owner2 ILIKE '%UNIV%' AND owner2 ILIKE '%PENN%')
)
SELECT COUNT(*)::int AS bg_that_intersect
FROM census.blockgroups_2020 bg
CROSS JOIN penn_campus pc
WHERE ST_Intersects(bg.geog::geometry, pc.geom);
