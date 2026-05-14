-- ============================================================================
-- Database Structure Definition for assignment2
-- Created: 2026-02-17
-- Description: SEPTA GTFS data and Philadelphia geographic/census data
-- ============================================================================

-- ============================================================================
-- SCHEMA CREATION
-- ============================================================================

CREATE SCHEMA septa;
CREATE SCHEMA phl;
CREATE SCHEMA census;

-- ============================================================================
-- SEPTA SCHEMA TABLES
-- ============================================================================

-- Bus Stops Table
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

-- Bus Routes Table
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

-- Bus Trips Table
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

-- Bus Shapes Table
CREATE TABLE septa.bus_shapes (
    shape_id TEXT,
    shape_pt_lat DOUBLE PRECISION,
    shape_pt_lon DOUBLE PRECISION,
    shape_pt_sequence INTEGER,
    shape_dist_traveled DOUBLE PRECISION
);

-- Rail Stops Table
CREATE TABLE septa.rail_stops (
    stop_id TEXT,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    zone_id TEXT,
    stop_url TEXT
);

-- ============================================================================
-- PHL SCHEMA TABLES
-- ============================================================================

-- PWD Parcels Table (loaded via ogr2ogr)
-- Contains Philadelphia property parcels with geometry
CREATE TABLE phl.pwd_parcels (
    ogc_fid INTEGER,
    wkb_geometry GEOMETRY,
    objectid INTEGER,
    cartodb_id INTEGER,
    parcelid TEXT,
    -- Additional fields from shapefile are included
    CONSTRAINT enforce_srid_wkb_geometry CHECK (st_srid(wkb_geometry) = 4326),
    CONSTRAINT enforce_dim_wkb_geometry CHECK (st_ndims(wkb_geometry) = 2),
    CONSTRAINT enforce_geom_type_wkb_geometry CHECK (geometrytype(wkb_geometry) = 'MULTIPOLYGON'::text OR wkb_geometry IS NULL)
);

-- Philadelphia Neighborhoods Table (loaded via ogr2ogr)
-- Contains neighborhood boundaries with geometry
CREATE TABLE phl.neighborhoods (
    ogc_fid INTEGER,
    wkb_geometry GEOMETRY,
    -- Additional fields from shapefile
    CONSTRAINT enforce_srid_wkb_geometry CHECK (st_srid(wkb_geometry) = 4326),
    CONSTRAINT enforce_dim_wkb_geometry CHECK (st_ndims(wkb_geometry) = 2),
    CONSTRAINT enforce_geom_type_wkb_geometry CHECK (geometrytype(wkb_geometry) = 'MULTIPOLYGON'::text OR wkb_geometry IS NULL)
);

-- ============================================================================
-- CENSUS SCHEMA TABLES
-- ============================================================================

-- Census Block Groups 2020 Table (loaded via ogr2ogr)
-- Contains Census block group boundaries with geometry
CREATE TABLE census.blockgroups_2020 (
    ogc_fid INTEGER,
    wkb_geometry GEOMETRY,
    geoid TEXT,
    -- Additional Census fields
    CONSTRAINT enforce_srid_wkb_geometry CHECK (st_srid(wkb_geometry) = 4326),
    CONSTRAINT enforce_dim_wkb_geometry CHECK (st_ndims(wkb_geometry) = 2),
    CONSTRAINT enforce_geom_type_wkb_geometry CHECK (geometrytype(wkb_geometry) = 'MULTIPOLYGON'::text OR wkb_geometry IS NULL)
);

-- Census Population 2020 Table
-- Contains population statistics for geographic areas
CREATE TABLE census.population_2020 (
    geoid TEXT,
    geoname TEXT,
    total INTEGER
);

-- ============================================================================
-- POST-GIS EXTENSION
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================================
-- GEOGRAPHY COLUMNS (Added for better spatial queries)
-- ============================================================================

-- Add geog columns to geographic tables
ALTER TABLE phl.pwd_parcels ADD COLUMN geog GEOGRAPHY(MULTIPOLYGON, 4326);
ALTER TABLE phl.neighborhoods ADD COLUMN geog GEOGRAPHY(MULTIPOLYGON, 4326);
ALTER TABLE census.blockgroups_2020 ADD COLUMN geog GEOGRAPHY(MULTIPOLYGON, 4326);

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- B-tree indexes for common query columns
CREATE INDEX idx_bus_stops_stop_id ON septa.bus_stops(stop_id);
CREATE INDEX idx_bus_routes_route_id ON septa.bus_routes(route_id);
CREATE INDEX idx_bus_trips_trip_id ON septa.bus_trips(trip_id);
CREATE INDEX idx_bus_shapes_shape_id ON septa.bus_shapes(shape_id);
CREATE INDEX idx_population_geoid ON census.population_2020(geoid);

-- GIST indexes for spatial queries on geographic data
CREATE INDEX idx_pwd_parcels_geog ON phl.pwd_parcels USING GIST(geog);
CREATE INDEX idx_neighborhoods_geog ON phl.neighborhoods USING GIST(geog);
CREATE INDEX idx_blockgroups_geog ON census.blockgroups_2020 USING GIST(geog);

-- ============================================================================
-- DATA IMPORT NOTES
-- ============================================================================

-- SEPTA Bus/Rail GTFS Data (CSV format)
-- COPY septa.bus_stops FROM '.../stops.txt' WITH (FORMAT csv, HEADER true);
-- COPY septa.bus_routes FROM '.../routes.txt' WITH (FORMAT csv, HEADER true);
-- COPY septa.bus_trips (route_id, service_id, trip_id, trip_headsign, direction_id, block_id, shape_id) 
--   FROM '.../trips.txt' WITH (FORMAT csv, HEADER true);
-- COPY septa.bus_shapes FROM '.../shapes.txt' WITH (FORMAT csv, HEADER true);
-- COPY septa.rail_stops FROM '.../rail_stops.txt' WITH (FORMAT csv, HEADER true);

-- Philadelphia Water Department Parcels (Shapefile via ogr2ogr)
-- ogr2ogr -f "PostgreSQL" PG:"..." -nln phl.pwd_parcels -nlt MULTIPOLYGON 
--   -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -overwrite PWD_PARCELS.shp

-- Philadelphia Neighborhoods (GeoJSON via ogr2ogr)
-- ogr2ogr -f "PostgreSQL" PG:"..." -nln phl.neighborhoods -nlt MULTIPOLYGON 
--   -lco GEOMETRY_NAME=geog -overwrite Neighborhoods_Philadelphia.geojson

-- Census Block Groups 2020 (Shapefile via ogr2ogr)
-- ogr2ogr -f "PostgreSQL" PG:"..." -nln census.blockgroups_2020 -nlt MULTIPOLYGON 
--   -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -overwrite tl_2020_42_bg.shp

-- Census Population 2020 (CSV - note: requires geoid processing)
-- Columns in source: GEO_ID, NAME, P1_001N, ... (71 columns)
-- Extract: geoid (last 12 chars of GEO_ID), geoname (NAME), total (P1_001N)

-- ============================================================================
-- END OF SCHEMA DEFINITION
-- ============================================================================
