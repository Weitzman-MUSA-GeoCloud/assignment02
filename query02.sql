WITH septa_bus_stop_blockgroups AS (
    SELECT
        stops.stop_id,
        '1500000US' || bg.geoid AS geoid
    FROM septa.bus_stops AS stops
    INNER JOIN census.blockgroups_2020 AS bg
        ON public.ST_DWithin(stops.geog, bg.geog, 800)
    WHERE bg.geoid LIKE '42101%'
),
septa_bus_stop_surrounding_population AS (
    SELECT
        stops.stop_id,
        SUM(pop.total) AS estimated_pop_800m
    FROM septa_bus_stop_blockgroups AS stops
    INNER JOIN census.population_2020 AS pop
        USING (geoid)
    GROUP BY stops.stop_id
    HAVING SUM(pop.total) > 500
)
SELECT
    stops.stop_name,
    pop.estimated_pop_800m,
    stops.geog
FROM septa_bus_stop_surrounding_population AS pop
INNER JOIN septa.bus_stops AS stops
    USING (stop_id)
ORDER BY pop.estimated_pop_800m ASC  -- Sort by smallest population
LIMIT 8;
