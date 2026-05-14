with shape_lines as (
    select
        shape_id,
        st_makeline(
            st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326)
            order by shape_pt_sequence
        ) as geom
    from septa.bus_shapes
    group by shape_id
),

shape_lengths as (
    select
        shape_id,
        round(st_length(geom::geography))::numeric as shape_length
    from shape_lines
),

route_best as (
    select
        t.route_id,
        t.trip_headsign,
        sl.shape_length,
        row_number() over (
            partition by t.route_id
            order by sl.shape_length desc
        ) as rn
    from septa.bus_trips as t
    inner join shape_lengths as sl
        on t.shape_id = sl.shape_id
)

select
    r.route_short_name,
    rb.trip_headsign,
    rb.shape_length
from route_best as rb
inner join septa.bus_routes as r
    on rb.route_id = r.route_id
where rb.rn = 1
order by rb.shape_length desc
limit 2;
