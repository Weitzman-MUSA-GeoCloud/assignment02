-- Active: 1770745616986@@127.0.0.1@5433@assignment02

    create schema if not exists septa;
    create schema if not exists phl;
    create schema if not exists census;


    create extension if not exists postgis;

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

DROP TABLE septa.bus_routes;
CREATE TABLE septa.bus_routes (
    route_id TEXT,
    agency_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_desc TEXT,
    route_type TEXT,
    route_url TEXT,
    route_color TEXT,
    route_text_color TEXT,
    network_id TEXT
);

DROP TABLE septa.bus_trips;
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


DROP TABLE septa.bus_shapes;
CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER,
    shape_dist_traveled DOUBLE PRECISION
);

DROP TABLE septa.rail_stops;
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

docker exec -it postgis psql -U postgres

docker exec -it postgis bash

census.blockgroups_2020


ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment02 user=postgres password=postgres" `
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/PWD_PARCELS.shp"

    --trying again
    ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment02 user=postgres password=postgres" `
    -nln phl.pwd_parcels2 `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/parcels/PWD_PARCELS.shp"

    ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment02 user=postgres password=postgres" `
    -nln phl.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/philadelphia-neighborhoods.geojson"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment02 user=postgres password=postgres" `
    -nln census.blockgroups_2020 `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/tl_2020_42_bg/tl_2020_42_bg.shp"

    csvcut -c 1-3 "C:\Users\antho\OneDrive\Documents\GitHub\MUSA 5090\pg-mount\DECENNIALPL2020.P1-Data.csv" > census_data.csv


ogr2ogr -f "PostgreSQL" `
PG:"host=localhost port=5433 dbname=assignment02 user=postgres password=postgres" `
-nln census.block_groups_new `
-t_srs EPSG:4326 `
"C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/Census_Block_Groups_in_2020.geojson"

--add geog to bus stops

CREATE EXTENSION postgis;

ALTER TABLE bus_stops
ADD COLUMN geog GEOGRAPHY(Point, 4326);

UPDATE bus_stops
SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography;

--Penn campus

   ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment02 user=postgres password=postgres" `
    -nln phl.PennCampus `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/PennCampus.geojson"

--wawas


   ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment02 user=postgres password=postgres" `
    -nln phl.wawas `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -overwrite `
    "C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/Wawas.json"



  --  in the container:

    ogr2ogr \
    -f "PostgreSQL" \
    PG:"host=localhost port=5432 dbname=assignment02 user=postgres password=postgres" \
    -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "/pg-mount/PWD_PARCELS.shp"

    