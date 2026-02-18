# Database Assignment: SEPTA GTFS & Philadelphia Spatial Data Analysis

## Project Overview

This project performs spatial analysis on the Philadelphia public transportation system (SEPTA) GTFS data combined with Philadelphia geographic and census population data using PostgreSQL and PostGIS.

## Database Structure

### Schemas
- **septa**: SEPTA bus and rail transit data
- **phl**: Philadelphia geographic data (parcels and neighborhoods)
- **census**: US Census data

### Main Tables

#### septa Schema
- `bus_stops`: Bus transit stations (13,798 records)
  - Fields: stop_id, stop_name, stop_lat, stop_lon, wheelchair_boarding, etc.
- `bus_routes`: Bus routes (167 records)
  - Fields: route_id, route_short_name, route_long_name, etc.
- `bus_trips`: Bus trips (connects routes and shapes)
  - Fields: trip_id, route_id, service_id, shape_id, etc.
- `bus_shapes`: Bus route geometry points (for constructing routes)
  - Fields: shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence
- `rail_stops`: Rail transit stations (57 records)
  - Fields: stop_id, stop_name, stop_lat, stop_lon

#### phl Schema
- `pwd_parcels`: Philadelphia Water Department parcel data (10,173 records)
  - Geographic column: geog (GEOGRAPHY type)
- `neighborhoods`: Philadelphia neighborhoods (160 neighborhoods)
  - Geographic column: geog (GEOGRAPHY type)

#### census Schema
- `blockgroups_2020`: 2020 US Census block groups (Pennsylvania geographic data)
  - Geographic column: geog (GEOGRAPHY type)
- `population_2020`: 2020 population data (by block group)
  - Fields: geoid, geoname, total (population)

## Query Descriptions

### Query 01: 8 Bus Stops with Largest Population within 800 Meters
**File**: query01.sql
**Method**:
1. Use ST_DWithin to find census block groups within 800 meters of each bus stop
2. Join with population_2020 table using block group geoid to get population data
3. Order by total population in descending order

**Sample Results**:
- Lombard St & 18th St: 57,936 people
- Rittenhouse Sq & 18th St: 57,571 people

### Query 02: 8 Bus Stops with Smallest Population in Philadelphia (800m, >500 people)
**File**: query02.sql
**Method**:
1. Filter census block groups with geoid prefix 42101 (Philadelphia County)
2. Only consider stops with total population > 500
3. Order by population in ascending order

**Sample Results**:
- Delaware Av & Venango St: 593 people
- Delaware Av & Tioga St: 593 people

### Query 03: Each Parcel's Nearest Bus Stop
**File**: query03.sql
**Method**:
1. Use LATERAL JOIN for nearest neighbor search
2. Optimize with KNN operator (<->) for distance ordering
3. Calculate distance and order from largest to smallest
**Performance**: May take 2-3 minutes (140M rows of data)

### Query 04: Two Routes with Longest Trips
**File**: query04.sql
**Method**:
1. Join bus_routes, bus_trips, and bus_shapes tables
2. Use ST_MakeLine to construct line from shape points
3. Calculate total length of each route
4. Order by length and take top 2

**Results**:
- MFL (69th Street Transportation Center): 122 meters
- MFL (Frankford Transportation Center): 119 meters

### Query 05 & 06: Neighborhood Wheelchair Accessibility Rating
**Files**: query05.sql (top 5), query06.sql (bottom 5)
**Accessibility Metric**:
- Definition: (number of accessible stops / total stops) × 100
- wheelchair_boarding = 1 means accessible
- wheelchair_boarding = 0 or 2 means not accessible

**Method**:
1. Use ST_Intersects to find bus stops within each neighborhood
2. Count accessible and inaccessible stops
3. Calculate accessibility percentage

**Top 5 Neighborhoods** (100% accessible):
- ALLEGHENY_WEST (96 stops)
- ANDORRA (20 stops)
- ASTON_WOODBRIDGE (29 stops)

**Bottom 5 Neighborhoods** (lowest accessibility):
- BARTRAM_VILLAGE (0% - 0/14 stops)
- WOODLAND_TERRACE (20% - 2/10 stops)
- SOUTHWEST_SCHUYLKILL (43.4% - 23/53 stops)

### Query 07: Number of Census Block Groups Penn Campus Contains
**File**: query07.sql
**Definition**: Use UNIVERSITY_CITY neighborhood as Penn's main campus boundary
**Method**: Use ST_Contains to check how many block groups are fully contained
**Result**: 11 block groups

### Query 08: Census Block Group Containing Meyerson Hall
**File**: query08.sql
**Method**:
1. Use Meyerson Hall coordinates: 39.9523376, -75.1925003
2. Use ST_Contains to find which block group contains this point
3. Return the block group's geoid
**Result**: 421010192005

### Query 09: Generate Descriptions for Rail Stops
**File**: query09.sql
**Method**:
1. Find nearest bus stop for each rail stop (LATERAL JOIN + KNN)
2. Calculate distance in meters
3. Use ST_Azimuth to calculate direction (N, NE, E, SE, S, SW, W, NW)
4. Generate description: "X meters [direction] of [bus stop name]"

