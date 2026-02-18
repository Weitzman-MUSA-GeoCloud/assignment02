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
CREATE EXTENSION IF NOT EXISTS postgis;

alter table septa.bus_stops
add column if not exists geog public.geography;

update septa.bus_stops
set geog = public.st_makepoint(stop_lon, stop_lat)::public.geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);


CREATE INDEX IF NOT EXISTS phl_pwd_parcels__geog__idx
ON phl.pwd_parcels USING GIST (geog);

CREATE INDEX IF NOT EXISTS septa_bus_stops__geog__idx
ON septa.bus_stops USING GIST (geog);

-- Add geography column to rail_stops
ALTER TABLE septa.rail_stops
ADD COLUMN IF NOT EXISTS geog public.geography;

UPDATE septa.rail_stops
SET geog = ST_MakePoint(stop_lon, stop_lat)::public.geography;

-- Create spatial index
CREATE INDEX IF NOT EXISTS septa_rail_stops__geog__idx
ON septa.rail_stops USING GIST (geog);