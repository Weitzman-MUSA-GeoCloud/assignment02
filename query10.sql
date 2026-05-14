with

rail_stop_geog as (
    select
        stop_id,
        stop_name,
        stop_lat,
        stop_lon,
        st_makepoint(stop_lon, stop_lat)::geography as geog
    from septa.rail_stops
)

select
    rs.stop_id::integer as stop_id,
    rs.stop_name,
    nearest.stop_desc,
    rs.stop_lon,
    rs.stop_lat
from rail_stop_geog as rs
cross join
    lateral (
        select
            round(st_distance(rs.geog, p.geog)::numeric)
            || ' meters '
            || case
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 22.5 then 'N'
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 67.5 then 'NE'
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 112.5 then 'E'
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 157.5 then 'SE'
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 202.5 then 'S'
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 247.5 then 'SW'
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 292.5 then 'W'
                when degrees(st_azimuth(
                    rs.geog::geometry,
                    st_centroid(p.geog::geometry)
                )) < 337.5 then 'NW'
                else 'N'
            end
            || ' of ' || p.address as stop_desc
        from phl.pwd_parcels as p
        order by rs.geog::geometry <-> p.geog::geometry
        limit 1
    ) as nearest
order by rs.stop_id
