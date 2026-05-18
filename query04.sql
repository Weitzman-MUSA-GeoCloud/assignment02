/*
  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.

  **Structure:**
  ```sql
  (
      route_short_name text,  -- The short name of the route
      trip_headsign text,  -- Headsign of the trip
      shape_geog geography,  -- The shape of the trip
      shape_length numeric  -- Length of the trip in meters, rounded to the nearest whole number
  )
  ```
*/

with shape_geoms as (
    select
        shape_id,
        st_makeline(st_setsrid(st_point(shape_pt_lon, shape_pt_lat), 4326) order by shape_pt_sequence) as geom
    from septa.bus_shapes
    group by shape_id
),

trip_lengths as (
    select
        t.route_id,
        t.trip_id,
        t.trip_headsign,
        s.geom,
        st_length(s.geom::geography) as shape_length
    from septa.bus_trips as t
    inner join shape_geoms as s on t.shape_id = s.shape_id
),

longest_trips_by_route as (
    select distinct on (r.route_short_name)
        r.route_short_name,
        t.trip_headsign,
        t.geom as shape_geog,
        t.shape_length
    from trip_lengths as t
    inner join septa.bus_routes as r on t.route_id = r.route_id
    order by r.route_short_name, t.shape_length desc
)

select
    route_short_name,
    trip_headsign,
    round(shape_length) as shape_length
from longest_trips_by_route
order by shape_length desc
limit 2;
