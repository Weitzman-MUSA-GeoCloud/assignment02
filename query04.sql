/*
  Find the two routes with the longest trips using bus_shapes, bus_routes,
  and bus_trips.
*/

with

shape_lines as (
    select
        shape_id,
        public.st_length(
            public.st_makeline(
                array_agg(
                    public.st_makepoint(shape_pt_lon, shape_pt_lat)
                    order by shape_pt_sequence
                )
            )::public.geography,
            true
        ) as shape_length_m
    from septa.bus_shapes
    group by shape_id
),

ranked_shapes as (
    select
        shape_id,
        round(shape_length_m)::numeric as shape_length,
        row_number() over (order by shape_length_m desc) as rn
    from shape_lines
),

top_two as (
    select shape_id, shape_length
    from ranked_shapes
    where rn <= 2
)
select route_short_name, trip_headsign, shape_length
from (
    select distinct on (tt.shape_id)
        r.route_short_name,
        t.trip_headsign,
        tt.shape_length
    from top_two as tt
    inner join septa.bus_trips as t on t.shape_id = tt.shape_id
    inner join septa.bus_routes as r on r.route_id = t.route_id
    order by tt.shape_id, t.trip_id
) sub
order by shape_length desc
