WITH trip_lengths AS (
    SELECT
        routes.route_short_name,
        trips.trip_headsign,
        public.ST_MakeLine(
            public.ST_SetSRID(
                public.ST_MakePoint(shapes.shape_pt_lon, shapes.shape_pt_lat), 4326
            )
        ) AS shape_geog,
        ROUND(public.ST_Length(
            public.ST_MakeLine(
                public.ST_SetSRID(
                    public.ST_MakePoint(
                        shapes.shape_pt_lon, shapes.shape_pt_lat
                    ), 4326
                )
            )
        )::INTEGER, 0) AS shape_length,
        ROW_NUMBER() OVER (
            ORDER BY SUM(shapes.shape_dist_traveled) DESC
        ) AS rank
    FROM
        septa.bus_trips AS trips
    JOIN
        septa.bus_shapes AS shapes
        ON
            trips.shape_id = shapes.shape_id
    JOIN
        septa.bus_routes AS routes
        ON
            trips.route_id = routes.route_id
    GROUP BY
        routes.route_short_name, trips.trip_headsign
)
SELECT
    route_short_name,
    trip_headsign,
    shape_geog,
    shape_length
FROM
    trip_lengths
WHERE
    rank <= 2
ORDER BY
    shape_length DESC;
