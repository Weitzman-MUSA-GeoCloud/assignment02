WITH shape_lines AS (
    SELECT
        bs.shape_id,
        ST_MakeLine(
            ST_SetSRID(ST_MakePoint(bs.shape_pt_lon, bs.shape_pt_lat), 4326)
            ORDER BY bs.shape_pt_sequence
        ) AS geom
    FROM septa.bus_shapes AS bs
    GROUP BY bs.shape_id
),

shape_lengths AS (
    SELECT
        sl.shape_id,
        ROUND(ST_Length(sl.geom::geography))::numeric AS shape_length
    FROM shape_lines AS sl
),

route_trip_lengths AS (
    SELECT
        r.route_short_name,
        t.trip_headsign,
        t.shape_id,
        l.shape_length
    FROM septa.bus_trips AS t
    INNER JOIN septa.bus_routes AS r
        ON t.route_id = r.route_id
    INNER JOIN shape_lengths AS l
        ON t.shape_id = l.shape_id
),

ranked_routes AS (
    SELECT
        route_short_name,
        trip_headsign,
        shape_length,
        ROW_NUMBER() OVER (
            PARTITION BY route_short_name
            ORDER BY shape_length DESC
        ) AS rn
    FROM route_trip_lengths
)

SELECT
    route_short_name,
    trip_headsign,
    shape_length
FROM ranked_routes
WHERE rn = 1
ORDER BY shape_length DESC
LIMIT 2;