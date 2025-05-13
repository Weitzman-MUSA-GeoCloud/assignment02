with stop_info as (
    select
        rs.stop_id,
        rs.stop_name,
        rs.stop_lat,
        rs.stop_lon,
        count(bs.stop_id)::integer as stops_within_500m,
        sum(case when bs.wheelchair_boarding = 1 then 1 else 0 end) as accessible_stops
    from
        septa.rail_stops as rs
    left join
        septa.bus_stops as bs
        on st_dwithin(rs.geog, bs.geog, 500)
    group by
        rs.stop_id, rs.stop_name, rs.stop_lat, rs.stop_lon
)

select
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    case
        when stops_within_500m = 0
            then
                'no nearby bus transfers within 500 meters.'
        when stops_within_500m = 1
            then
                '1 bus stop nearby within 500m, '
                || accessible_stops || ' accessible.'
        else
            stops_within_500m || ' bus stops nearby within 500m, '
            || accessible_stops || ' accessible.'
    end as stop_desc
from stop_info
order by stops_within_500m desc;