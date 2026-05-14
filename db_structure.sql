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

alter table septa.rail_stops
add column if not exists geog geography;

update septa.rail_stops
set geog = st_makepoint(stop_lon, stop_lat)::geography;

create index if not exists septa_rail_stops__geog__idx
on septa.rail_stops using gist
(geog);

create index if not exists phl_pwd_parcels__geog__idx
on phl.pwd_parcels using gist
(geog);

create index if not exists phl_neighborhoods__geog__idx
on phl.neighborhoods using gist
(geog);

create index if not exists census_blockgroups_2020__geog__idx
on census.blockgroups_2020 using gist
(geog);

create index if not exists septa_bus_shapes__shape_id__shape_pt_sequence__idx
on septa.bus_shapes (shape_id, shape_pt_sequence);

create index if not exists septa_bus_trips__shape_id__idx
on septa.bus_trips (shape_id);

create index if not exists septa_bus_trips__route_id__idx
on septa.bus_trips (route_id);

create index if not exists septa_bus_routes__route_id__idx
on septa.bus_routes (route_id);

create index if not exists census_population_2020__geoid__idx
on census.population_2020 (geoid);

create index if not exists census_blockgroups_2020__geoid__idx
on census.blockgroups_2020 (geoid);