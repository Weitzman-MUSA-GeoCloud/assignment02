/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, find the two routes with the longest trips.
*/

set search_path = public;

WITH trip_lengths AS (
  SELECT 
    routes.route_short_name,
    trips.trip_headsign,
    shapes.shape_id,
    ROUND(ST_Length(
      ST_MakeLine(
        array_agg(
          ST_SetSRID(
            ST_MakePoint(shapes.shape_pt_lon::float, shapes.shape_pt_lat::float),
            4326
          )
          ORDER BY shapes.shape_pt_sequence
        )
      )::geography
    )::numeric, 0) AS shape_length
  FROM septa.bus_routes routes
  JOIN septa.bus_trips trips
    ON trips.route_id = routes.route_id
  JOIN septa.bus_shapes shapes
    ON shapes.shape_id = trips.shape_id
  GROUP BY 
    routes.route_short_name,
    trips.trip_headsign,
    shapes.shape_id
)
SELECT route_short_name, trip_headsign, shape_length
FROM trip_lengths
ORDER BY shape_length DESC
LIMIT 2;