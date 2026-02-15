/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/


CREATE INDEX if NOT EXISTS pwd_parcels_geog_gist
    ON phl.pwd_parcels
    USING gist (geog);

CREATE INDEX IF NOT EXISTS bus_stops_geog_gist
    ON septa.bus_stops
    USING gist (geog);

set search_path = public

SELECT 
    p.address as parcel_address,
    nn.stop_name,
    Round(
        ST_Distance(p.geog, nn.geog)::numeric,
        2
    ) AS distance
FROM phl.pwd_parcels AS p
CROSS JOIN lateral (
    SELECT
        s.stop_name,
        s.geog
    FROM septa.bus_stops as s
    order by p.geog <-> s.geog
    limit 1
) as nn 
order by distance DESC