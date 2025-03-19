/*
 With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
 I used parcel and neighborhood dataset to define Penn's Campus. In the neighborhood dataset, I was able to filter the university city neighborhood. Since land owned by Penn usually begins with something like "UNIV" or "TRUSTEE" in the owner fields, I was able to use the parcel dataset to further filter and define Penn campus area. As a result, there are about 3 Census Blocks contains in the area owned by University of Pennsylvania.
*/


with campus_area as (
    select geog::geometry as geog
    from phl.neighborhoods
    where name = 'UNIVERSITY_CITY'
),

parcels as (
    select
        owner1,
        owner2,
        geog
    from phl.pwd_parcels
    where
        (owner1 ilike '%Univ%')
        or (owner1 ilike '%Trustee%')
        or (owner2 ilike '%Univ%')
        or (owner2 ilike '%Trustee%')
),

campus as (
    select st_intersection(ca.geog, p.geog) as geog
    from campus_area as ca
    inner join parcels as p
        on st_intersects(ca.geog, p.geog)
),

bg_penn as (
    select bg.geoid
    from census.blockgroups_2020 as bg
    inner join campus as c
        on st_intersects(bg.geog, c.geog)
    group by bg.geoid, bg.geog
    having sum(st_area(c.geog)) >= st_area(bg.geog)

)
/*
group by(for each) geoid and geog, calculate area of each block group and make sure it is entirely within campus area
 */

select count(*) as count_block_groups
from bg_penn;
