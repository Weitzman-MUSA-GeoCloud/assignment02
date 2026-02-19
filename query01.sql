/*
  Which 8 bus stops have the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.

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
    select
        stops.stop_id,
        '1500000US' || bg.geoid as geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on st_dwithin(stops.geog, bg.geog, 800)
),

septa_bus_stop_surrounding_population as (
    select
        stops.stop_id,
        sum(pop.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid)
    group by stops.stop_id
)

select
    stops.stop_id,
    stops.stop_name,
    pop.estimated_pop_800m
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id)
order by pop.estimated_pop_800m desc
limit 8;
