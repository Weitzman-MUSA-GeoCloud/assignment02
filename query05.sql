/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs.
  Use OpenDataPhilly's neighborhood dataset along with an appropriate
  dataset from the Septa GTFS bus feed. Use the GTFS documentation for
  help. Use some creativity in the metric you devise in rating neighborhoods.

  NOTE: There is no automated test for this question, as there's no one
  right answer. With urban data analysis, this is frequently the case.

  Discuss your accessibility metric and how you arrived at it below:

  Description: For each neighborhood, the query finds all wheelchair-accessible
  bus stops where wheelchair_boarding = 1, then counts the total number of
  pedestrian ramps within 150 meters of any of those stops based on rough
  average block measurements in Google Maps. Neighborhoods with more nearby
  ramps near accessible stops are considered more accessible.
*/

with
accessible_stops as (
    select
        stop_id,
        stop_name,
        geog
    from septa.bus_stops
    where wheelchair_boarding = 1
),

stops_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        acc.stop_id,
        acc.geog as stop_geog
    from phl.neighborhoods as neighborhoods
    inner join accessible_stops as acc
        on st_within(acc.geog::geometry, neighborhoods.geog::geometry)
),

ramps_near_stops as (
    select
        stopn.neighborhood_name,
        stopn.stop_id,
        count(ramps.ogc_fid) as nearby_ramp_count
    from stops_in_neighborhoods as stopn
    left join phl.pedestrian_ramps as ramps
        on st_dwithin(stopn.stop_geog::geography, ramps.geog::geography, 150)
    group by stopn.neighborhood_name, stopn.stop_id
)

select
    neighborhood_name,
    count(stop_id) as total_accessible_stops,
    sum(nearby_ramp_count) as total_nearby_ramps
from ramps_near_stops
group by neighborhood_name
order by total_nearby_ramps desc, total_accessible_stops desc;
