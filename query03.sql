select
    pwd_parcels.address as parcel_address,
    nearest_bus_stop.stop_name,
    round(st_distance(pwd_parcels.geog, nearest_bus_stop.geog)::numeric, 2) as distance
from phl.pwd_parcels as pwd_parcels
cross join
    lateral (
        select
            bus_stops.stop_name,
            bus_stops.geog
        from septa.bus_stops as bus_stops
        order by pwd_parcels.geog <-> bus_stops.geog
        limit 1
    ) as nearest_bus_stop
order by distance desc;
