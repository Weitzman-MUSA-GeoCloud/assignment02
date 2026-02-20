/*
  You're tasked with giving more contextual information to rail stops
  to fill the stop_desc field in a GTFS feed. Using any of the data sets
  above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and
  PostgreSQL string functions, build a description (alias as stop_desc)
  for each stop. Feel free to supplement with other datasets (must provide
  link to data used so it's reproducible), and other methods of describing
  the relationships. SQL's CASE statements may be helpful for some operations.

  Structure:

  (
    stop_id integer,
    stop_name text,
    stop_desc text,
    stop_lon double precision,
    stop_lat double precision
  )

  As an example, your stop_desc for a station stop may be something like
  "37 meters NE of 1234 Market St" (that's only an example, feel free to
  be creative, silly, descriptive, etc.)

  Tip when experimenting: Use subqueries to limit your query to just a few
  rows to keep query times faster. Once your query is giving you answers
  you want, scale it up. E.g., instead of FROM tablename, use
  FROM (SELECT * FROM tablename limit 10) as t.
*/

with liberty_bell as (
    -- Liberty Bell coordinates as ref point.
    select st_setsrid(
        st_makepoint(-75.15031592068193, 39.949548328739006),
        4326
    )::geography as geog
),

rail_stops_with_geom as (
    select
        rail_stops.stop_id,
        rail_stops.stop_name,
        rail_stops.stop_lat,
        rail_stops.stop_lon,
        -- Rail stop coordinates to geography for distance.
        st_setsrid(
            st_makepoint(rail_stops.stop_lon, rail_stops.stop_lat),
            4326
        )::geography as stop_geog
    from septa.rail_stops
),

distance_to_liberty_bell as (
    -- Calculate distance from rail stops to Liberty Bell.
    select
        rail_geom.stop_id,
        round(
            st_distance(rail_geom.stop_geog, bell.geog)::numeric,
            0
        ) as distance_meters
    from rail_stops_with_geom as rail_geom
    cross join liberty_bell as bell
),

containing_neighborhood as (
    -- Find which neighborhood contains rail stop.
    select
        rail_geom.stop_id,
        neighborhoods.name as neighborhood_name
    from rail_stops_with_geom as rail_geom
    left join phl.neighborhoods
        on st_within(
            rail_geom.stop_geog::geometry,
            st_setsrid(neighborhoods.geog::geometry, 4326)
        )
)

-- Combine Liberty Bell distance and neighborhood into description,
-- and reorder columns according to assignment.
select
    final.stop_id,
    final.stop_name,
    final.stop_desc,
    final.stop_lon,
    final.stop_lat
from (
    select
        rail_geom.stop_id,
        rail_geom.stop_name,
        rail_geom.stop_lon,
        rail_geom.stop_lat,
        concat(
            distance_to_liberty_bell.distance_meters::text,
            'm from LETTING FREEDOM RING! 🔔🦅 #',
            upper(coalesce(containing_neighborhood.neighborhood_name, 'Philadelphia'))
        ) as stop_desc
    from rail_stops_with_geom as rail_geom
    left join distance_to_liberty_bell on rail_geom.stop_id = distance_to_liberty_bell.stop_id
    left join containing_neighborhood on rail_geom.stop_id = containing_neighborhood.stop_id
) as final
order by final.stop_id;

/*
AI used to help with query. Free model Claude Haiku 4.5.

Prompt:
Don't give me answer. Having trouble with upper function where
"function upper(record) does not exist", what's the issue behind
that error? On that note is there a function to reorder columns in
the final table?

(Resolved by using coalesce to handle null neighborhood names, and by
selecting columns in desired order in final select statement.)
*/
