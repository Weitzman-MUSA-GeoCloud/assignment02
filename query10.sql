/*
  Build a description (alias as stop_desc) for each rail stop using spatial 
  relationships with nearby parcels and neighborhoods.
  
  The description includes:
  - Distance and direction to the nearest parcel
  - The neighborhood the stop is located in
*/

with nearest_parcel as (
    select
        stops.stop_id,
        parcels.address as nearest_address,
        st_distance(stops.geog, parcels.geog) as dist,
        degrees(st_azimuth(stops.geog::geometry, st_centroid(parcels.geog::geometry))) as azimuth
    from septa.rail_stops as stops
    cross join lateral (
        select
            pwd.address,
            pwd.geog
        from phl.pwd_parcels as pwd
        order by stops.geog <-> pwd.geog
        limit 1
    ) as parcels
),

stop_neighborhoods as (
    select
        stops.stop_id,
        neighborhoods.name as neighborhood_name
    from septa.rail_stops as stops
    left join phl.neighborhoods as neighborhoods
        on st_contains(neighborhoods.geog::geometry, stops.geog::geometry)
)

select
    stops.stop_id::integer as stop_id,
    stops.stop_name,
    concat(
        round(np.dist::numeric, 0), ' meters ',
        case
            when np.azimuth >= 337.5 or np.azimuth < 22.5 then 'N'
            when np.azimuth >= 22.5 and np.azimuth < 67.5 then 'NE'
            when np.azimuth >= 67.5 and np.azimuth < 112.5 then 'E'
            when np.azimuth >= 112.5 and np.azimuth < 157.5 then 'SE'
            when np.azimuth >= 157.5 and np.azimuth < 202.5 then 'S'
            when np.azimuth >= 202.5 and np.azimuth < 247.5 then 'SW'
            when np.azimuth >= 247.5 and np.azimuth < 292.5 then 'W'
            when np.azimuth >= 292.5 and np.azimuth < 337.5 then 'NW'
        end,
        ' of ', np.nearest_address,
        coalesce(' in ' || sn.neighborhood_name, '')
    ) as stop_desc,
    stops.stop_lon,
    stops.stop_lat
from septa.rail_stops as stops
left join nearest_parcel as np on stops.stop_id = np.stop_id
left join stop_neighborhoods as sn on stops.stop_id = sn.stop_id
