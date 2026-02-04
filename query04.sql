SET search_path TO public, phl, septa, census;
WITH shape_geometries AS (
    SELECT
        septa.bus_shapes.shape_id,
        ST_MakeLine(
            ST_SetSRID(ST_MakePoint(septa.bus_shapes.shape_pt_lon, septa.bus_shapes.shape_pt_lat), 4326)
            ORDER BY septa.bus_shapes.shape_pt_sequence
        ) AS shape_geom
    FROM septa.bus_shapes
    GROUP BY septa.bus_shapes.shape_id
),
shape_lengths AS (
    SELECT
        shape_geometries.shape_id,
        shape_geometries.shape_geom,
        ST_Length(shape_geometries.shape_geom::geography) AS shape_length
    FROM shape_geometries
),
trip_shapes AS (
    SELECT
        septa.bus_trips.route_id,
        septa.bus_trips.trip_headsign,
        shape_lengths.shape_geom::geography AS shape_geog,
        ROUND(shape_lengths.shape_length) AS shape_length
    FROM septa.bus_trips
    INNER JOIN shape_lengths ON septa.bus_trips.shape_id = shape_lengths.shape_id
),
answer AS (
    SELECT
        septa.bus_routes.route_short_name,
        trip_shapes.trip_headsign,
        trip_shapes.shape_geog,
        trip_shapes.shape_length
    FROM trip_shapes
    INNER JOIN septa.bus_routes ON septa.bus_routes.route_id = trip_shapes.route_id
)
SELECT *
FROM answer
ORDER BY shape_length DESC
LIMIT 2;
