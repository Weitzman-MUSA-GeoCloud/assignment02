/*
You're tasked with giving more contextual information to rail stops
to fill the stop_desc field in a GTFS feed. Using any of the data
sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.),
and PostgreSQL string functions, build a description (alias as stop_desc)
for each stop. Feel free to supplement with other datasets
(must provide link to data used so it's reproducible), and other
methods of describing the relationships. SQL's CASE statements may
be helpful for some operations.
*/

SELECT
    stops.stop_id,
    stops.stop_name,
    stops.stop_lon,
    stops.stop_lat,
    concat(
        round(
            st_distance(
                st_makepoint(stops.stop_lon, stops.stop_lat)::geography,
                neighborhoods.geog
            )::numeric
        ),
        ' meters ',
        CASE
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 22.5 THEN 'N'
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 67.5 THEN 'NE'
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 112.5 THEN 'E'
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 157.5 THEN 'SE'
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 202.5 THEN 'S'
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 247.5 THEN 'SW'
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 292.5 THEN 'W'
            WHEN degrees(st_azimuth(
                st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326),
                st_centroid(st_setsrid(neighborhoods.geog::geometry, 4326))
            )) < 337.5 THEN 'NW'
            ELSE 'N'
        END,
        ' of ',
        neighborhoods.listname,
        ' neighborhood'
    ) AS stop_desc
FROM septa.rail_stops AS stops
CROSS JOIN LATERAL (
    SELECT
        n.listname,
        n.geog
    FROM phl.neighborhoods AS n
    ORDER BY st_makepoint(stops.stop_lon, stops.stop_lat)::geography <-> n.geog
    LIMIT 1
) AS neighborhoods
