SELECT bg.geoid AS geo_id
FROM phl.pwd_parcels AS p
INNER JOIN census.blockgroups_2020 AS bg
    ON ST_INTERSECTS(bg.geog, p.geog)
WHERE p.address = '220-30 S 34TH ST';
