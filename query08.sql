/* With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus. */


set search_path = public  


WITH penn AS (
  SELECT ST_Union(geog::geometry)::geography AS geog
  FROM phl.universities_colleges
  WHERE name ILIKE '%University of Pennsylvania%'
)
SELECT COUNT(*)::integer AS count_block_groups
FROM census.blockgroups_2020 bg
CROSS JOIN penn
WHERE ST_Covers(penn.geog, bg.geog);



WITH penn AS (
  SELECT ST_Union(geog::geometry)::geography AS geog
  FROM phl.universities_colleges
  WHERE name ILIKE '%University of Pennsylvania%'
    AND name NOT ILIKE '%Academy%'
)
SELECT COUNT(*) AS bg_intersects
FROM census.blockgroups_2020 bg
CROSS JOIN penn
WHERE ST_Intersects(penn.geog, bg.geog);


WITH x AS (
  SELECT
    bg.geoid,
    ST_Area(ST_Intersection(bg.geog::geometry, pc.geom)) / NULLIF(ST_Area(bg.geog::geometry), 0) AS frac_inside
  FROM census.blockgroups_2020 bg
  CROSS JOIN phl.penn_main_campus pc
  WHERE ST_Intersects(bg.geog::geometry, pc.geom)
)
SELECT COUNT(*)::integer AS count_block_groups_majority_inside
FROM x
WHERE frac_inside >= 0.5;