**Sample Results**:
- Cynwyd: "61 meters SW of Bala Av & Montgomery Av"
- Suburban Station: "31 meters NW of JFK Blvd & 17th St"

## Key PostGIS Functions Used

- **ST_DWithin**: Check if two geographic objects are within specified distance
- **ST_Contains**: Check if one geometry contains another
- **ST_Intersects**: Check if two geometries intersect
- **ST_Distance**: Calculate distance between two geographic objects
- **ST_Azimuth**: Calculate bearing from one point to another (in radians)
- **ST_MakeLine**: Construct line from array of points
- **ST_Length**: Calculate length of a line
- **ST_SetSRID**: Set coordinate reference system for geometry
- **ST_Point**: Create point from coordinates
- **KNN operator (<->)**: Index-optimized distance ordering

## Indexes

The following indexes were created to optimize query performance:

```sql
-- B-tree indexes
CREATE INDEX idx_bus_stops_stop_id ON septa.bus_stops(stop_id);
CREATE INDEX idx_bus_routes_route_id ON septa.bus_routes(route_id);
CREATE INDEX idx_bus_trips_trip_id ON septa.bus_trips(trip_id);
CREATE INDEX idx_bus_shapes_shape_id ON septa.bus_shapes(shape_id);
CREATE INDEX idx_population_geoid ON census.population_2020(geoid);

-- GIST indexes for spatial queries
CREATE INDEX idx_pwd_parcels_geog ON phl.pwd_parcels USING GIST(geog);
CREATE INDEX idx_neighborhoods_geog ON phl.neighborhoods USING GIST(geog);
CREATE INDEX idx_blockgroups_geog ON census.blockgroups_2020 USING GIST(geog);
```

## Data Import Instructions

### SEPTA Data (CSV Format)
```bash
COPY septa.bus_stops FROM 'path/to/stops.txt' WITH (FORMAT csv, HEADER true);
COPY septa.bus_routes FROM 'path/to/routes.txt' WITH (FORMAT csv, HEADER true);
COPY septa.bus_trips (route_id, service_id, trip_id, trip_headsign, direction_id, block_id, shape_id)
  FROM 'path/to/trips.txt' WITH (FORMAT csv, HEADER true);
COPY septa.bus_shapes FROM 'path/to/shapes.txt' WITH (FORMAT csv, HEADER true);
COPY septa.rail_stops FROM 'path/to/rail_stops.txt' WITH (FORMAT csv, HEADER true);
```

### Geographic Data (Shapefile/GeoJSON via ogr2ogr)
```bash
ogr2ogr -f "PostgreSQL" PG:"..." -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog -overwrite PWD_PARCELS.shp

ogr2ogr -f "PostgreSQL" PG:"..." -nln phl.neighborhoods \
    -nlt MULTIPOLYGON -lco GEOMETRY_NAME=geog \
    -overwrite Neighborhoods_Philadelphia.geojson

ogr2ogr -f "PostgreSQL" PG:"..." -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog -overwrite tl_2020_42_bg.shp
```

### Census Population Data (CSV)
```bash
COPY census.population_2020 (geoid, geoname, total) 
FROM 'path/to/population.csv' WITH (FORMAT csv, HEADER true);
```

## Technical Details

### Coordinate Reference Systems
- **Input**: EPSG:2272 (feet, for PWD parcels), EPSG:4269 (Census), EPSG:4326 (standard WGS84)
- **Output**: EPSG:4326 (WGS84 latitude/longitude)
- **Geography Type**: Uses spherical distance calculations, no manual projection required

### Performance Considerations
- Query 03 (nearest neighbor) may take 2-3 minutes due to 140M rows of cartesian product
- Query 04 using ST_MakeLine and ST_Length may be slow; alternative is to use shape_dist_traveled field
- GIST indexes significantly accelerate spatial queries

## File Manifest

- `query01.sql` - 8 bus stops with largest population
- `query02.sql` - 8 bus stops with smallest population
- `query03.sql` - Nearest bus stop for each parcel
- `query04.sql` - Two routes with longest trips
- `query05.sql` - Neighborhoods accessibility rating (top 5)
- `query06.sql` - Neighborhoods accessibility rating (bottom 5)
- `query07.sql` - Number of block groups Penn campus contains
- `query08.sql` - Block group containing Meyerson Hall
- `query09.sql` - Descriptive information for rail stops
- `db_structure.sql` - Complete database schema definition

## Notes

1. **Query 03 Performance**: Nearest neighbor queries are slow on large datasets. In production, consider subsampling or spatial index partitioning.

2. **Accessibility Metric (Query 05-06)**: Current metric only considers wheelchair accessibility (wheelchair_boarding field). Real accessibility assessment should include elevators, ramps, tactile paving, etc.

3. **Penn Campus Definition (Query 07)**: Uses UNIVERSITY_CITY neighborhood as proxy for Penn's main campus. More precise definition could use Penn's official campus boundary data.

4. **Geographic Accuracy**: All spatial queries use spherical calculations (geography type), with negligible error for small areas like Philadelphia.

---

**Created**: February 18, 2026
**Database**: assignment2 (PostgreSQL + PostGIS)
**Data Sources**: SEPTA GTFS, OpenDataPhilly, US Census Bureau
