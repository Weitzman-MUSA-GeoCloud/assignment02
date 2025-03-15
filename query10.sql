/*
You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop.
Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships.
SQL's `CASE` statements may be helpful for some operations.
*/

--Number of drinking fountains in 500metre radius https://opendataphilly.org/datasets/ppr-hydration-stations/
SELECT 
    stops.stop_id,
	stops.stop_name,
    COUNT(hs.geog) AS num_hydration_stations
FROM septa.rail_stops AS stops
LEFT JOIN phl.Hydration_Stations AS hs
    ON ST_DWithin(stops.geog, hs.geog, 500)
GROUP BY stops.stop_id, stops.stop_name
;