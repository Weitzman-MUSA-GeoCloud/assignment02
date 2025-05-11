-- Query 4

-- Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.

-- ANSWER: The two routes with the longest trips are Route 130 and Route 128.

WITH shape_lines AS (
    SELECT
        s.shape_id,
        ST_MakeLine(geom ORDER BY shape_pt_sequence) AS trip_geometry
    FROM (
        SELECT
            shape_id,
            ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326) AS geom,
            shape_pt_sequence
        FROM septa.bus_shapes
    ) AS ordered_shapes
    GROUP BY shape_id
),

trip_lengths AS (
    SELECT
        r.route_short_name,
        t.trip_headsign,
        sl.trip_geometry::geography AS shape_geog,
        ROUND(ST_Length(sl.trip_geometry::geography)) AS shape_length
    FROM septa.bus_trips t
    JOIN septa.bus_routes r ON t.route_id = r.route_id
    JOIN shape_lines sl ON t.shape_id = sl.shape_id
)

SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM trip_lengths
ORDER BY shape_length DESC
LIMIT 2;
