SELECT * FROM (
    SELECT
        neighborhood_name,
        num_bus_stops_accessible::integer AS num_bus_stops_accessible,
        num_bus_stops_inaccessible::integer AS num_bus_stops_inaccessible,
        ROUND(
            accessible_visits::numeric / NULLIF(accessible_visits + inaccessible_visits, 0),
            4
        ) AS accessibility_metric
    FROM (
        SELECT
            neighborhood_name,
            SUM(CASE WHEN wheelchair_boarding = 1 THEN weekly_visits ELSE 0 END) AS accessible_visits,
            SUM(CASE WHEN wheelchair_boarding = 2 THEN weekly_visits ELSE 0 END) AS inaccessible_visits,
            COUNT(*) FILTER (WHERE wheelchair_boarding = 1) AS num_bus_stops_accessible,
            COUNT(*) FILTER (WHERE wheelchair_boarding = 2) AS num_bus_stops_inaccessible
        FROM (
            SELECT
                n.name AS neighborhood_name,
                s.wheelchair_boarding,
                COALESCE(v.weekly_visits, 0) AS weekly_visits
            FROM phl.neighborhoods AS n
            INNER JOIN septa.bus_stops AS s
                ON ST_INTERSECTS(n.geog, s.geog)
            LEFT JOIN (
                SELECT
                    st.stop_id::numeric AS stop_id,
                    SUM(tw.days_per_week) AS weekly_visits
                FROM septa.bus_stop_times AS st
                INNER JOIN (
                    SELECT
                        t.trip_id,
                        (
                            c.monday + c.tuesday + c.wednesday + c.thursday
                            + c.friday + c.saturday + c.sunday
                        ) AS days_per_week
                    FROM septa.bus_trips AS t
                    INNER JOIN septa.bus_calendar AS c USING (service_id)
                ) AS tw USING (trip_id)
                GROUP BY st.stop_id::numeric
            ) AS v ON s.stop_id = v.stop_id
            WHERE s.wheelchair_boarding IN (1, 2)
        ) AS stops_with_neighborhood
        GROUP BY neighborhood_name
    ) AS neighborhood_stats
    WHERE accessible_visits + inaccessible_visits > 0
    ORDER BY accessibility_metric DESC, num_bus_stops_accessible DESC
    LIMIT 5
) AS top5;
