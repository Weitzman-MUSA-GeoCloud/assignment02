COPY septa.bus_stops (
    stop_id,
    stop_name,
    stop_lat,
    stop_lon,
    location_type,
    parent_station,
    zone_id,
    wheelchair_boarding
)
FROM 'C:/Users/seank/Documents/Penn/Cloud Computing/Postgres Data/gtfs_assignment_2/google_bus/stops.txt'
CSV HEADER;

COPY septa.bus_routes (
    route_id,
    route_short_name,
    route_long_name,
    route_type,
    route_color,
    route_text_color,
    route_url
)
FROM 'C:/Users/seank/Documents/Penn/Cloud Computing/Postgres Data/gtfs_assignment_2/google_bus/routes.txt'
CSV HEADER;

COPY septa.bus_trips (
    route_id,
    service_id,
    trip_id,
    trip_headsign,
    block_id,
    direction_id,
    shape_id
)
FROM 'C:/Users/seank/Documents/Penn/Cloud Computing/Postgres Data/gtfs_assignment_2/google_bus/trips.txt'
CSV HEADER;

COPY septa.bus_shapes (
    shape_id,
    shape_pt_lat,
    shape_pt_lon,
    shape_pt_sequence
)
FROM 'C:/Users/seank/Documents/Penn/Cloud Computing/Postgres Data/gtfs_assignment_2/google_bus/shapes.txt'
CSV HEADER;

COPY septa.rail_stops (
    stop_id,
    stop_name,
    stop_desc,
    stop_lat,
    stop_lon,
    zone_id,
    stop_url
)
FROM 'C:/Users/seank/Documents/Penn/Cloud Computing/Postgres Data/gtfs_assignment_2/google_rail/stops.txt'
CSV HEADER;

COPY census.population_2020 (
    geoid,
    geoname,
    total
)
FROM 'C:/Users/seank/Documents/Penn/Cloud Computing/Postgres Data/census_pop.csv'
CSV HEADER;