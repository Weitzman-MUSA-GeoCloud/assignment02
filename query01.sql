/*
Which eight bus stop have the largest population within 800 meters?
As a rough estimation, consider any block group that intersects the buffer as
being part of the 800 meter buffer.
*/

SELECT
    septa.bus_stops.stop_id,
    septa.bus_stops.stop_name,
    SUM(census.population_2020.total)::integer AS estimated_pop_800m
FROM septa.bus_stops
LEFT JOIN census.blockgroups_2020
    ON public.ST_Intersects(
        public.ST_Buffer(septa.bus_stops.geog, 800), census.blockgroups_2020.geog
    )
LEFT JOIN census.population_2020
    ON census.blockgroups_2020.geoid = census.population_2020.geoid
GROUP BY
    septa.bus_stops.stop_id,
    septa.bus_stops.stop_name
ORDER BY estimated_pop_800m DESC NULLS LAST
LIMIT 8;
