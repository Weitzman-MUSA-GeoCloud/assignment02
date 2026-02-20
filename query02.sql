/*
  Which eight bus stops have the smallest population above 500 people
  inside of Philadelphia within 800 meters of the stop (Philadelphia
  county block groups have a geoid prefix of 42101 -- that's 42 for
  the state of PA, and 101 for Philadelphia county)?

  The queries to #1 & #2 should generate results with a single row,
  with the following structure:

  (
    stop_id text, -- The ID of the station
    stop_name text, -- The name of the station
    estimated_pop_800m integer -- The population within 800 meters
  )
*/

with
septa_bus_stop_blockgroups as (
    -- Find Philadelphia county block groups within 800 meters for each
    -- bus stop that don't spatially contain stop itself.
    select
        stops.stop_id,
        -- Match format used in population_2020 by prepending.
        '1500000US' || bg.geoid as geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on
            -- Keep block groups whose boundary falls within 800 meters 
            -- of stop.
            st_dwithin(stops.geog::geography, bg.geog::geography, 800)
    -- Restrict to Philadelphia county block groups only.
    where bg.geoid like '42101%'
),

septa_bus_stop_surrounding_population as (
    -- Sum population of all nearby block groups for each bus stop.
    select
        stops.stop_id,
        sum(pop.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid)
    group by stops.stop_id
    -- Keep stops w/ surrounding population beyond 500 people.
    having sum(pop.total) > 500
)

-- Join population estimates back to bus stop details for the final output.
select
    stops.stop_id,
    stops.stop_name,
    pop.estimated_pop_800m
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id)
-- Sort ascending so least-served stops first.
order by pop.estimated_pop_800m
-- Return only 8 stops w/ smallest surrounding population.
limit 8;
