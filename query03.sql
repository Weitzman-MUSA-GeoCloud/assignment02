/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
pair each parcel with its closest bus stop. 
The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals.
Order by distance (largest on top).
*/
WITH
    parcel_closest_bus_stop AS (
        SELECT
            stops.stop_id,
            parcels.parcelid,
            stops.geog <-> parcels.geog AS distance,
            parcels.address
        FROM septa.bus_stops AS stops
        CROSS JOIN LATERAL (
            SELECT
                parcels.parcelid,
                parcels.geog,
                stops.geog <-> parcels.geog AS distance,
                parcels.address
            FROM phl.pwd_parcels AS parcels
            ORDER BY distance ASC
            LIMIT 1
        ) parcels
    )
SELECT
    parcels.address::text AS parcel_address,
    stops.stop_name::text,
    round(parcels.distance::numeric,2) AS distance
FROM parcel_closest_bus_stop AS parcels
INNER JOIN septa.bus_stops AS stops using (stop_id)
ORDER BY distance DESC