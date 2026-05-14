select
    pwd_parcels.address as parcel_address,
    knn.stop_name,
    ROUND(knn.distance::NUMERIC, 2) as distance
from phl.pwd_parcels
cross join
    lateral (
        select
            bs.stop_name,
            pwd_parcels.geog <-> bs.geog as distance
        from septa.bus_stops as bs
        order by distance asc
        limit 1
    ) as knn
order by distance desc;
