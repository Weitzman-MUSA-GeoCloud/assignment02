/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
  pair each parcel with its closest bus stop. The final result should give the
  parcel address, bus stop name, and distance apart in meters, rounded to two
  decimals. Order by distance (largest on top).
*/

select
    parcels.address as parcel_address,
    pairs.stop_name,
    round(pairs.distance::numeric, 2) as distance
from phl.pwd_parcels as parcels
cross join
    lateral (
        select
            stops.stop_name,
            parcels.geog <-> stops.geog as distance
        from septa.bus_stops as stops
        where st_dwithin(parcels.geog, stops.geog, 2000)
        order by distance
        limit 1
    ) as pairs
order by pairs.distance desc;
