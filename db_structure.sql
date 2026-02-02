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

-- Add a column to the septa.bus_stops table to store the geometry of each stop.
alter table septa.bus_stops
add column if not exists geog geography;

ALTER TABLE septa.bus_stops ALTER COLUMN stop_code DROP NOT NULL;

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);


create schema if not exists septa;
create schema if not exists phl;
create schema if not exists census;

drop table if exists septa.bus_stops;


create table septa.bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type INTEGER,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding INTEGER
);

drop table if exists septa.bus_routes;

create table septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);



drop table if exists septa.bus_trips;
create table septa.bus_trips (
    route_id TEXT,
    service_id TEXT,
    trip_id TEXT,
    trip_headsign TEXT,
    block_id TEXT,
    direction_id TEXT,
    shape_id TEXT
);


drop table if exists septa.bus_shapes;
create table septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER
);



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



drop table if exists census.population_2020;
create table census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

create extension if not exists postgis;

--CREATE TABLES THEN LOAD DATA--
\copy septa.bus_stops(stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station,zone_id,wheelchair_boarding) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/stops.txt' WITH  CSV HEADER DELIMITER ',' ;

\copy septa.bus_routes(route_id,route_short_name,route_long_name,route_type,route_color,route_text_color,route_url) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/routes.txt' WITH  CSV HEADER;

\copy septa.bus_trips (route_id,service_id,trip_id,trip_headsign,block_id,direction_id,shape_id) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/trips.txt' WITH  CSV HEADER;

\copy septa.bus_shapes (stop_id,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url)FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/shapes.txt' WITH  CSV HEADER;

\copy septa.rail_stops (stop_id,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/stops_rail.txt' WITH  CSV HEADER;

\copy census.population_2020 (geoid,geoname,total) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/pop2020.csv' WITH  CSV HEADER ;



ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=Xllxl@ntihacker7" "C:\Users\Xian Lu Lee\OneDrive - PennO365\Datasets\GeoCloud\musa-geocloud-assm02\data\PWD_PARCELS.geojson" -nln "phl.pwd_parcels" -nlt MULTIPOLYGON -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -lco GEOM_TYPE=GEOGRAPHY


ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=Xllxl@ntihacker7" "C:\Users\Xian Lu Lee\OneDrive - PennO365\Datasets\GeoCloud\musa-geocloud-assm02\data\philadelphia-neighborhoods.geojson" -nln "phl.neighborhoods" -nlt MULTIPOLYGON -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -lco GEOM_TYPE=GEOGRAPHY

ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=Xllxl@ntihacker7" "C:\Users\Xian Lu Lee\OneDrive - PennO365\Datasets\GeoCloud\musa-geocloud-assm02\data\tl_2020_42_bg.shp" -nln "census.blockgroups_2020" -nlt MULTIPOLYGON -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -lco GEOM_TYPE=GEOGRAPHY