/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.
As an example, your stop_desc for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)
*/

SELECT
    septa.rail_stops.stop_id::integer,
    septa.rail_stops.stop_name,
    septa.rail_stops.stop_lon,
    septa.rail_stops.stop_lat,
    CONCAT(
        'Located in ',
        COALESCE(phl.neighborhoods.name, 'Greater Philadelphia Area'),
        ' neighborhood'
    ) AS stop_desc
FROM septa.rail_stops
LEFT JOIN phl.neighborhoods
    ON public.ST_Intersects(
        public.ST_SetSRID(
            public.ST_Point(septa.rail_stops.stop_lon, septa.rail_stops.stop_lat),
            4326
        )::public.geography,
        phl.neighborhoods.geog
    );
