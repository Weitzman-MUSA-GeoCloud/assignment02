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

with shape_lengths as(
  select
    shape_id,
    round(
      st_length(
        st_makeline(
          st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326)
          order by shape_pt_sequence
        )::geography
      )
    ) as shape_length
  from septa.bus_shapes
  group by shape_id
),
trip_info as (
  select
    route.route_short_name,
    trip.trip_headsign,
    shape.shape_length,
    row_number() over (order by shape.shape_length desc) as rownumber
  from shape_lengths as shape
  inner join septa.bus_trips as trip on shape.shape_id = trip.shape_id
  inner join septa.bus_routes as route on trip.route_id = route.route_id
)
select
  route_short_name,
  trip_headsign,
  round(shape_length::numeric) as shape_length
from trip_info
where rownumber <= 2;
