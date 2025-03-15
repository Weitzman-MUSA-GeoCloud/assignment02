
/*
create schema if not exists septa;
create schema if not exists phl;
create schema if not exists census;

create extension if not exists postgis;

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
