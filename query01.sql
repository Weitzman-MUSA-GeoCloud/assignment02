/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/

DROP EXTENSION postgis CASCADE;
CREATE EXTENSION postgis;

--need to create geog for bus stops

ALTER TABLE septa.bus_stops
ADD COLUMN geog GEOGRAPHY(Point, 4326);

UPDATE septa.bus_stops
SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography;

--
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'block_groups';
--tells me it's wkb_geometry

ALTER TABLE census.block_groups
ADD COLUMN geog GEOGRAPHY(MultiPolygon, 4326);

ALTER TABLE census.block_groups
ADD COLUMN population INTEGER;

UPDATE census.block_groups bg
SET population = p.total
FROM census.population_2020 p
WHERE bg.geoid = p.geoid;



with
septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
 --       '1500000US' || bg.geoid as geoid
        bg.geoid as geoid
    from septa.bus_stops as stops
    inner join census.block_groups as bg
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
limit 8
