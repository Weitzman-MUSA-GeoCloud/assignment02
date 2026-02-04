SET search_path TO public, phl, septa, census;
SELECT geoid AS geo_id
FROM census.blockgroups_2020
WHERE ST_Covers(
    geog,
    ST_GeomFromText('POINT(-75.195242 39.9522493)', 4326)::geography
)
LIMIT 1;
