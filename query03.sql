/*
  Pair each PWD parcel with its closest bus stop. Parcel address, bus stop name,
  and distance in meters (rounded to two decimals). Order by distance (largest on top).
*/


CREATE INDEX IF NOT EXISTS bus_stops_geog_idx 
ON septa.bus_stops 
USING GIST (geog);

CREATE INDEX IF NOT EXISTS pwd_parcels_geog_idx 
ON phl.pwd_parcels 
USING GIST (geog);

select
    p.address as parcel_address,
    nearest.stop_name,
    round(nearest.dist_m::numeric, 2) as distance
from phl.pwd_parcels as p
cross join lateral (
    select
        s.stop_name,
        public.st_distance(p.geog, s.geog) as dist_m
    from septa.bus_stops as s

    order by p.geog::public.geometry operator(public.<->) s.geog::public.geometry
    limit 1
) as nearest
order by distance desc;

