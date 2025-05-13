COPY septa.rail_stops (
    stop_id,
    stop_name,
    stop_desc,
    stop_lat,
    stop_lon,
    zone_id,
    stop_url
)
FROM '/Users/claudia/geocloud-assignment02/Data/rail_stops.txt'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY septa.bus_stops (
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
FROM '/Users/claudia/geocloud-assignment02/Data/stops.txt'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY septa.bus_routes (
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
FROM '/Users/claudia/geocloud-assignment02/Data/routes.txt'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY septa.bus_trips (
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
FROM '/Users/claudia/geocloud-assignment02/Data/trips.txt'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

COPY septa.bus_shapes (
    shape_id,
    shape_pt_lat,
    shape_pt_lon,
    shape_pt_sequence,
    shape_dist_traveled
)
FROM '/Users/claudia/geocloud-assignment02/Data/shapes.txt'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);