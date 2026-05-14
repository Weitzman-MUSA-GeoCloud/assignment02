/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use
  OpenDataPhilly's neighborhood dataset along with an appropriate dataset
  from the Septa GTFS bus feed. Use the [GTFS documentation]
  (https://gtfs.org/reference/static/) for help. Use some creativity in
  the metric you devise in rating neighborhoods.

*/

SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg
WHERE ST_Within(
    bg.geog::geometry,
    (
        SELECT ST_Union(pp.geog::geometry)
        FROM phl.pwd_parcels pp
        WHERE (
            owner1 LIKE '%univ%penn%'
            OR owner1 LIKE '%penn%univ%'
            OR owner1 LIKE '%univ%penna%'
        )
    )
);
