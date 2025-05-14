SET search_path TO public, phl, septa, census;
WITH rail_stops_geog AS (
    SELECT
        stop_id,
        stop_name,
        stop_lat,
        stop_lon,
        ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog
    FROM rail_stops
),
nearest_bus_stop AS (
    SELECT
        r.stop_id AS rail_stop_id,
        r.stop_name AS rail_stop_name,
        b.stop_name AS bus_stop_name,
        ST_Distance(r.geog, b.geog) AS distance_meters
    FROM rail_stops_geog r
    CROSS JOIN LATERAL (
        SELECT stop_name, geog
        FROM septa.bus_stops
        ORDER BY r.geog <-> geog
        LIMIT 1
    ) b
)
SELECT
    r.stop_id,
    r.stop_name,
    'Nearest bus stop: ' || n.bus_stop_name || ' (' || ROUND(n.distance_meters)::text || ' meters away)' AS stop_desc,
    r.stop_lon,
    r.stop_lat
FROM rail_stops_geog r
JOIN nearest_bus_stop n ON r.stop_id = n.rail_stop_id;
