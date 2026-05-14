/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
  find the two routes with the longest trips.
*/

with

shape_lines as (
    select
        shape_id,
        st_makeline(
            st_makepoint(shape_pt_lon, shape_pt_lat)::geometry
            order by shape_pt_sequence
        ) as shape_geom
    from septa.bus_shapes
    group by shape_id
),

trip_lengths as (
    select
        trips.route_id,
        trips.trip_headsign,
        trips.shape_id,
        st_length(sl.shape_geom::geography) as shape_length,
        row_number() over (
            partition by trips.route_id
            order by st_length(sl.shape_geom::geography) desc
        ) as rn
    from septa.bus_trips as trips
    inner join shape_lines as sl using (shape_id)
),

longest_per_route as (
    select
        route_id,
        trip_headsign,
        shape_length
    from trip_lengths
    where rn = 1
)

select
    routes.route_short_name,
    lpr.trip_headsign,
    round(lpr.shape_length) as shape_length
from longest_per_route as lpr
inner join septa.bus_routes as routes using (route_id)
order by shape_length desc
limit 2
