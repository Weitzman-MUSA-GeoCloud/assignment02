SELECT bg.geoid AS geo_id
FROM census.blockgroups_2020 bg
JOIN phl.pwd_parcels p
  ON ST_Intersects(bg.geog::geometry, ST_PointOnSurface(p.geog::geometry))
WHERE p.address = '220-30 S 34TH ST';