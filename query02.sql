/*
Which eight bus stops have the smallest population above 500 people inside of Philadelphia within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of 42101 -- that's 42 for the state of PA, and 101 for Philadelphia county)?
*/

set search_path = public;

WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON ST_DWithin(
    ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326),
    bg.geog,
    800
)
    WHERE bg.geoid LIKE '42101%'
),

septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop USING (geoid)
    GROUP BY stops.stop_id
)
SELECT
    stops.stop_id,
    stops.stop_name,
    pop.estimated_pop_800m
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops USING (stop_id)
WHERE pop.estimated_pop_800m > 500
ORDER BY pop.estimated_pop_800m ASC
LIMIT 5;