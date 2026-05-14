/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

with
septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        '1500000US' || bg.geoid as geoid --modify geoid to match population_2020.geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on st_dwithin(stops.geog, bg.geog, 800) --join block groups within 800m (creates multiple rows per stop_id)
),

septa_bus_stop_surrounding_population as (
    select
        stops.stop_id, --get stop_id to join with stop names
        sum(pop.total) as estimated_pop_800m --sum the population total column while grouped
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid) --join population totals based on geoid
    group by stops.stop_id -- group by stop_id to sum population of all blkgrps within 800m
)

select
    stops.stop_id,
    stops.stop_name,
    pop.estimated_pop_800m
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id) --join original bus stop information (including name)
order by pop.estimated_pop_800m desc --order table in descending order to isolate highest pop values
limit 8; --identify the top 8 stations by population
