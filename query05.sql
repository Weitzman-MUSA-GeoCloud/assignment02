/*
5. Rate neighborhoods by their bus stop accessibility for wheelchairs. Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.
*/

/*
  Rate neighborhoods by bus stop wheelchair accessibility.

  Metric:
    - total_stops: all stops inside the neighborhood
    - accessible_stops: wheelchair_boarding = 1
    - share_accessible = accessible_stops / total_stops
    - accessible_per_sqkm = accessible_stops / area_sqkm
    - score = share_accessible * accessible_per_sqkm

  Notes:
    - wheelchair_boarding meanings (GTFS):
        0 = unknown, 1 = accessible, 2 = not accessible
    - We assign stops to neighborhoods using ST_Covers (includes boundary).
*/

with
neighborhood_area as (
  select
    n.*,
    (st_area(n.geog) / 1000000.0) as area_sqkm
  from phl.neighborhoods as n
),

stops_in_neighborhood as (
  select
    n.name as neighborhood_name,
    n.area_sqkm,
    s.wheelchair_boarding
  from neighborhood_area as n
  join septa.bus_stops as s
    on st_covers(n.geog, s.geog)
),

neighborhood_counts as (
  select
    neighborhood_name,
    max(area_sqkm) as area_sqkm,

    count(*) as total_stops,

    sum(case when wheelchair_boarding = 1 then 1 else 0 end) as accessible_stops,
    sum(case when wheelchair_boarding = 2 then 1 else 0 end) as not_accessible_stops,
    sum(case when wheelchair_boarding = 0 or wheelchair_boarding is null then 1 else 0 end) as unknown_stops

  from stops_in_neighborhood
  group by neighborhood_name
),

neighborhood_scores as (
  select
    neighborhood_name,
    area_sqkm,
    total_stops,
    accessible_stops,
    not_accessible_stops,
    unknown_stops,

    (accessible_stops::numeric / nullif(total_stops, 0)) as share_accessible,
    (accessible_stops::numeric / nullif(area_sqkm, 0)) as accessible_per_sqkm,

    ((accessible_stops::numeric / nullif(total_stops, 0))
      * (accessible_stops::numeric / nullif(area_sqkm, 0))) as score

  from neighborhood_counts
)
select
  neighborhood_name,
  round(area_sqkm::numeric, 2) as area_sqkm,
  total_stops,
  accessible_stops,
  not_accessible_stops,
  unknown_stops,
  round(share_accessible::numeric, 3) as share_accessible,
  round(accessible_per_sqkm::numeric, 2) as accessible_per_sqkm,
  round(score::numeric, 3) as accessibility_score
from neighborhood_scores
order by accessibility_score desc;


