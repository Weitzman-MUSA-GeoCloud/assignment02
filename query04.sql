/*
Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed,
find the **two** routes with the longest trips.
*/

-- Create a table to store the shape geometries
CREATE TABLE shape_geoms (
  shape_id text NOT NULL,
  shape_geom geometry('LINESTRING', 4326),
  CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);
CREATE INDEX shape_geoms_key ON septa.bus_shapes (shape_id);

-- Create the geometries for routes 
INSERT INTO shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))
FROM septa.bus_shapes
GROUP BY shape_id;

-- Find the two routes with the longest trips
WITH

bus_trips_routes AS (
SELECT 
	trip_headsign,
	shape_id,
	septa.bus_routes.route_short_name
FROM septa.bus_trips
LEFT JOIN septa.bus_routes
  ON septa.bus_trips.route_id = septa.bus_routes.route_id
),  
bus_trips_routes_shapes AS(
SELECT
	trip_headsign,
	shape_id,
	route_short_name,
	ROUND(ST_Length(ST_Transform(shape_geom, 32633))) AS shape_length,
	shape_geom
FROM bus_trips_routes
INNER JOIN shape_geoms using (shape_id)
)
SELECT * FROM bus_trips_routes_shapes
ORDER BY shape_length DESC

-- The two routes are 128 and 130.