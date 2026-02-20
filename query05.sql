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
  ramps near accessible stops are considered more accessible. This has its
  limitations as it doesn't account for the quality of the ramps, the side of
  the street the ramps are on,or the actual routes of the bus stops, but it
  provides a starting point for assessing accessibility based on proximity
  to pedestrian infrastructure.

  [DVRPC Data Page Link](https://catalog.dvrpc.org/dataset/dvrpc-pedestrian-ramps)
  [GeoJSON Direct Link](https://arcgis.dvrpc.org/portal/rest/services/transportation/pedestriannetwork_points/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson)
*/

with
accessible_stops as (
    select
        stop_id,
        stop_name,
        geog
    from septa.bus_stops
    -- Filter wheelchair-accessible bus stops.
    where wheelchair_boarding = 1
),

stops_in_neighborhoods as (
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

ramps_near_stops as (
    select
        stops_in_neighborhoods.neighborhood_name,
        stops_in_neighborhoods.stop_id,
        count(ramps.ogc_fid) as nearby_ramp_count
    from stops_in_neighborhoods
    left join phl.pedestrian_ramps as ramps
        -- Count pedestrian ramps within 150m of accessible stops.
        on st_dwithin(
            stops_in_neighborhoods.stop_geog::geography,
            ramps.geog::geography,
            150
        )
    group by
        stops_in_neighborhoods.neighborhood_name,
        stops_in_neighborhoods.stop_id
)

-- Aggregate counts per neighborhood for total accessible stops
-- and nearby ramps as accessibility metric.
select
    neighborhood_name,
    count(stop_id) as total_accessible_stops,
    sum(nearby_ramp_count) as total_nearby_ramps
from ramps_near_stops
group by neighborhood_name
order by total_nearby_ramps desc, total_accessible_stops desc;
