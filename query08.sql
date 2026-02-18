/*
  With a query, find out how many census block groups Penn's main campus fully contains.
  
  For Penn's main campus, I'm using PWD parcels that have "UNIV OF PENN" or similar
  in their owner name. This captures the main campus area. We then check which
  census block groups are fully contained within the combined campus boundary.
*/

with penn_campus as (
    select st_union(geog::geometry)::geography as campus_geog
    from phl.pwd_parcels
    where owner1 like '%UNIV%PENN%' or owner1 like '%UNIVERSITY%PENNSYLVANIA%'
)

select count(*)::integer as count_block_groups
from census.blockgroups_2020 as bg
cross join penn_campus as penn
where st_contains(penn.campus_geog::geometry, bg.geog::geometry)
