/* Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips. */




set search_path = public                                                                                      

WITH shape_lengths AS (
    SELECT
        s.shape_id,
        ST_Length(
            ST_MakeLine(
                ST_SetSRID(ST_MakePoint(s.shape_pt_lon, s.shape_pt_lat), 4326)
                ORDER BY s.shape_pt_sequence
            )::geography
        ) AS shape_length_m
    FROM septa.bus_shapes AS s
    GROUP BY s.shape_id
),
trip_lengths AS (
    SELECT
        t.route_id,
        t.trip_headsign,
        sl.shape_length_m
    FROM septa.bus_trips AS t
    JOIN shape_lengths sl USING (shape_id)
),
ranked AS (
    SELECT
        tl.route_id,
        tl.trip_headsign,
        tl.shape_length_m,
        ROW_NUMBER() OVER (
            PARTITION BY tl.route_id
            ORDER BY tl.shape_length_m DESC
        ) AS rn
    FROM trip_lengths AS tl
)
SELECT
    r.route_short_name,
    ranked.trip_headsign,
    ROUND(ranked.shape_length_m::numeric, 0) AS shape_length
FROM ranked
JOIN septa.bus_routes AS r USING (route_id)
WHERE ranked.rn = 1
ORDER BY ranked.shape_length_m DESC
LIMIT 2;
