/*
  Build a descriptive stop_desc for each rail stop using the nearest PWD parcel
  address and compass direction from the stop to that parcel.
*/

with rail_with_nearest as (
    select
        rs.stop_id,
        rs.stop_name,
        rs.stop_lon,
        rs.stop_lat,
        nearest.address,
        round(st_distance(rs.geog, nearest.geog)::numeric) as dist_m,
        degrees(st_azimuth(
            st_centroid(rs.geog::geometry),
            st_centroid(nearest.geog::geometry)
        )) as azimuth
    from septa.rail_stops as rs
    cross join lateral (
        select
            pwd_parcels.address,
            pwd_parcels.geog
        from phl.pwd_parcels
        order by pwd_parcels.geog <-> rs.geog
        limit 1
    ) as nearest
)

select
    stop_id::integer,
    stop_name,
    stop_lon,
    stop_lat,
    dist_m || ' meters '
    || case
        when azimuth < 22.5 or azimuth >= 337.5 then 'N'
        when azimuth < 67.5 then 'NE'
        when azimuth < 112.5 then 'E'
        when azimuth < 157.5 then 'SE'
        when azimuth < 202.5 then 'S'
        when azimuth < 247.5 then 'SW'
        when azimuth < 292.5 then 'W'
        else 'NW'
    end
    || ' of ' || address as stop_desc
from rail_with_nearest
order by stop_id::integer
