/*
Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.
*/
WITH
shapes_line AS (
    SELECT 
        shapes.shape_id,
        ST_MakeLine(array_agg(
    ST_SetSRID(ST_MakePoint(shapes.shape_pt_lon, shapes.shape_pt_lat),4326) ORDER BY shapes.shape_pt_sequence)) AS shape_geog
    FROM septa.bus_shapes as shapes
    GROUP BY shapes.shape_id
),
shapes_line_trips AS (
    SELECT
        trips.shape_id,
        trips.trip_headsign,
        trips.route_id,
        shapes.shape_geog,
        round(st_length(st_transform(shapes.shape_geog, 26918))::NUMERIC,2) AS shape_length  -- Transform to Pennsylvania State Plane South (meters)
    FROM septa.bus_trips AS trips
    INNER JOIN shapes_line AS shapes using (shape_id)
    GROUP BY trips.trip_headsign, trips.route_id, trips.shape_id, shapes.shape_geog
)
SELECT
    trips.trip_headsign,
    routes.route_short_name,
    trips.shape_length,
    trips.shape_geog
FROM shapes_line_trips AS trips
INNER JOIN septa.bus_routes AS routes using (route_id)
ORDER BY trips.shape_length DESC
LIMIT 2;
