create schema if not exists septa;
create schema if not exists phl;
create schema if not exists census;
create extension if not exists postgis;
drop table if exists septa.bus_stops;
create table septa.bus_stops (
    stop_id TEXT,
    stop_code TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT,
    location_type INTEGER,
    parent_station TEXT,
    stop_timezone TEXT,
    wheelchair_boarding INTEGER
);
COPY septa.bus_stops
FROM 'C:\Users\19397\Documents\GitHub\MUSA_509\musa509_assignment02\data\bus_stops.txt'
WITH (FORMAT csv, HEADER true);

drop table if exists septa.bus_routes;
create table septa.bus_routes (
    route_id TEXT,
    agency_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_desc TEXT,
    route_type TEXT,
    route_url TEXT,
    route_color TEXT,
    route_text_color TEXT
);
COPY septa.bus_routes
FROM 'C:\Users\19397\Documents\GitHub\MUSA_509\musa509_assignment02\data\bus_routes.txt'
WITH (FORMAT csv, HEADER true);

drop table if exists septa.bus_trips;
create table septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    trip_short_name TEXT,
    direction_id TEXT,
    block_id TEXT,
    shape_id TEXT,
    wheelchair_accessible INTEGER,
    bikes_allowed INTEGER
);
COPY septa.bus_trips
FROM 'C:\Users\19397\Documents\GitHub\MUSA_509\musa509_assignment02\data\bus_trips.txt'
WITH (FORMAT csv, HEADER true);

drop table if exists septa.bus_shapes;
create table septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER,
    shape_dist_traveled DOUBLE PRECISION
);
COPY septa.bus_shapes
FROM 'C:\Users\19397\Documents\GitHub\MUSA_509\musa509_assignment02\data\bus_shapes.txt'
WITH (FORMAT csv, HEADER true);

drop table if exists septa.rail_stops;
create table septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);
COPY septa.rail_stops
FROM 'C:\Users\19397\Documents\GitHub\MUSA_509\musa509_assignment02\data\rail_stops.txt'
WITH (FORMAT csv, HEADER true);

drop table if exists census.population_2020;
create table census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);
COPY census.population_2020
FROM 'C:\Users\19397\Documents\GitHub\MUSA_509\musa509_assignment02\data\population2020.csv'
WITH (FORMAT csv, HEADER true);

-- add geog for bus_stops
ALTER TABLE septa.bus_stops ADD COLUMN geog geography;
UPDATE septa.bus_stops
SET geog = ST_MakePoint(stop_lon, stop_lat)::geography;

drop table if exists phl.upenn;