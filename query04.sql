WITH trip_shapes AS (
    SELECT
        t.trip_id,
        r.route_short_name,
        t.trip_headsign,
        ST_MAKELINE(
            ST_SETSRID(ST_MAKEPOINT(s.shape_pt_lon, s.shape_pt_lat), 4326)
            ORDER BY s.shape_pt_sequence
        )::geography AS shape_geog
    FROM septa.bus_trips AS t
    JOIN septa.bus_routes AS r -- noqa
        ON t.route_id = r.route_id
    JOIN septa.bus_shapes AS s -- noqa
        ON t.shape_id = s.shape_id
    GROUP BY t.trip_id, r.route_short_name, t.trip_headsign
),

trip_lengths AS (
    SELECT
        route_short_name,
        trip_headsign,
        shape_geog,
        ROUND(ST_LENGTH(shape_geog)) AS shape_length,
        ROW_NUMBER() OVER (
            ORDER BY ST_LENGTH(shape_geog) DESC
        ) AS rn
    FROM trip_shapes
)

SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM trip_lengths
WHERE rn <= 2
ORDER BY shape_length DESC;
