/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs.
  Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset
  from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some
  creativity in the metric you devise in rating neighborhoods.
*/
with
accessible_buffer as (
    select
        stop_id,
        st_buffer(geog, 200) as accessible_zones
    from septa.bus_stops
    where wheelchair_boarding = 1
),

accessible_union as (
    select st_union(accessible_zones::geometry)::geography as geog
    from accessible_buffer
),

livable_neighborhoods as (
    select
        neigh.name as neighborhood_name,
        st_union(parcels.geog::geometry)::geography as geog,
        st_area(st_union(parcels.geog::geometry)::geography) as geog_area
    from phl.pwd_parcels as parcels
    inner join phl.neighborhoods as neigh on st_intersects(st_centroid(parcels.geog), neigh.geog)
    group by neigh.name
),

accessible_stops as (
    select
        geog,
        stop_id
    from septa.bus_stops
    where wheelchair_boarding = 1
),

inaccessible_stops as (
    select
        geog,
        stop_id
    from septa.bus_stops
    where not wheelchair_boarding = 1
),

accessible_stops_neighborhoods as (
    select
        neigh.name as neighborhood_name,
        count(stops.stop_id) as stop_count
    from phl.neighborhoods as neigh
    inner join accessible_stops as stops on st_dwithin(neigh.geog, stops.geog, 10)
    group by neigh.name
),

inaccessible_stops_neighborhoods as (
    select
        neigh.name as neighborhood_name,
        count(stops.stop_id) as stop_count
    from phl.neighborhoods as neigh
    inner join inaccessible_stops as stops on st_dwithin(neigh.geog, stops.geog, 10)
    group by neigh.name
),

output_unordered as (
    select
        neigh.name as neighborhood_name,
        a_stop.stop_count::integer as num_bus_stops_accessible,
        i_stop.stop_count::integer as num_bus_stops_inaccessible,
        st_area(st_intersection(liveable.geog, accessible_union.geog)) / liveable.geog_area as accessibility_metric
    from livable_neighborhoods as liveable
    inner join phl.neighborhoods as neigh on (liveable.neighborhood_name = neigh.name)
    inner join accessible_stops_neighborhoods as a_stop using (neighborhood_name)
    inner join inaccessible_stops_neighborhoods as i_stop using (neighborhood_name)
    cross join accessible_union
    order by accessibility_metric desc
    limit 5
)

select
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from output_unordered;
