create schema if not exists septa;
create schema if not exists phl;
create schema if not exists census;

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


copy septa.bus_stops (
    stop_id,
    stop_code,
    stop_name,
    stop_desc,
    stop_lat,
    stop_lon,
    zone_id,
    stop_url,
    location_type,
    parent_station,
    stop_timezone,
    wheelchair_boarding
)
from 'C:/Users/super/Downloads/School Work/MUSA 5090/5090assignment02/gtfs_public/google_bus/stops.txt'
delimiter ','
csv header;

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


copy septa.bus_routes (
    route_id,
    agency_id,
    route_short_name,
    route_long_name,
    route_desc,
    route_type,
    route_url,
    route_color,
    route_text_color
)
from 'C:/Users/super/Downloads/School Work/MUSA 5090/5090assignment02/gtfs_public/google_bus/routes.txt'
delimiter ','
csv header;


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


copy septa.bus_trips (
    route_id,
    service_id,
    trip_id,
    trip_headsign,
    trip_short_name,
    direction_id,
    block_id,
    shape_id,
    wheelchair_accessible,
    bikes_allowed
)
from 'C:/Users/super/Downloads/School Work/MUSA 5090/5090assignment02/gtfs_public/google_bus/trips.txt'
delimiter ','
csv header;


drop table if exists septa.bus_shapes;
create table septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER,
    shape_dist_traveled DOUBLE PRECISION
);

copy septa.bus_shapes (
    shape_id,
    shape_pt_lat,
    shape_pt_lon,
    shape_pt_sequence,
    shape_dist_traveled
)
from 'C:/Users/super/Downloads/School Work/MUSA 5090/5090assignment02/gtfs_public/google_bus/shapes.txt'
delimiter ','
csv header;

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

copy septa.rail_stops (
    stop_id, stop_name, stop_desc, stop_lat, stop_lon, zone_id, stop_url
)
from 'C:/Users/super/Downloads/School Work/MUSA 5090/5090assignment02/gtfs_public/google_rail/stops.txt'
delimiter ','
csv header;

drop table if exists census.population_2020;
create table census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

copy census.population_2020 (geoid, geoname, total)
from 'C:/Users/super/Downloads/School Work/MUSA 5090/5090assignment02/DECENNIALPL2020.P1_2025-03-19T213705/pop2020.csv'
delimiter ','
csv header;
