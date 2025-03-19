/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

Your query should run in under two minutes.
*/


CREATE INDEX ON septa.bus_stops USING gist (geog);
CREATE INDEX ON phl.pwd_parcels USING gist (geog);

SELECT
    stops.stop_name AS stopname,
    stops.distance AS dist,
    pwd.address
FROM phl.pwd_parcels AS pwd
INNER JOIN LATERAL (
    SELECT
        bus_stops.stop_name,
        bus_stops.geog <-> pwd.geog AS distance
    FROM septa.bus_stops
    ORDER BY distance
    LIMIT 1
) AS stops ON true
ORDER BY dist DESC;
