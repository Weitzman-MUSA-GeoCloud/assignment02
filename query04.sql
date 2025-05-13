/*

Using the bus_shapes, bus_routes, 
and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.
*/

WITH septa_bus_shapes_geom AS (
    SELECT
        shape_id,
        public.ST_MakeLine(
            array_agg(
                public.ST_SetSRID(public.ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326)
                ORDER BY shape_pt_sequence
            )
        ) AS shape_geom
    FROM septa.bus_shapes
    GROUP BY shape_id
)
SELECT DISTINCT
    routes.route_short_name,
    trips.trip_headsign,
    public.ST_SetSRID(shapes.shape_geom, 4326)::geography AS shape_geog,
    round((public.ST_Length(public.ST_Transform(shapes.shape_geom, 32129)))::numeric, 0) AS shape_length
FROM septa_bus_shapes_geom AS shapes
INNER JOIN septa.bus_trips AS trips
    ON shapes.shape_id = trips.shape_id
INNER JOIN septa.bus_routes AS routes
    ON trips.route_id = routes.route_id
ORDER BY shape_length DESC
LIMIT 2;
