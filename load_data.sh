ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment_02 user=postgres password=postgres" `
    -nln phl.pwd_parcels `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -lco PRECISION=NO `
    -overwrite `
    "data/PhillyWater_PWD_PARCELS2025/PhillyWater_PWD_PARCELS2025.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment_02 user=postgres password=postgres" `
    -nln phl.neighborhoods `
    -nlt MULTIPOLYGON `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -lco PRECISION=NO `
    -overwrite `
    "data/philadelphia-neighborhoods/philadelphia-neighborhoods.shp"

ogr2ogr `
    -f "PostgreSQL" `
    PG:"host=localhost port=5433 dbname=assignment_02 user=postgres password=postgres" `
    -nln census.blockgroups_2020  `
    -nlt MULTIPOLYGON `
    -t_srs EPSG:4326 `
    -lco GEOMETRY_NAME=geog `
    -lco GEOM_TYPE=GEOGRAPHY `
    -lco PRECISION=NO `
    -overwrite `
    "data/tl_2020_42_bg/tl_2020_42_bg.shp"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.rail_stops (stop_id, stop_name, stop_desc, stop_lat, stop_lon, zone_id, stop_url) FROM 'data/gtfs_public/google_rail/stops.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_stops (stop_id, stop_name, stop_lat, stop_lon, location_type, parent_station, zone_id, wheelchair_boarding) FROM 'data/gtfs_public/google_bus/stops.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_routes (route_id, route_short_name, route_long_name, route_type, route_color, route_text_color, route_url) FROM 'data/gtfs_public/google_bus/routes.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_trips (route_id, service_id, trip_id, trip_headsign, block_id, direction_id, shape_id) FROM 'data/gtfs_public/google_bus/trips.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy septa.bus_shapes (shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence) FROM 'data/gtfs_public/google_bus/shapes.txt' WITH (FORMAT csv, HEADER true);"

psql -h localhost -p 5433 -U postgres -d assignment_02 -c "\copy census.temp_population FROM 'data/population_2020.csv' WITH (FORMAT csv, HEADER true);"
