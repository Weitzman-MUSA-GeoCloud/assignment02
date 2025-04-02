WITH parcel_bus_stop_distances AS (
    SELECT
        parcels.name AS parcel_address,
        stops.stop_name AS stop_names,
        ROUND(public.ST_Distance(parcels.geog, public.ST_SetSRID(stops.geog, 4326))::INTEGER, 2) AS distance,
        ROW_NUMBER() OVER 
            (PARTITION BY parcels.name
                ORDER BY
                    public.ST_Distance(parcels.geog, public.ST_SetSRID(stops.geog, 4326)) DESC
            )
        AS rn
    FROM
        phl.pwd_parcels AS parcels
    JOIN
        septa.bus_stops AS stops
        ON
            TRUE
)
SELECT
    parcel_address,
    stop_names,
    distance
FROM
    parcel_bus_stop_distances
WHERE
    rn = 1
ORDER BY
    distance DESC;
