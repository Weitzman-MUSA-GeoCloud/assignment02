SELECT blockgroups.geoid AS geo_id
FROM census.blockgroups_2020 AS blockgroups
INNER JOIN phl.pwd_parcels AS pp
    ON public.ST_Intersects(
        pp.geog::public.geometry, public.ST_GeomFromText(
            'POINT(-75.192711 39.952208)', 4326
        )
    )
WHERE public.ST_Contains(
    blockgroups.geog::public.geometry, pp.geog::public.geometry
);
