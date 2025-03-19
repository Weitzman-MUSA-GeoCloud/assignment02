with protected as (
    select geog
    from phl.bike_network
    where type like '%Separated Bike Lane%'
),

info as (
    select
        rail.stop_id,
        rail.stop_name,
        rail.stop_lon,
        rail.stop_lat,
        case
            when bike.distance < 500 then 'Proteced bike lane within ' || bike.distance::character || 'm'
            else
                'No protected bike lane within 500m'
        end as stop_desc
    from septa.rail_stops as rail
    cross join
        lateral (
            select
                protected.geog,
                rail.geog <-> protected.geog as distance
            from protected
            order by distance
            limit 1
        ) as bike
)

select
    stop_id,
    stop_name,
    stop_desc,
    stop_lon,
    stop_lat
from info;
