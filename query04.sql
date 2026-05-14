/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
  find the two routes with the longest trips.
*/

with

shape_geoms as (
    select
        shape_id,
        st_makeline(
            st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326)
            order by shape_pt_sequence
        ) as geom
    from septa.bus_shapes
    group by shape_id
),

route_trip_lengths as (
    select
        r.route_short_name,
        t.trip_headsign,
        st_length(sg.geom::geography) as length,
        row_number() over (
            partition by r.route_short_name
            order by st_length(sg.geom::geography) desc
        ) as rn
    from septa.bus_routes as r
    inner join septa.bus_trips as t on r.route_id = t.route_id
    inner join shape_geoms as sg on t.shape_id = sg.shape_id
)

select
    route_short_name,
    trip_headsign,
    round(length) as shape_length
from route_trip_lengths
where rn = 1
order by length desc
limit 2
