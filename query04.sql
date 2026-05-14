/*
  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed,
  find the **two** routes with the longest trips.

*/

WITH shape_lines AS (
    SELECT
        shape_id,
        ST_MAKELINE(
            ST_MAKEPOINT(shape_pt_lon, shape_pt_lat)::geometry
            ORDER BY shape_pt_sequence
        )::geography AS shape_geog
    FROM septa.bus_shapes
    GROUP BY shape_id
),

trip_lengths AS (
    SELECT
        t.route_id,
        t.trip_headsign,
        t.shape_id,
        ROUND(ST_LENGTH(sl.shape_geog)::numeric) AS shape_length,
        ROW_NUMBER() OVER (ORDER BY ST_LENGTH(sl.shape_geog) DESC) AS rn
    FROM septa.bus_trips AS t
    INNER JOIN shape_lines AS sl USING (shape_id)
)

SELECT
    r.route_short_name,
    tl.trip_headsign,
    tl.shape_length
FROM trip_lengths AS tl
INNER JOIN septa.bus_routes AS r USING (route_id)
WHERE tl.rn <= 2;
