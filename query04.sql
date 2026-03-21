WITH shape_lines AS (
    SELECT
        shape_id,
        ST_MakeLine(
            ST_SetSRID(
                ST_MakePoint(shape_pt_lon, shape_pt_lat),
                4326
            )
            ORDER BY shape_pt_sequence
        ) AS geom
    FROM septa.bus_shapes
    GROUP BY shape_id
),

trip_lengths AS (
    SELECT
        t.route_id,
        t.trip_headsign,
        ST_Length(s.geom::geography) AS shape_length
    FROM septa.bus_trips t
    JOIN shape_lines s
        ON t.shape_id = s.shape_id
),

ranked_trips AS (
    SELECT
        route_id,
        trip_headsign,
        shape_length,
        ROW_NUMBER() OVER (
            PARTITION BY route_id
            ORDER BY shape_length DESC
        ) AS rn
    FROM trip_lengths
)

SELECT
    r.route_short_name,
    rt.trip_headsign,
    ROUND(rt.shape_length)::numeric AS shape_length
FROM ranked_trips rt
JOIN septa.bus_routes r
    ON rt.route_id = r.route_id
WHERE rt.rn = 1
ORDER BY rt.shape_length DESC
LIMIT 2;
