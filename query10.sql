SELECT
    rail.stop_id,
    rail.stop_name,
    CONCAT(COUNT(bus.stop_id), ' bus stops within 500 m') AS stop_desc,
    rail.stop_lon,
    rail.stop_lat
FROM
    septa.rail_stops AS rail
LEFT JOIN
    septa.bus_stops AS bus
    ON
        public.ST_DWithin(
            public.ST_SetSRID(public.ST_MakePoint(rail.stop_lon, rail.stop_lat), 4326),
            bus.geog,
            500
        )
GROUP BY
    rail.stop_id, rail.stop_name, rail.stop_lon, rail.stop_lat
ORDER BY
    rail.stop_id;
