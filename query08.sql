with
ucity as (
    select *
    from phl.neighborhoods
    where starts_with(listname, 'Uni')
)

select count(ucity.listname) as count_block_groups
from census.blockgroups_2020 as block_grps
inner join ucity
    on st_coveredby(block_grps.geog, ucity.geog);
