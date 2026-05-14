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

update septa.bus_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

-- Create an index on the geog column.
create index if not exists septa_bus_stops__geog__idx
on septa.bus_stops using gist
(geog);

-- Functional geometry index used by the <-> KNN operator in query03.
-- The KNN operator requires geometry type; casting geog::geometry at query time
-- only hits an index if the index is built on the same cast expression.
create index if not exists septa_bus_stops__geom__idx
on septa.bus_stops using gist
((geog::geometry));

-- Add a geography column to septa.rail_stops for spatial queries (query10).
alter table septa.rail_stops
add column if not exists geog geography;

update septa.rail_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

create index if not exists septa_rail_stops__geog__idx
on septa.rail_stops using gist
(geog);

-- Index on bus_shapes.shape_id to speed up the join with bus_trips (query04).
create index if not exists septa_bus_shapes__shape_id__idx
on septa.bus_shapes (shape_id);

-- Index on bus_trips.shape_id for the same join (query04).
create index if not exists septa_bus_trips__shape_id__idx
on septa.bus_trips (shape_id);
