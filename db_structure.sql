/*

This file contains the SQL commands to prepare the database for your queries.
Before running this file, you should have created your database, created the
schemas (see below), and loaded your data into the database.

Creating your schemas
---------------------

You can create your schemas by running the following statements in PG Admin:

    create schema if not exists septa;
    create schema if not exists phl;
    create schema if not exists census;

Also, don't forget to enable PostGIS on your database:

    create extension if not exists postgis;

Loading your data
-----------------

After you've created the schemas, load your data into the database specified in
the assignment README.

Finally, you can run this file either by copying it all into PG Admin, or by
running the following command from the command line:

    psql -U postgres -d <YOUR_DATABASE_NAME> -f db_structure.sql

*/

-- Create schemas.
create schema if not exists septa;
create schema if not exists phl;
create schema if not exists census;

-- Enable PostGIS.
create extension if not exists postgis schema public;

-- Create tables.
CREATE TABLE septa.bus_stops (
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
CREATE TABLE septa.bus_routes (
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
CREATE TABLE septa.bus_trips (
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
CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER,
    shape_dist_traveled DOUBLE PRECISION
);
CREATE TABLE septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);
CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

-- Set path to public for geography types.
set search_path to public;

/*
ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment_02 user=postgres password=postgres" `
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -lco PRECISION=NO `
    -overwrite `
    "data/PhillyWater_PWD_PARCELS2025/PhillyWater_PWD_PARCELS2025.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment_02 user=postgres password=postgres" `
    -nln phl.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -lco PRECISION=NO `
    -overwrite `
    "data/philadelphia-neighborhoods/philadelphia-neighborhoods.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment_02 user=postgres password=postgres" `
    -nln census.blockgroups_2020  `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -lco PRECISION=NO `
    -overwrite `
    "data/tl_2020_42_bg/tl_2020_42_bg.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment_02 user=postgres password=postgres" `
    -nln phl.pedestrian_ramps `
    -nlt POINT `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -lco PRECISION=NO `
    -overwrite `
    "data/pedestrian_ramps.json"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.rail_stops (stop_id, stop_name, stop_desc, stop_lat, stop_lon, zone_id, stop_url) FROM 'data/gtfs_public/google_rail/stops.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_stops (stop_id, stop_name, stop_lat, stop_lon, location_type, parent_station, zone_id, wheelchair_boarding) FROM 'data/gtfs_public/google_bus/stops.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_routes (route_id, route_short_name, route_long_name, route_type, route_color, route_text_color, route_url) FROM 'data/gtfs_public/google_bus/routes.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_trips (route_id, service_id, trip_id, trip_headsign, block_id, direction_id, shape_id) FROM 'data/gtfs_public/google_bus/trips.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_shapes (shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence) FROM 'data/gtfs_public/google_bus/shapes.txt' WITH (FORMAT csv, HEADER true);"
*/

-- Add a column to the septa.bus_stops table to store the geometry of each stop.
alter table septa.bus_stops
add column if not exists geog geography;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography
where geog is null;

-- Load in population data to temporary staging table.
create table census.temp_population (
    geoname text,
    geoid text,
    total text,
    state text,
    county text,
    tract text,
    block_group text
);

-- psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy census.temp_population FROM 'data/population_2020.csv' WITH (FORMAT csv, HEADER true);"

insert into census.population_2020 (geoid, geoname, total)
select 
    geoid as geoid,
    geoname as geoname,
    total::integer as total
from 
    census.temp_population;

drop table census.temp_population;

create index if not exists idx_bus_stops_geog_geom_idx
on septa.bus_stops using gist (geog);
create index if not exists idx_bus_shapes_shape_id 
on septa.bus_shapes (shape_id);

alter table septa.rail_stops add column if not exists geog geography;
update septa.rail_stops set geog = st_makepoint(stop_lon, stop_lat)::geography where geog is null;
create index if not exists septa_rail_stops_geog_geom_idx
on septa.rail_stops using gist (geog);
