/*
Which eight bus stops have the smallest population above 500 people inside of Philadelphia
within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101`
-- that's `42` for the state of PA, and `101` for Philadelphia county)?
*/
WITH
septa_bus_stop_blockgroups as (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid as geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 as bg
        ON st_dwithin(stops.geog, bg.geog, 800)
    WHERE LEFT(bg.geoid, 5) = '42101'
),

septa_bus_stop_surround_population AS (
    SELECT
        stops.stop_id,
        sum(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop using (geoid)
    GROUP BY stops.stop_id
)
SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surround_population as pop
INNER JOIN septa.bus_stops as stops using (stop_id)
WHERE pop.estimated_pop_800m > 500
ORDER BY pop.estimated_pop_800m ASC
LIMIT 8