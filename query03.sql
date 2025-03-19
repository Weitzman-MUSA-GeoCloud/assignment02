
/* Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. The final result should give the parcel address, 
bus stop name, and distance apart in meters, rounded to two decimals. Order by distance 
(largest on top). */


-- Ensure spatial indexes exist (run this once before the query)
CREATE INDEX IF NOT EXISTS idx_parcels_geog ON phl.pwd_parcels USING GIST(geog);
CREATE INDEX IF NOT EXISTS idx_bus_stops_geog ON septa.bus_stops USING GIST(geog);

WITH nearest_stops AS (
    -- Find the closest bus stop for each parcel
    SELECT 
        p.address AS parcel_address,
        s.stop_name AS stop_name,
        ROUND(ST_Distance(p.geog, s.geog)::NUMERIC, 2) AS distance
    FROM phl.pwd_parcels AS p
    LEFT JOIN LATERAL (
        SELECT s.stop_name, s.geog 
        FROM septa.bus_stops AS s
        ORDER BY p.geog <-> s.geog  -- Uses GiST index for nearest-neighbor search
        LIMIT 1  -- Get only the nearest stop
    ) AS s ON true
)

-- Order results by the farthest parcels first
SELECT * 
FROM nearest_stops
ORDER BY distance DESC;
