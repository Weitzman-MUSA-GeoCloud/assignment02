with penn_parcels as (
    select
        objectid,
        geog
    from phl.pwd_parcels
    where
        owner1 ilike '%TRUSTEES OF THE UNIVERSIT%'
        or owner1 ilike '%TRS UNIV OF PENN%'
        or owner1 ilike '%UNIV OF PENNSYLVANIA%'
        or owner1 ilike '%THE UNIVERSITY OF PENNA%'
        or owner1 ilike '%UNIVERSITY CITY ASSOC%'
        or owner1 ilike '%UNIVERSITY OF%'
        or owner1 ilike '%UPENN%'
        or owner2 ilike '%TRUSTEES OF THE UNIVERSIT%'
        or owner2 ilike '%TRS UNIV OF PENN%'
        or owner2 ilike '%UNIV OF PENNSYLVANIA%'
        or owner2 ilike '%THE UNIVERSITY OF PENNA%'
        or owner2 ilike '%UNIVERSITY CITY ASSOC%'
        or owner2 ilike '%UNIVERSITY OF%'
        or owner2 ilike '%UPENN%'
),

campus as (
    select *
    from penn_parcels as p
    where exists (
        select 1
        from penn_parcels as q
        where
            p.objectid != q.objectid
            and st_distance(p.geog::geometry, q.geog::geometry) < 15
    )
),

covered_blocks as (
    select cb.geoid
    from campus as mp
    inner join census.blockgroups_2020 as cb
        on st_contains(cb.geog::geometry, mp.geog::geometry)
    group by cb.geoid, cb.geog
    having sum(st_area(mp.geog)) >= 0.1 * st_area(cb.geog)
)

select count(*) as count_block_groups
from covered_blocks;