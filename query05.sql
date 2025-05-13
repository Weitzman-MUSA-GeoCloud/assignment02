with nearest_accessible_stop as (
    select
        pwd.geog,
        pwd.address as parcel_address,
        nbs.name as neighborhood_name,
        round(st_distance(pwd.geog, bs.geog)::numeric, 2) as distance
    from phl.pwd_parcels as pwd
    inner join phl.neighborhoods as nbs
        on st_intersects(pwd.geog::geometry, nbs.geog::geometry)
    inner join lateral (
        select
            bus_stops.stop_name,
            bus_stops.geog
        from septa.bus_stops
        where bus_stops.wheelchair_boarding = 1
        order by pwd.geog <-> bus_stops.geog
        limit 1
    ) as bs on true
),

neighborhood_access_count as (
    select
        neighborhood_name,
        count(*) filter (where distance <= 150) as parcels_near_accessible_stop
    from nearest_accessible_stop
    group by neighborhood_name
),

bus_stop_counts as (
    select
        nbs.name as neighborhood_name,
        count(*) filter (where stops.wheelchair_boarding = 1) as num_bus_stops_accessible,
        count(*) filter (where stops.wheelchair_boarding != 1) as num_bus_stops_inaccessible
    from phl.neighborhoods as nbs
    left join septa.bus_stops as stops
        on st_intersects(stops.geog, nbs.geog)
    group by nbs.name
)

select
    a.neighborhood_name,
    a.parcels_near_accessible_stop,
    b.num_bus_stops_accessible,
    b.num_bus_stops_inaccessible
into phl.neighborhoods_accessibility2
from neighborhood_access_count as a
left join bus_stop_counts as b using (neighborhood_name)
order by a.parcels_near_accessible_stop desc;