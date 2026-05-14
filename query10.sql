SELECT
    s.stop_id,
    s.stop_name,
    'Stop ' || s.stop_name ||
    ' is located in ' || n.name ||
    ', serving the surrounding community.' AS stop_desc
FROM septa.bus_stops s
JOIN phl.neighborhoods n
    ON ST_Intersects(s.geog, n.geog);
