/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
  find the two routes with the longest trips.
*/

with

trip_shapes as (
    select
        trips.route_id,
        trips.trip_headsign,
        shapes.shape_id,
        st_makeline(
            st_point(shapes.shape_pt_lon, shapes.shape_pt_lat)
            order by shapes.shape_pt_sequence
        )::geography as shape_geog
    from septa.bus_trips as trips
    inner join septa.bus_shapes as shapes
        on trips.shape_id = shapes.shape_id
    group by trips.route_id, trips.trip_headsign, shapes.shape_id
),

shape_lengths as (
    select
        route_id,
        trip_headsign,
        shape_id,
        st_length(shape_geog) as shape_length
    from trip_shapes
),

ranked_shapes as (
    select
        routes.route_short_name,
        sl.trip_headsign,
        round(sl.shape_length)::integer as shape_length,
        row_number() over (order by sl.shape_length desc) as rn
    from shape_lengths as sl
    inner join septa.bus_routes as routes
        on sl.route_id = routes.route_id
)

select
    route_short_name,
    trip_headsign,
    shape_length
from ranked_shapes
where rn <= 2
order by shape_length desc
