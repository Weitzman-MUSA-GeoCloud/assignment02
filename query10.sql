/*
  Using any of the datasets above, PostGIS functions, and PostgreSQL string
  functions, build a description (alias as stop_desc) for each rail stop.

  Each description states the distance and direction from the nearest PWD
  parcel to the rail stop, e.g. "42 meters NE of 1234 MARKET ST".
*/

select
    rs.stop_id::integer as stop_id,
    rs.stop_name,
    concat(
        round(
            st_distance(
                st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)::geography,
                nearest.geog
            )::numeric,
            0
        )::integer,
        ' meters ',
        case
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 22.5  then 'N'
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 67.5  then 'NE'
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 112.5 then 'E'
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 157.5 then 'SE'
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 202.5 then 'S'
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 247.5 then 'SW'
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 292.5 then 'W'
            when degrees(
                st_azimuth(
                    nearest.geog::geometry,
                    st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)
                )
            ) < 337.5 then 'NW'
            else 'N'
        end,
        ' of ',
        nearest.address
    ) as stop_desc,
    rs.stop_lon,
    rs.stop_lat
from septa.rail_stops as rs
cross join lateral (
    select
        p.address,
        p.geog
    from phl.pwd_parcels as p
    order by
        st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)::geography
        <-> p.geog
    limit 1
) as nearest
order by rs.stop_name
