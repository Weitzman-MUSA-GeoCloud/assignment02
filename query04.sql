/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
 find the two routes with the longest trips.
*/

WITH unique_trips AS (
    SELECT DISTINCT ON (shape_id)
        shape_id,
        trip_headsign,
        route_id
    FROM septa.bus_trips
)

SELECT
    septa.bus_routes.route_short_name,
    unique_trips.trip_headsign,
    ROUND(public.ST_Length(shape_line.geog))::numeric AS shape_length
FROM (
    SELECT
        septa.bus_shapes.shape_id,
        public.ST_MakeLine(
            public.ST_SetSRID(
                public.ST_MakePoint(septa.bus_shapes.shape_pt_lon, septa.bus_shapes.shape_pt_lat),
                4326
            )
            ORDER BY septa.bus_shapes.shape_pt_sequence
        )::public.geography AS geog
    FROM septa.bus_shapes
    GROUP BY septa.bus_shapes.shape_id
) AS shape_line
INNER JOIN unique_trips ON shape_line.shape_id = unique_trips.shape_id
INNER JOIN septa.bus_routes ON unique_trips.route_id = septa.bus_routes.route_id
ORDER BY shape_length DESC
LIMIT 2;
