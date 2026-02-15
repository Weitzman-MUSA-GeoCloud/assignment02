/* With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed. */
set search_path = public  


WITH parcel_candidates AS (
  SELECT
    p.*
  FROM phl.pwd_parcels p
  WHERE ST_XMin(p.geog::geometry) <= -75.192584
    AND ST_XMax(p.geog::geometry) >= -75.192584
    AND ST_YMin(p.geog::geometry) <=  39.952415
    AND ST_YMax(p.geog::geometry) >=  39.952415
)
SELECT DISTINCT
  bg.geoid AS geo_id
FROM census.blockgroups_2020 bg
JOIN parcel_candidates pc
  ON ST_Covers(bg.geog, pc.geog);


