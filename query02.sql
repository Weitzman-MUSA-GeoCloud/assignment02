SET search_path TO public, phl, septa, census;
WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        stops.stop_name,
        stops.stop_lat,
        stops.stop_lon,
        '1500000US' || bg.geoid AS geoid
    FROM
        septa.bus_stops AS stops
    INNER JOIN
        census.blockgroups_2020 AS bg
        ON ST_DWithin(
            ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326)::geography,
            bg.geog,
            800
        )
),
septa_bus_stop_surrounding_popn AS (
    SELECT
        stop_id,
        stop_name,
        stop_lat,
        stop_lon,
        SUM(pop.total) AS estimated_pop_800m
    FROM
        septa_bus_stop_blockgroups
    INNER JOIN
        census.population_2020 AS pop
        USING (geoid)
    GROUP BY
        stop_id, stop_name, stop_lat, stop_lon
)
SELECT
    stop_name,
    estimated_pop_800m,
    ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog
FROM
    septa_bus_stop_surrounding_popn
ORDER BY
    estimated_pop_800m DESC
LIMIT 8;
