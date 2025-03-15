/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.
*/

with trips_clean as (
    select
        t.shape_id,
        min(t.route_id) as route_id,
        min(t.trip_headsign) as trip_headsign
    from septa.bus_trips as t
    group by t.shape_id
),

trip_shapes as (
    select
        s.shape_id,
        st_makeline(array_agg(
            st_setsrid(st_makepoint(s.shape_pt_lon, s.shape_pt_lat), 4326)
            order by s.shape_pt_sequence
        ))::geography as shape_geog,
        st_length(st_makeline(array_agg(
            st_setsrid(st_makepoint(s.shape_pt_lon, s.shape_pt_lat), 4326)
            order by s.shape_pt_sequence
        ))::geography) as shape_length
    from septa.bus_shapes as s
    group by s.shape_id
)

select
    tc.route_id as route_short_name,
    tc.trip_headsign,
    ts.shape_geog,
    round(ts.shape_length) as shape_length
from trips_clean as tc
inner join trip_shapes as ts on tc.shape_id = ts.shape_id
order by
    ts.shape_length desc
limit 2;
