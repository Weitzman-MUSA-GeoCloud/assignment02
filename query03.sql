/*
Using the Philadelphia Water Department Stormwater Billing Parcels
dataset, pair each parcel with its closest bus stop. The final result
should give the parcel address, bus stop name, and distance apart in
meters, rounded to two decimals. Order by distance (largest on top).
*/

SELECT
    phl.pwd_parcels.address AS parcel_address,
    nearest_stop.stop_name,
    ROUND(public.ST_Distance(phl.pwd_parcels.geog, nearest_stop.geog)::numeric, 2) AS distance
FROM
    phl.pwd_parcels
CROSS JOIN
    LATERAL (
        SELECT
            septa.bus_stops.stop_name,
            septa.bus_stops.geog
        FROM
            septa.bus_stops
        ORDER BY
            public.ST_Distance(phl.pwd_parcels.geog, septa.bus_stops.geog)
        LIMIT 1
    ) AS nearest_stop
ORDER BY
    distance DESC;
