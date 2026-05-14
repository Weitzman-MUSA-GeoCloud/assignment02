/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/

set search_path = public;
WITH
septa_bus_stops AS (
    SELECT
        stop_name,
        st_makepoint(stop_lon, stop_lat) AS geog 
    FROM septa.bus_stops
)
SELECT
    pwd_parcels.address,
    nearest_bus_stop.stop_name,
    round(st_distance(pwd_parcels.geog, nearest_bus_stop.geog)::NUMERIC, 2) AS distance
FROM phl.pwd_parcels
CROSS JOIN LATERAL (
    SELECT stop_name, geog
    FROM septa_bus_stops AS bus_stops
    ORDER BY pwd_parcels.geog <-> bus_stops.geog
    LIMIT 1
 ) AS nearest_bus_stop;
