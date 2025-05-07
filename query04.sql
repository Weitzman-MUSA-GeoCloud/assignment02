WITH trip_shapes AS (
    SELECT
        br.route_short_name,
        bt.trip_headsign,
        ST_MakeLine(
            ARRAY(
                SELECT ST_SetSRID(ST_MakePoint(bs.shape_pt_lon, bs.shape_pt_lat), 4326)
                FROM septa.bus_shapes bs
                WHERE bs.shape_id = bt.shape_id
                ORDER BY bs.shape_pt_sequence
            )
        ) AS shape_geog,
        ROUND(ST_Length(
            ST_MakeLine(
                ARRAY(
                    SELECT ST_SetSRID(ST_MakePoint(bs.shape_pt_lon, bs.shape_pt_lat), 4326)
                    FROM septa.bus_shapes bs
                    WHERE bs.shape_id = bt.shape_id
                    ORDER BY bs.shape_pt_sequence
                )
            )
        )) AS shape_length
    FROM 
        septa.bus_routes br
    JOIN 
        septa.bus_trips bt ON br.route_id = bt.route_id
    GROUP BY
        br.route_short_name, bt.trip_headsign, bt.shape_id
)
SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM
    trip_shapes
ORDER BY
    shape_length DESC
LIMIT 2;
