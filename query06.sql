/*
  What are the top five neighborhoods according to your accessibility metric?

  Both #6 and #7 should have the structure:

  (
  neighborhood_name text,  -- The name of the neighborhood
  accessibility_metric ...,  -- Your accessibility metric value
  num_bus_stops_accessible integer,
  num_bus_stops_inaccessible integer
  )
*/

with
accessible_stops as (
    select
        stop_id,
        geog
    from septa.bus_stops
    -- Filter wheelchair-accessible bus stops.
    where wheelchair_boarding = 1
),

inaccessible_stops as (
    select
        stop_id,
        geog
    from septa.bus_stops
    -- Filter wheelchair-inaccessible bus stops.
    where wheelchair_boarding != 1
),

accessible_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        accessible_stops.stop_id,
        accessible_stops.geog as stop_geog
    from phl.neighborhoods as neighborhoods
    -- Join accessible stops to neighborhoods.
    inner join accessible_stops
        on st_within(
            accessible_stops.geog::geometry,
            neighborhoods.geog::geometry
        )
),

inaccessible_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        inaccessible_stops.stop_id
    from phl.neighborhoods as neighborhoods
    -- Join inaccessible stops to neighborhoods.
    inner join inaccessible_stops
        on st_within(
            inaccessible_stops.geog::geometry,
            neighborhoods.geog::geometry
        )
),

ramps_near_stops as (
    select
        accessible_in_neighborhoods.neighborhood_name,
        accessible_in_neighborhoods.stop_id,
        count(ramps.ogc_fid) as nearby_ramp_count
    from accessible_in_neighborhoods
    left join phl.pedestrian_ramps as ramps
        -- Count pedestrian ramps within 150m of accessible stops.
        on st_dwithin(
            accessible_in_neighborhoods.stop_geog::geography,
            ramps.geog::geography,
            150
        )
    group by
        accessible_in_neighborhoods.neighborhood_name,
        accessible_in_neighborhoods.stop_id
),

-- Aggregate accessible stops and ramps per neighborhood.
-- accessibility_metric is sum of nearby ramps across all stops.
accessible_summary as (
    select
        neighborhood_name,
        count(stop_id) as num_bus_stops_accessible,
        sum(nearby_ramp_count) as accessibility_metric
    from ramps_near_stops
    group by neighborhood_name
),

-- Aggregate inaccessible stops and ramps per neighborhood.
-- inaccessibility_metric is sum of nearby ramps across all stops.
inaccessible_summary as (
    select
        neighborhood_name,
        count(stop_id) as num_bus_stops_inaccessible
    from inaccessible_in_neighborhoods
    group by neighborhood_name
)

select
    accessible_summary.neighborhood_name,
    accessible_summary.accessibility_metric,
    accessible_summary.num_bus_stops_accessible,
    coalesce(
        inaccessible_summary.num_bus_stops_inaccessible, 0
    ) as num_bus_stops_inaccessible
from accessible_summary
-- Join summaries and return top 5 accessible, ordered by accessibility_metric
-- desc, then by accessible stops desc.
left join inaccessible_summary
    on
        accessible_summary.neighborhood_name
        = inaccessible_summary.neighborhood_name
order by
    accessible_summary.accessibility_metric desc,
    accessible_summary.num_bus_stops_accessible desc
limit 5;

/*
AI used to help with query. Free model Claude Haiku 4.5.

Prompt:
Don't give me answer. I'm getting null values showing up despite ordering
them, is there a way to replace with 0? I want to make sure all stops show up.

(Resolved by using coalesce to replace null with 0 for num_bus_stops_inaccessible.)
*/
