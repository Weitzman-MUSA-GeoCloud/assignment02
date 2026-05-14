WITH shape_lines AS (
    SELECT
        shape_id,
        ST_MAKELINE(
            ST_SETSRID(ST_MAKEPOINT(shape_pt_lon, shape_pt_lat), 4326)
            ORDER BY shape_pt_sequence
        ) AS shape_geom
    FROM septa.bus_shapes
    GROUP BY shape_id
),

shape_lengths AS (
    SELECT
        shape_id,
        ROUND(ST_LENGTH(shape_geom::geography)) AS shape_length
    FROM shape_lines
),

distinct_route_trips AS (
    SELECT DISTINCT
        r.route_short_name,
        t.trip_headsign,
        sl.shape_length
    FROM septa.bus_trips AS t
    INNER JOIN shape_lengths AS sl USING (shape_id)
    INNER JOIN septa.bus_routes AS r USING (route_id)
),

ranked AS (
    SELECT
        route_short_name,
        trip_headsign,
        shape_length,
        ROW_NUMBER() OVER (
            PARTITION BY route_short_name
            ORDER BY shape_length DESC
        ) AS rn_per_route
    FROM distinct_route_trips
)

SELECT
    route_short_name,
    trip_headsign,
    shape_length::numeric
FROM ranked
WHERE rn_per_route = 1
ORDER BY shape_length DESC
LIMIT 2;
