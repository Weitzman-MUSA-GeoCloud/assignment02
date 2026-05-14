/*
Using the bus_shapes, bus_routes, and bus_trips tables from
GTFS bus feed, find the two routes with the longest trips.
*/

WITH

trip_shapes AS (
    SELECT
        shape_id,
        st_makeline(
            st_makepoint(shape_pt_lon, shape_pt_lat)::geography::geometry
            ORDER BY shape_pt_sequence
        ) AS shape_geom
    FROM septa.bus_shapes
    GROUP BY shape_id
),

trip_lengths AS (
    SELECT
        trips.route_id,
        trips.trip_headsign,
        st_length(shapes.shape_geom::geography) AS shape_length,
        row_number() OVER (
            PARTITION BY trips.route_id
            ORDER BY st_length(shapes.shape_geom::geography) DESC
        ) AS rn
    FROM septa.bus_trips AS trips
    INNER JOIN trip_shapes AS shapes USING (shape_id)
)

SELECT
    routes.route_short_name,
    lengths.trip_headsign,
    round(lengths.shape_length) AS shape_length
FROM trip_lengths AS lengths
INNER JOIN septa.bus_routes AS routes USING (route_id)
WHERE lengths.rn = 1
ORDER BY lengths.shape_length DESC
LIMIT 2
