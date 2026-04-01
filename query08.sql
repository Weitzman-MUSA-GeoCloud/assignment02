SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 bg
JOIN phl.neighborhoods n
  ON ST_Contains(n.geog::geometry, bg.geog::geometry)
WHERE n.name = 'UNIVERSITY_CITY';