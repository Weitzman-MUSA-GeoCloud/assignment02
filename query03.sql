/*
   Using the Philadelphia Water Department Stormwater Billing Parcels
   dataset, pair each parcel with its closest bus stop. The final
   result should give the parcel address, bus stop name, and
   distance apart in meters, rounded to two decimals. Order by
   distance (largest on top).
*/

SELECT
    parcels.address AS parcel_address,
    stops.stop_name,
    round(
        st_distance(
            parcels.geog,
            stops.geog
        )::numeric,
        2
    ) AS distance
FROM phl.pwd_parcels AS parcels,
    LATERAL (
        SELECT
            stops.stop_name,
            stops.geog
        FROM septa.bus_stops AS stops
        ORDER BY parcels.geog <-> stops.geog
        LIMIT 1
    ) AS stops
ORDER BY distance DESC
