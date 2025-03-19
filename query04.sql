/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
  find the two routes with the longest trips.
*/
with
shapes as (
    select
        shape_id,
        st_makeline(
            array_agg(
                st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326)
                order by shape_pt_sequence
            )
        )::geography as shape_geog
    from septa.bus_shapes
    group by shape_id
),
distinct_trips as (
    select distinct
        trip_headsign,
        route_id,
        shape_id
    from septa.bus_trips
),
trip_shapes as (
    select
        trips.route_id,
        trips.trip_headsign,
        shapes.shape_id,
        shapes.shape_geog,
        st_length(shapes.shape_geog) as shape_length
    from distinct_trips as trips
    inner join shapes using (shape_id)
),
longest_trips_per_route as (
    select
        route_id,
        max(shape_length) as shape_length
    from trip_shapes
    group by route_id
),
longest_2_trips as (
    select *
    from longest_trips_per_route
    order by shape_length desc
    limit 2
)
select 
    routes.route_short_name,
    trip_shapes.trip_headsign,
    trip_shapes.shape_geog,
    round(trip_shapes.shape_length) as shape_length
from trip_shapes
inner join longest_2_trips using (route_id, shape_length)
inner join septa.bus_routes as routes using (route_id)
order by trip_shapes.shape_length desc;
