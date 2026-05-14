/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
  find the two routes with the longest trips.
*/

with shape_lines as (
    select
        shape_id,
        st_makeline(
            st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326)
            order by shape_pt_sequence
        ) as shape_geom
    from septa.bus_shapes
    group by shape_id
),

trip_lengths as (
    select
        t.trip_id,
        t.trip_headsign,
        t.route_id,
        st_length(sl.shape_geom::geography) as shape_length,
        row_number() over (
            partition by t.route_id
            order by st_length(sl.shape_geom::geography) desc
        ) as rn
    from septa.bus_trips as t
    inner join shape_lines as sl on t.shape_id = sl.shape_id
)

select
    r.route_short_name,
    tl.trip_headsign,
    round(tl.shape_length) as shape_length
from trip_lengths as tl
inner join septa.bus_routes as r on tl.route_id = r.route_id
where tl.rn = 1
order by tl.shape_length desc
limit 2
