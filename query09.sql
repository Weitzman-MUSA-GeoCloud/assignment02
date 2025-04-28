SELECT pop.geoid AS geo_id
FROM census.blockgroups_2020 AS pop
JOIN phl.neighborhoods AS n -- noqa: AM05
    ON ST_INTERSECTS(pop.geog::geometry, n.geog::geometry)
WHERE n.mapname ILIKE '%University City%'
ORDER BY
    ST_DISTANCE(
        ST_CENTROID(pop.geog::geometry),
        ST_CENTROID(n.geog::geometry)
    )
LIMIT 1;
