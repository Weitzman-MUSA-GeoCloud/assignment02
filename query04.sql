/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
  find the two routes with the longest trips.
*/

WITH
-- a line geometry for each unique shape based on ordered shape points
trip_shape AS (
    SELECT
        bs.shape_id,
        ST_MAKELINE(ARRAY_AGG(
            ST_SETSRID(ST_MAKEPOINT(bs.shape_pt_lon, bs.shape_pt_lat), 4326)
            ORDER BY bs.shape_pt_sequence
        ))::GEOGRAPHY AS shape_geog
    FROM septa.bus_shapes AS bs
    GROUP BY bs.shape_id
),

-- the total distance (in meters) for each shape line
trip_length AS (
    SELECT
        ts.shape_id,
        ts.shape_geog,
        ROUND(ST_LENGTH(ts.shape_geog)::NUMERIC, 0) AS shape_length
    FROM trip_shape AS ts
),

-- trips within each route by descending shape length
ranked_trip AS (
    SELECT
        bt.route_id,
        bt.trip_headsign,
        tl.shape_geog,
        tl.shape_length,
        ROW_NUMBER() OVER (
            PARTITION BY bt.route_id
            ORDER BY tl.shape_length DESC
        ) AS rn
    FROM septa.bus_trips AS bt
    INNER JOIN trip_length AS tl
        ON bt.shape_id = tl.shape_id
),

-- the longest trip per route
final_trip AS (
    SELECT *
    FROM ranked_trip
    WHERE rn = 1
)

--  the two longest trips among all routes
SELECT
    br.route_short_name,
    ft.trip_headsign,
    ft.shape_geog,
    ft.shape_length
FROM final_trip AS ft
INNER JOIN septa.bus_routes AS br
    ON ft.route_id = br.route_id
ORDER BY ft.shape_length DESC
LIMIT 2;
