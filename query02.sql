/*
Which eight bus stops have the smallest population above 500 people
inside of Philadelphia within 800 meters of the stop (Philadelphia
county block groups have a geoid prefix of 42101 -- that's 42 for the
state of PA, and 101 for Philadelphia county)?
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
    AND census.blockgroups_2020.geoid LIKE '42101%'
LEFT JOIN census.population_2020
    ON census.blockgroups_2020.geoid = census.population_2020.geoid
GROUP BY
    septa.bus_stops.stop_id,
    septa.bus_stops.stop_name
HAVING SUM(census.population_2020.total) > 500
ORDER BY estimated_pop_800m ASC
LIMIT 8;
