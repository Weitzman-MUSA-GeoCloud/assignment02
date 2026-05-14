with rail as (
    select
        stop_id::integer as stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        geog,
        geog::geometry as geom
    from septa.rail_stops
),

rail_flag as (
    select
        r.*,
        exists(
            select 1
            from census.blockgroups_2020 as bg
            where
                bg.geoid like '42101%'
                and st_covers(bg.geog::geometry, r.geom)
        ) as is_phl
    from rail as r
),

phl_parcel_nn as (
    select
        rf.stop_id,
        rf.stop_name,
        rf.stop_lon,
        rf.stop_lat,
        rf.geog,
        rf.geom as stop_geom,
        rf.is_phl,
        p.address as parcel_address,
        st_pointonsurface(p.geog::geometry) as parcel_pt_geom,
        round(st_distance(rf.geog, p.geog)::numeric, 0) as dist_m
    from rail_flag as rf
    left join lateral (
        select
            pwd_parcels.geog,
            pwd_parcels.address
        from phl.pwd_parcels
        order by rf.geog <-> pwd_parcels.geog
        limit 1
    ) as p on rf.is_phl
),

with_dir as (
    select
        a.stop_id,
        a.stop_name,
        a.stop_lon,
        a.stop_lat,
        a.is_phl,
        a.parcel_address,
        a.dist_m,
        degrees(st_azimuth(a.stop_geom, a.parcel_pt_geom)) as az_deg
    from phl_parcel_nn as a
)

select
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    case
        when is_phl
            then
                concat(
                    dist_m::int, ' meters ',
                    case
                        when az_deg >= 337.5 or az_deg < 22.5 then 'N of '
                        when az_deg < 67.5 then 'NE of '
                        when az_deg < 112.5 then 'E of '
                        when az_deg < 157.5 then 'SE of '
                        when az_deg < 202.5 then 'S of '
                        when az_deg < 247.5 then 'SW of '
                        when az_deg < 292.5 then 'W of '
                        else 'NW of '
                    end,
                    parcel_address
                )
        else 'Outside Philadelphia'
    end as stop_desc
from with_dir;
