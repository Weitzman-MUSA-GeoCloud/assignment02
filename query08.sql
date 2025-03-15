/*
  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/

with campus_area as (
    select geog::geometry as geog
    from phl.neighborhoods
    where name = 'UNIVERSITY_CITY'
),

penn_parcels as (
    select
        owner1,
        owner2,
        geog
    from phl.pwd_parcels
    where
        (owner1 ilike '%Univ%') or (owner1 ilike '%Trustee%')
        or (owner2 ilike '%Univ%') or (owner2 ilike '%Trustee%')
),

penn_campus as (
    select st_intersection(ca.geog, p.geog) as geog
    from campus_area as ca
    inner join penn_parcels as p
        on st_intersects(ca.geog, p.geog)
),

selected_bg as (
    select bg.geoid
    from census.blockgroups_2020 as bg
    inner join penn_campus as pc
        on st_intersects(bg.geog, pc.geog)
    group by bg.geoid, bg.geog
    having sum(st_area(pc.geog)) >= st_area(bg.geog)
)

select count(*) as count_block_groups
from selected_bg;
