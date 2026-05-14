/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use
  OpenDataPhilly's neighborhood dataset along with an appropriate dataset
  from the Septa GTFS bus feed. Use the [GTFS documentation]
  (https://gtfs.org/reference/static/) for help. Use some creativity in
  the metric you devise in rating neighborhoods.

*/

SELECT bg.geoid AS geo_id
FROM census.blockgroups_2020 bg
JOIN phl.pwd_parcels p
  ON ST_Within(p.geog::geometry, bg.geog::geometry)
WHERE p.address LIKE '220-30 S 34TH ST';
