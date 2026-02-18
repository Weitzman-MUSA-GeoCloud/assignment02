/*
With a query involving PWD parcels and census block groups,
find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint()
and functions like that are not allowed.
Structure (should be a single value):
*/

SELECT census.blockgroups_2020.geoid AS geo_id
FROM
    phl.pwd_parcels
INNER JOIN census.blockgroups_2020
    ON public.ST_Intersects(
        phl.pwd_parcels.geog,
        census.blockgroups_2020.geog
    )
WHERE
    phl.pwd_parcels.address LIKE '%MEYERSON%'
    OR phl.pwd_parcels.address LIKE '%WALNUT%'
LIMIT 1;
