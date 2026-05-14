/*
  How many census block groups does Penn's main campus fully contain?

  I use the phl.pwd_parcels dataset to define Penn's campus by filtering parcels
  where the owner name matches Penn trustees, then creating a convex hull boundary. -- noqa: LT05
*/

with penn_campus as (
    select st_convexhull(st_union(geog::geometry)) as campus_geom
    from phl.pwd_parcels
    where
        upper(owner1) like '%TRUSTEES%'
        and (
            upper(owner1) like '%UNIV%PENN%'
            or upper(owner1) like '%U OF P%'
        )
)

select count(*)::integer as count_block_groups
from census.blockgroups_2020 as bg, penn_campus
where st_within(bg.geog::geometry, penn_campus.campus_geom)
