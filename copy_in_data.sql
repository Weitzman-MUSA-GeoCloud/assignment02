-- Active: 1770745616986@@127.0.0.1@5433@assignment02
--this is where I will do copy commands

COPY septa.bus_stops
FROM '/pg-mount/stops.txt'
DELIMITER ','
CSV HEADER;


--ogr2ogr runs in terminal, not .sql
--paths for those are the full computer paths, rather than the paths that the container would be concerned about
--no need to start psql for ogr2ogr, powershell will work

COPY septa.rail_stops
FROM '/pg-mount/rail_stops.txt'
DELIMITER ','
CSV HEADER;

COPY septa.bus_routes
FROM '/pg-mount/bus_routes.txt'
DELIMITER ','
CSV HEADER;

COPY septa.bus_shapes
FROM '/pg-mount/bus_shapes.txt'
DELIMITER ','
CSV HEADER;

COPY septa.bus_trips
FROM '/pg-mount/bus_trips.txt'
DELIMITER ','
CSV HEADER;

COPY census.population_2020
FROM '/pg-mount/census_data.csv'
DELIMITER ','
CSV HEADER;

-- 1. Add the new geography column

create extension postgis


ALTER TABLE census.blockgroups_2020
ADD COLUMN geog geography;

-- 2. Populate it from your geometry column
UPDATE census.blockgroups_2020
SET geog = geom::geography;

ALTER TABLE septa.bus_stops
ADD COLUMN geog GEOGRAPHY(Point, 4326);

UPDATE septa.bus_stops
SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography;



CREATE INDEX ON septa.bus_stops USING GIST(geog);
CREATE INDEX ON phl.pwd_parcels USING GIST(geog);

-- Add a geometry column to bus_stops rather than casting it in query
ALTER TABLE septa.bus_stops ADD COLUMN geom geometry(Point, 4326);
UPDATE septa.bus_stops SET geom = geog::geometry;
CREATE INDEX ON septa.bus_stops USING GIST(geom);


CREATE INDEX ON septa.bus_shapes (shape_id);

CREATE INDEX ON septa.bus_routes (route_id);
CREATE INDEX ON septa.bus_shapes (shape_pt_sequence);
CREATE INDEX ON septa.bus_trips (shape_id);
CREATE INDEX ON septa.bus_trips (route_id);

