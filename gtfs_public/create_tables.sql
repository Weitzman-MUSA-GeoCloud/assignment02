create schema if not exists septa;
create schema if not exists phl;
create schema if not exists census;

DROP TABLE IF EXISTS septa.bus_stops;

CREATE TABLE septa.bus_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type INTEGER,
    parent_station TEXT,
    zone_id TEXT,
    wheelchair_boarding INTEGER
);


COPY septa.bus_stops(stop_id, stop_name, stop_lat, stop_lon, location_type, parent_station, zone_id, wheelchair_boarding)
FROM '/Users/jiatong/Desktop/assignment2/gtfs_public/google_bus/stops.txt'
DELIMITER ',' 
CSV HEADER;


DROP TABLE IF EXISTS septa.bus_routes;

CREATE TABLE septa.bus_routes (
    route_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,
    route_url TEXT
);


COPY septa.bus_routes(route_id, route_short_name, route_long_name, route_type, route_color, route_text_color, route_url)
FROM '/Users/jiatong/Desktop/assignment2/gtfs_public/google_bus/routes.txt'
DELIMITER ',' 
CSV HEADER;


drop table if exists septa.bus_trips;

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


COPY septa.bus_trips(route_id, service_id, trip_id, trip_headsign, block_id, direction_id, shape_id)
FROM '/Users/jiatong/Desktop/assignment2/gtfs_public/google_bus/trips.txt'
DELIMITER ',' 
CSV HEADER;


drop table if exists septa.bus_shapes;
create table septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER,
    shape_dist_traveled DOUBLE PRECISION
);

COPY septa.bus_shapes(shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence)
FROM '/Users/jiatong/Desktop/assignment2/gtfs_public/google_bus/shapes.txt'
DELIMITER ',' 
CSV HEADER;

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

COPY septa.rail_stops(stop_id, stop_name, stop_desc, stop_lat, stop_lon, zone_id, stop_url)
FROM '/Users/jiatong/Desktop/assignment2/gtfs_public/google_rail/stops.txt'
DELIMITER ',' 
CSV HEADER;



drop table if exists census.population_2020;
create table census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);


COPY census.population_2020(geoid, geoname, total)
FROM '/Users/jiatong/Desktop/assignment2/pop2020.csv'
DELIMITER ',' 
CSV HEADER;


