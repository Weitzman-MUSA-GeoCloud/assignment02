/*
  Using the bus_shapes, bus_routes, and bus_trips tables from GTFS
  bus feed, find the two routes with the longest trips.

  Your query should run in under two minutes.

  HINT: The ST_MakeLine function is useful here. You can see an example
  of how you could use it at this MobilityData walkthrough on using
  GTFS data. If you find other good examples, please share them in Slack.

  HINT: Use the query planner (EXPLAIN) to see if there might be
  opportunities to speed up your query with indexes. For reference, I got
  this query to run in about 15 seconds.

  HINT: The row_number window function could also be useful here. You can
  read more about window functions in the PostgreSQL documentation. That
  documentation page uses the rank function, which is very similar to
  row_number.

  Structure:

  (
    route_short_name text,  -- The short name of the route
    trip_headsign text,  -- Headsign of the trip
    shape_length numeric  -- Length of the trip in meters, rounded to the nearest meter
  )
*/

with shape_lengths as (
    -- Reconstruct each bus route shape as single line geometry,
    -- then measure meters length.
    select
        shape_id,
        round(
            st_length(
                -- Build line from shape points, ordered by sequence
                -- for right path direction.
                st_makeline(
                    st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326)
                    order by shape_pt_sequence
                -- Cast to geography to get meters distance.
                )::geography
            )
        ) as shape_length
    from septa.bus_shapes
    -- Aggregate all points belonging to same shape into one line.
    group by shape_id
),

unique_trips as (
    select
        -- 1 shape to 1 trip and route before ranking to prevent duplicates.
        distinct on (shape.shape_id)
        shape.shape_id,
        shape.shape_length,
        trip.trip_headsign,
        route.route_short_name
    from shape_lengths as shape
    inner join septa.bus_trips as trip on shape.shape_id = trip.shape_id
    inner join septa.bus_routes as route on trip.route_id = route.route_id
    order by shape.shape_id
)

trip_info as (
    -- Rank unique shapes from longest to shortest.
    select
        route_short_name,
        trip_headsign,
        shape_length,
        row_number() over (order by shape_length desc) as rownumber
    from unique_trips
)

-- Return two trips w/ biggest shape length.
select
    route_short_name,
    trip_headsign,
    shape_length
from trip_info
where rownumber <= 2;

/*
AI used to help with query. Free model Claude Haiku 4.5.

Prompt:
Don't give me answer. I'm having duplication issues and
a single-row issue when I use distinct. Is there something
wrong in my logic or conceptual understanding of how I'm
tackling this question?

Original, no distinct clause:
"130"    "Bucks County Community College"    46505
"130"    "Bucks County Community College"    46505

Distinct clause added:
"130"    "Bucks County Community College"    46505

Expected:
route_short_name,trip_headsign,shape_length
"130","Bucks County Community College",46684
"128","Oxford Valley Mall",44044
*/
