-- Active: 1738180041736@@localhost@5432@musa_509
-- Active: 1738180041736@@localhost@5432@musa_509

/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed,
find the two routes with the longest trips.
*/



WITH trip_lengths AS (
    SELECT
        routes.route_short_name,
        trips.trip_headsign,
        shapes.shape_id,
        public.ST_MakeLine(
            ARRAY_AGG(
                public.ST_SetSRID(
                    public.ST_MakePoint(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326
                ) 
                ORDER BY shapes.shape_pt_sequence
            )
        ) AS shape_geog
    FROM
        septa.bus_shapes AS shapes
    LEFT JOIN
        septa.bus_trips AS trips
        ON shapes.shape_id = trips.shape_id
    LEFT JOIN
        septa.bus_routes AS routes
        ON trips.route_id = routes.route_id
    GROUP BY
        shapes.shape_id, trips.trip_headsign, routes.route_short_name
)
SELECT
    route_short_name,
    trip_headsign,
    shape_id,
    shape_geog,
    ROUND(public.ST_Length(shape_geog::public.geography)::NUMERIC, 2) AS shape_length
FROM
    busroute_shapes
ORDER BY
    shape_length DESC
LIMIT 2;