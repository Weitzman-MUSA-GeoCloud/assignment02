SELECT
    bg.geoid
FROM phl.pwd_parcels p
JOIN census.blockgroups_2020 bg
    ON ST_Intersects(p.geog, bg.geog)
WHERE p.address ILIKE '%3400%'
  AND p.address ILIKE '%Walnut%'
LIMIT 1;
