# Assignment 02

**Complete by February 18, 2026**

This assignment will work similarly to assignment #1. To complete this assigment you will need to do the following:
1.  Fork this repository to your own account.
2.  Clone your fork to your local machine.
3.  Complete the assignment according to the instructions below.
4.  Push your changes to your fork.
5.  Submit a pull request to the original repository. Opening your pull request will be equivalent to you submitting your assignment. You will only need to open one pull request for this assignment. **If you make additional changes to your fork, they will automatically show up in the pull request you already opened.** Your pull request should have your name in the title (e.g. `Assignment 02 - Mjumbe Poe`).

----------------

## Instructions

Write a query to answer each of the questions below.
* Your queries should produce results in the format specified by each question.
* Write your query in a SQL file corresponding to the question number (e.g. a file named _query06.sql_ for the answer to question #6).
* Each SQL file should contain a single query that retrieves data from the database (i.e. a `SELECT` query).
* Some questions include a request for you to discuss your methods. Update this README file with your answers in the appropriate place.

### Initial database structure

There are several datasets that are prescribed for you to use in this part. Below you will find table creation DDL statements that define the initial structure of your tables. Over the course of the assignment you may end up adding columns or indexes to these initial table structures. **You should put SQL that you use to modify the schema (e.g. SQL that creates indexes or update columns) should in the _db_structure.sql_ file.**

*   `septa.bus_stops` ([SEPTA GTFS](https://github.com/septadev/GTFS/releases) -- Use the file for February 07, 2024)
    *   In the tests, the initial table will have the following structure:
        ```sql
        CREATE TABLE septa.bus_stops (
            stop_id TEXT,
            stop_code TEXT,
            stop_name TEXT,
            stop_desc TEXT,
            stop_lat DOUBLE PRECISION,
            stop_lon DOUBLE PRECISION,
            zone_id TEXT,
            stop_url TEXT,
            location_type INTEGER,
            parent_station TEXT,
            stop_timezone TEXT,
            wheelchair_boarding INTEGER
        );
        ```
*   `septa.bus_routes` ([SEPTA GTFS](https://github.com/septadev/GTFS/releases))
    *   In the tests, the initial table will have the following structure:
        ```sql
        CREATE TABLE septa.bus_routes (
            route_id TEXT,
            agency_id TEXT,
            route_short_name TEXT,
            route_long_name TEXT,
            route_desc TEXT,
            route_type TEXT,
            route_url TEXT,
            route_color TEXT,
            route_text_color TEXT
        );
        ```
*   `septa.bus_trips` ([SEPTA GTFS](https://github.com/septadev/GTFS/releases))
    *  In the tests, the initial table will have the following structure:
        ```sql
        CREATE TABLE septa.bus_trips (
            route_id TEXT,
            service_id TEXT,
            trip_id TEXT,
            trip_headsign TEXT,
            trip_short_name TEXT,
            direction_id TEXT,
            block_id TEXT,
            shape_id TEXT,
            wheelchair_accessible INTEGER,
            bikes_allowed INTEGER
        );
        ```
*   `septa.bus_shapes` ([SEPTA GTFS](https://github.com/septadev/GTFS/releases))
    *   In the tests, the initial table will have the following structure:
        ```sql
        CREATE TABLE septa.bus_shapes (
            shape_id TEXT,
            shape_pt_lat DOUBLE PRECISION,
            shape_pt_lon DOUBLE PRECISION,
            shape_pt_sequence INTEGER,
            shape_dist_traveled DOUBLE PRECISION
        );
        ```
*   `septa.rail_stops` ([SEPTA GTFS](https://github.com/septadev/GTFS/releases))
    *   In the tests, the initial table will have the following structure:
        ```sql
        CREATE TABLE septa.rail_stops (
            stop_id TEXT,
            stop_name TEXT,
            stop_desc TEXT,
            stop_lat DOUBLE PRECISION,
            stop_lon DOUBLE PRECISION,
            zone_id TEXT,
            stop_url TEXT
        );
        ```
*   `phl.pwd_parcels` ([OpenDataPhilly](https://opendataphilly.org/dataset/pwd-stormwater-billing-parcels))
    *   In the tests, this data will be loaded in with a geography column named `geog`, and all field names will be lowercased. If you use `ogr2ogr` to load the file, I recommend you use the following options:
        ```bash
        ogr2ogr \
            -f "PostgreSQL" \
            PG:"host=localhost port=$PGPORT dbname=$PGNAME user=$PGUSER password=$PGPASS" \
            -nln phl.pwd_parcels \
            -nlt MULTIPOLYGON \
            -t_srs EPSG:4326 \
            -lco GEOMETRY_NAME=geog \
            -lco GEOM_TYPE=GEOGRAPHY \
            -overwrite \
            "${DATA_DIR}/phl_pwd_parcels/PWD_PARCELS.shp"
        ```
        _(remember to replace the variables with the appropriate values, and replace the backslashes (`\`) with backticks (`` ` ``) if you're using PowerShell)_

        **Take note that PWD files use an EPSG:2272 coordinate reference system. To deal with this above I'm using the [`t_srs` option](https://gdal.org/programs/ogr2ogr.html#cmdoption-ogr2ogr-t_srs) which will reproject the data into whatever CRS you specify (in this case, EPSG:4326).**
*   `phl.neighborhoods` ([OpenDataPhilly's GitHub](https://github.com/opendataphilly/open-geo-data/tree/master/philadelphia-neighborhoods))
    * In the tests, this data will be loaded in with a geography column named `geog`, and all field names will be lowercased. If you use `ogr2ogr` to load the file, I recommend you use the following options:
        ```bash
        ogr2ogr \
            -f "PostgreSQL" \
            PG:"host=localhost port=$PGPORT dbname=$PGNAME user=$PGUSER password=$PGPASS" \
            -nln phl.neighborhoods \
            -nlt MULTIPOLYGON \
            -lco GEOMETRY_NAME=geog \
            -lco GEOM_TYPE=GEOGRAPHY \
            -overwrite \
            "${DATA_DIR}/Neighborhoods_Philadelphia.geojson"
        ```
        _(remember to replace the variables with the appropriate values, and replace the backslashes (`\`) with backticks (`` ` ``) if you're using PowerShell)_
*   `census.blockgroups_2020` ([Census TIGER FTP](https://www2.census.gov/geo/tiger/TIGER2020/BG/) -- Each state has it's own file; Use file number `42` for PA)
    *   In the tests, this data will be loaded in with a geography column named `geog`, and all field names will be lowercased. If you use `ogr2ogr` to load the file, I recommend you use the following options:
        ```bash
        ogr2ogr \
            -f "PostgreSQL" \
            PG:"host=localhost port=$PGPORT dbname=$PGNAME user=$PGUSER password=$PGPASS" \
            -nln census.blockgroups_2020 \
            -nlt MULTIPOLYGON \
            -t_srs EPSG:4326 \
            -lco GEOMETRY_NAME=geog \
            -lco GEOM_TYPE=GEOGRAPHY \
            -overwrite \
            "$DATADIR/census_blockgroups_2020/tl_2020_42_bg.shp"
        ```
        _(remember to replace the variables with the appropriate values, and replace the backslashes (`\`) with backticks (`` ` ``) if you're using PowerShell)_

        **Take note that Census TIGER/Line files use an EPSG:4269 coordinate reference system. To deal with this above I'm using the [`t_srs` option](https://gdal.org/programs/ogr2ogr.html#cmdoption-ogr2ogr-t_srs) which will reproject the data into whatever CRS you specify (in this case, EPSG:4326).** Check out [this stack exchange answer](https://gis.stackexchange.com/a/170854/8583) for the difference.
  *   `census.population_2020` ([Census Explorer](https://data.census.gov/table?t=Populations+and+People&g=040XX00US42$1500000&y=2020&d=DEC+Redistricting+Data+(PL+94-171)&tid=DECENNIALPL2020.P1))  
      * In the tests, the initial table will have the following structure:
        ```sql
        CREATE TABLE census.population_2020 (
            geoid TEXT,
            geoname TEXT,
            total INTEGER
        );
        ```
      * Note that the file from the Census Explorer will have more fields than those three. You may have to do some data preprocessing to get the data into the correct format.

        Alternatively you can use the results from the [Census API](https://api.census.gov/data/2020/dec/pl?get=NAME,GEO_ID,P1_001N&for=block%20group:*&in=state:42%20county:*), but you'll still have to transform the JSON that it gives you into a CSV.

## Questions

1.  Which **eight** bus stop have the largest population within 800 meters? As a rough estimation, consider any block group that intersects the buffer as being part of the 800 meter buffer.

```sql
with
septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        '1500000US' || bg.geoid as geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on st_dwithin(stops.geog, bg.geog, 800)
),

septa_bus_stop_surrounding_population as (
    select
        stops.stop_id,
        sum(pop.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid)
    group by stops.stop_id
)

select
    stops.stop_id,
    stops.stop_name,
    pop.estimated_pop_800m
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id)
order by pop.estimated_pop_800m desc
limit 8;
```

**Result:**

| stop_id | stop_name | estimated_pop_800m |
|---|---|---|
| 22272 | Lombard St & 18th St | 57936 |
| 25080 | Rittenhouse Sq & 18th St | 57571 |
| 24284 | Snyder Av & 9th St | 57412 |
| 22273 | Lombard St & 19th St | 57019 |
| 14958 | 19th St & Lombard St | 57019 |
| 3042 | 16th St & Locust St | 56309 |
| 25083 | Locust St & 16th St | 56309 |
| 22241 | South St & 19th St | 55789 |

2.  Which **eight** bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?

    **The queries to #1 & #2 should generate results with a single row, with the following structure:**

    ```sql
    (
        stop_id text, -- The ID of the station
        stop_name text, -- The name of the station
        estimated_pop_800m integer -- The population within 800 meters
    )
    ```

```sql
with
septa_bus_stop_blockgroups as (
    -- Find Philadelphia county block groups within 800 meters for each
    -- bus stop that don't spatially contain stop itself.
    select
        stops.stop_id,
        -- Match format used in population_2020 by prepending.
        '1500000US' || bg.geoid as geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on
            -- Keep block groups whose boundary falls within 800 meters 
            -- of stop.
            st_dwithin(stops.geog::geography, bg.geog::geography, 800)
            -- Exclude block group that stop sits inside.
            and not st_intersects(stops.geog::geography, bg.geog::geography)
    -- Restrict to Philadelphia county block groups only.
    where bg.geoid like '42101%'
),

septa_bus_stop_surrounding_population as (
    -- Sum population of all nearby block groups for each bus stop.
    select
        stops.stop_id,
        sum(pop.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups as stops
    inner join census.population_2020 as pop using (geoid)
    group by stops.stop_id
    -- Keep stops w/ surrounding population beyond 500 people.
    having sum(pop.total) > 500
)

-- Join population estimates back to bus stop details for the final output.
select
    stops.stop_id,
    stops.stop_name,
    pop.estimated_pop_800m
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as stops using (stop_id)
-- Sort ascending so least-served stops first.
order by pop.estimated_pop_800m
-- Return only 8 stops w/ smallest surrounding population.
limit 8;
```

**Result:**

| stop_id | stop_name | estimated_pop_800m |
|---|---|---|
| 30840 | Delaware Av & Tioga St | 583 |
| 31499 | Delaware Av & Castor Av | 583 |
| 31500 | Delaware Av & Venango St | 583 |
| 31752 | Stenton Av & Northwestern Av | 655 |
| 27000 | Bethlehem Pk & Chesney Ln | 655 |
| 27152 | Bethlehem Pk & Chesney Ln | 655 |
| 30839 | Delaware Av & Wheatsheaf Ln | 674 |
| 19604 | Long Ln & Clinton Rd | 729 |

3.  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

    _Your query should run in under two minutes._

    >_**HINT**: This is a [nearest neighbor](https://postgis.net/workshops/postgis-intro/knn.html) problem.

    **Structure:**
    ```sql
    (
        parcel_address text,  -- The address of the parcel
        stop_name text,  -- The name of the bus stop
        distance numeric  -- The distance apart in meters, rounded to two decimals
    )
    ```

```sql
select
    pwd_parcels.address as parcel_address,
    nearest.stop_name,
    nearest.distance
from phl.pwd_parcels
cross join
    lateral (
        -- Run subquery per parcel to find single closest bus stop.
        select
            septa.bus_stops.stop_name,
            -- Calculate actual geodesic distance in meters between parcel and bus stop,
            -- rounded to 2 decimal places.
            round(st_distance(phl.pwd_parcels.geog, septa.bus_stops.geog)::numeric, 2) as distance
        from septa.bus_stops
        -- Use <-> operator to pre-sort bus stops by approximate distance from current parcel
        -- using spatial index.
        order by phl.pwd_parcels.geog <-> septa.bus_stops.geog
        -- Keep only closest bus stop row.
        limit 1
    ) as nearest
-- Sort all parcels from farthest to nearest bus stop.
order by nearest.distance desc;
```

**Result:**

Ascending Version:

| parcel_address | stop_name | distance |
|---|---|---|
| 170 SPRING LN | Ridge Av & Ivins Rd | 1658.70 |
| 150 SPRING LN | Ridge Av & Ivins Rd | 1620.24 |
| 130 SPRING LN | Ridge Av & Ivins Rd | 1610.96 |
| 190 SPRING LN | Ridge Av & Ivins Rd | 1490.01 |
| 630 SAINT ANDREW RD | Germantown Av & Springfield Av | 1418.54 |

Descending Version:

| parcel_address | stop_name | distance |
|---|---|---|
| 7501-03 MALVERN AVE | 75th St & Malvern Av | 0.00 |
| 1500 S 32ND ST | Dickinson St & 32nd St | 0.00 |
| 4900 RHAWN ST | Rhawn St & Tulip St | 0.00 |
| 1901 E SOMERSET ST | Somerset St & Jasper St | 0.00 |
| 5250 WAYNE AVE | Queen Ln & Wayne Av - detour | 0.00 |

4.  Using the `bus_shapes`, `bus_routes`, and `bus_trips` tables from GTFS bus feed, find the **two** routes with the longest trips.

    _Your query should run in under two minutes._

    >_**HINT**: The `ST_MakeLine` function is useful here. You can see an example of how you could use it at [this MobilityData walkthrough](https://docs.mobilitydb.com/MobilityDB-workshop/master/ch04.html#:~:text=INSERT%20INTO%20shape_geoms) on using GTFS data. If you find other good examples, please share them in Slack._

    >_**HINT**: Use the query planner (`EXPLAIN`) to see if there might be opportunities to speed up your query with indexes. For reference, I got this query to run in about 15 seconds._

    >_**HINT**: The `row_number` window function could also be useful here. You can read more about window functions [in the PostgreSQL documentation](https://www.postgresql.org/docs/9.1/tutorial-window.html). That documentation page uses the `rank` function, which is very similar to `row_number`. For more info about window functions you can check out:_
    >*   📑 [_An Easy Guide to Advanced SQL Window Functions_](https://medium.com/data-science/a-guide-to-advanced-sql-window-functions-f63f2642cbf9) in Towards Data Science, by Julia Kho
    >*   🎥 [_SQL Window Functions for Data Scientists_](https://www.youtube.com/watch?v=e-EL-6Vnkbg) (and a [follow up](https://www.youtube.com/watch?v=W_NBnkLLh7M) with examples) on YouTube, by Emma Ding
    >*   📖 Chapter 16: Analytic Functions in Learning SQL, 3rd Edition for a deep dive (see the [books](https://github.com/Weitzman-MUSA-GeoCloud/course-info/tree/main/week01#books) listed in week 1, which you can access on [O'Reilly for Higher Education](http://pwp.library.upenn.edu.proxy.library.upenn.edu/loggedin/pwp/pw-oreilly.html))
    

    **Structure:**
    ```sql
    (
        route_short_name text,  -- The short name of the route
        trip_headsign text,  -- Headsign of the trip
        shape_length numeric  -- Length of the trip in meters, rounded to the nearest meter
    )
    ```

```sql
-- Reconstruct each bus route shape as single line geometry,
-- then measure meters length.
with shape_lengths as (
    select
        shape_id,
        round(
            st_length(
                -- Build line from shape points, ordered by sequence
                -- for right path direction.
                st_makeline(
                    st_setsrid(st_makepoint(shape_pt_lon, shape_pt_lat), 4326)
                    order by shape_pt_sequence
                -- Cast to geography to get meters distance.
                )::geography
            )
        ) as shape_length
    from septa.bus_shapes
    -- Aggregate all points belonging to same shape into one line.
    group by shape_id
),

unique_trips as (
    -- 1 shape to 1 trip and route before ranking to prevent duplicates.
    select distinct on (shape.shape_id)
        shape.shape_id,
        shape.shape_length,
        trip.trip_headsign,
        route.route_short_name
    from shape_lengths as shape
    inner join septa.bus_trips as trip on shape.shape_id = trip.shape_id
    inner join septa.bus_routes as route on trip.route_id = route.route_id
    order by shape.shape_id
),

trip_info as (
    -- Rank unique shapes from longest to shortest.
    select
        route_short_name,
        trip_headsign,
        shape_length,
        row_number() over (order by shape_length desc) as rownumber
    from unique_trips
)

-- Return two trips w/ biggest shape length.
select
    route_short_name,
    trip_headsign,
    shape_length
from trip_info
where rownumber <= 2;
```

**Result:**

| route_short_name | trip_headsign | shape_length |
|---|---|---|
| 130 | Bucks County Community College | 46505 |
| 128 | Oxford Valley Mall | 43659 |

AI used to help with query. Free model Claude Haiku 4.5.

Prompt: """Don't give me answer. I'm having duplication issues and
a single-row issue when I use distinct. Is there something
wrong in my logic or conceptual understanding of how I'm
tackling this question?

Original, no distinct clause:
"130"    "Bucks County Community College"    46505
"130"    "Bucks County Community College"    46505

Distinct clause added:
"130"    "Bucks County Community College"    46505

Expected:
route_short_name,trip_headsign,shape_length
"130","Bucks County Community College",46684
"128","Oxford Valley Mall",44044
"""

(Resolved by creating unique trips w/ distinct on shape_id
before ranking to prevent duplicates.)

5.  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.

    _NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case._

    Discuss your accessibility metric and how you arrived at it below:

    **Description:** For each neighborhood, the query finds all wheelchair-accessible
  bus stops where wheelchair_boarding = 1, then counts the total number of
  pedestrian ramps within 150 meters of any of those stops based on rough
  average block measurements in Google Maps. Neighborhoods with more nearby
  ramps near accessible stops are considered more accessible. This has its
  limitations as it doesn't account for the quality of the ramps, the side of
  the street the ramps are on,or the actual routes of the bus stops, but it
  provides a starting point for assessing accessibility based on proximity
  to pedestrian infrastructure.

  [DVRPC Data Page Link](https://catalog.dvrpc.org/dataset/dvrpc-pedestrian-ramps)
  [GeoJSON Direct Link](https://arcgis.dvrpc.org/portal/rest/services/transportation/pedestriannetwork_points/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson)

```sql
with
accessible_stops as (
    select
        stop_id,
        stop_name,
        geog
    from septa.bus_stops
    -- Filter wheelchair-accessible bus stops.
    where wheelchair_boarding = 1
),

stops_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        accessible_stops.stop_id,
        accessible_stops.geog as stop_geog
    from phl.neighborhoods as neighborhoods
    -- Join accessible stops to neighborhoods.
    inner join accessible_stops
        on st_within(
            accessible_stops.geog::geometry,
            neighborhoods.geog::geometry
        )
),

ramps_near_stops as (
    select
        stops_in_neighborhoods.neighborhood_name,
        stops_in_neighborhoods.stop_id,
        count(ramps.ogc_fid) as nearby_ramp_count
    from stops_in_neighborhoods
    left join phl.pedestrian_ramps as ramps
        -- Count pedestrian ramps within 150m of accessible stops.
        on st_dwithin(
            stops_in_neighborhoods.stop_geog::geography,
            ramps.geog::geography,
            150
        )
    group by
        stops_in_neighborhoods.neighborhood_name,
        stops_in_neighborhoods.stop_id
)

-- Aggregate counts per neighborhood for total accessible stops
-- and nearby ramps as accessibility metric.
select
    neighborhood_name,
    count(stop_id) as total_accessible_stops,
    sum(nearby_ramp_count) as total_nearby_ramps
from ramps_near_stops
group by neighborhood_name
order by total_nearby_ramps desc, total_accessible_stops desc;
```

6.  What are the _top five_ neighborhoods according to your accessibility metric?

```sql
with
accessible_stops as (
    select
        stop_id,
        geog
    from septa.bus_stops
    -- Filter wheelchair-accessible bus stops.
    where wheelchair_boarding = 1
),

inaccessible_stops as (
    select
        stop_id,
        geog
    from septa.bus_stops
    -- Filter wheelchair-inaccessible bus stops.
    where wheelchair_boarding != 1
),

accessible_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        accessible_stops.stop_id,
        accessible_stops.geog as stop_geog
    from phl.neighborhoods as neighborhoods
    -- Join accessible stops to neighborhoods.
    inner join accessible_stops
        on st_within(
            accessible_stops.geog::geometry,
            neighborhoods.geog::geometry
        )
),

inaccessible_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        inaccessible_stops.stop_id
    from phl.neighborhoods as neighborhoods
    -- Join inaccessible stops to neighborhoods.
    inner join inaccessible_stops
        on st_within(
            inaccessible_stops.geog::geometry,
            neighborhoods.geog::geometry
        )
),

ramps_near_stops as (
    select
        accessible_in_neighborhoods.neighborhood_name,
        accessible_in_neighborhoods.stop_id,
        count(ramps.ogc_fid) as nearby_ramp_count
    from accessible_in_neighborhoods
    left join phl.pedestrian_ramps as ramps
        -- Count pedestrian ramps within 150m of accessible stops.
        on st_dwithin(
            accessible_in_neighborhoods.stop_geog::geography,
            ramps.geog::geography,
            150
        )
    group by
        accessible_in_neighborhoods.neighborhood_name,
        accessible_in_neighborhoods.stop_id
),

-- Aggregate accessible stops and ramps per neighborhood.
-- accessibility_metric is sum of nearby ramps across all stops.
accessible_summary as (
    select
        neighborhood_name,
        count(stop_id) as num_bus_stops_accessible,
        sum(nearby_ramp_count) as accessibility_metric
    from ramps_near_stops
    group by neighborhood_name
),

-- Aggregate inaccessible stops and ramps per neighborhood.
-- inaccessibility_metric is sum of nearby ramps across all stops.
inaccessible_summary as (
    select
        neighborhood_name,
        count(stop_id) as num_bus_stops_inaccessible
    from inaccessible_in_neighborhoods
    group by neighborhood_name
)

select
    accessible_summary.neighborhood_name,
    accessible_summary.accessibility_metric,
    accessible_summary.num_bus_stops_accessible,
    coalesce(
        inaccessible_summary.num_bus_stops_inaccessible, 0
    ) as num_bus_stops_inaccessible
from accessible_summary
-- Join summaries and return top 5 accessible, ordered by accessibility_metric
-- desc, then by accessible stops desc.
left join inaccessible_summary
    on
        accessible_summary.neighborhood_name
        = inaccessible_summary.neighborhood_name
order by
    accessible_summary.accessibility_metric desc,
    accessible_summary.num_bus_stops_accessible desc
limit 5;
```

**Result:**

| neighborhood_name | accessibility_metric | num_bus_stops_accessible | num_bus_stops_inaccessible |
|---|---|---|---|
| OVERBROOK | 2 | 176 | 23 |
| EAST_OAK_LANE | 2 | 97 | 0 |
| BURHOLME | 1 | 22 | 0 |
| MELROSE_PARK_GARDENS | 1 | 16 | 0 |
| OLNEY | 0 | 172 | 0 |

AI used to help with query. Free model Claude Haiku 4.5.

Prompt: Don't give me answer. I'm getting null values showing up despite ordering them, is there a way to replace with 0? I want to make sure all stops show up.

(Resolved by using coalesce to replace null with 0 for num_bus_stops_inaccessible.)

7.  What are the _bottom five_ neighborhoods according to your accessibility metric?

    **Both #6 and #7 should have the structure:**
    ```sql
    (
      neighborhood_name text,  -- The name of the neighborhood
      accessibility_metric ...,  -- Your accessibility metric value
      num_bus_stops_accessible integer,
      num_bus_stops_inaccessible integer
    )
    ```

```sql
with
accessible_stops as (
    select
        stop_id,
        geog
    from septa.bus_stops
    -- Filter wheelchair-accessible bus stops.
    where wheelchair_boarding = 1
),

inaccessible_stops as (
    select
        stop_id,
        geog
    from septa.bus_stops
    -- Filter wheelchair-inaccessible bus stops.
    where wheelchair_boarding != 1
),

accessible_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        accessible_stops.stop_id,
        accessible_stops.geog as stop_geog
    from phl.neighborhoods as neighborhoods
    -- Join accessible stops to neighborhoods.
    inner join accessible_stops
        on st_within(
            accessible_stops.geog::geometry,
            neighborhoods.geog::geometry
        )
),

inaccessible_in_neighborhoods as (
    select
        neighborhoods.name as neighborhood_name,
        inaccessible_stops.stop_id
    from phl.neighborhoods as neighborhoods
    -- Join inaccessible stops to neighborhoods.
    inner join inaccessible_stops
        on st_within(
            inaccessible_stops.geog::geometry,
            neighborhoods.geog::geometry
        )
),

ramps_near_stops as (
    select
        accessible_in_neighborhoods.neighborhood_name,
        accessible_in_neighborhoods.stop_id,
        count(ramps.ogc_fid) as nearby_ramp_count
    from accessible_in_neighborhoods
    left join phl.pedestrian_ramps as ramps
        -- Count pedestrian ramps within 150m of accessible stops.
        on st_dwithin(
            accessible_in_neighborhoods.stop_geog::geography,
            ramps.geog::geography,
            150
        )
    group by
        accessible_in_neighborhoods.neighborhood_name,
        accessible_in_neighborhoods.stop_id
),

-- Aggregate accessible stops and ramps per neighborhood.
-- accessibility_metric is sum of nearby ramps across all stops.
accessible_summary as (
    select
        neighborhood_name,
        count(stop_id) as num_bus_stops_accessible,
        sum(nearby_ramp_count) as accessibility_metric
    from ramps_near_stops
    group by neighborhood_name
),

-- Aggregate inaccessible stops and ramps per neighborhood.
-- inaccessibility_metric is sum of nearby ramps across all stops.
inaccessible_summary as (
    select
        neighborhood_name,
        count(stop_id) as num_bus_stops_inaccessible
    from inaccessible_in_neighborhoods
    group by neighborhood_name
)

select
    accessible_summary.neighborhood_name,
    accessible_summary.accessibility_metric,
    accessible_summary.num_bus_stops_accessible,
    coalesce(
        inaccessible_summary.num_bus_stops_inaccessible, 0
    ) as num_bus_stops_inaccessible
from accessible_summary
-- Join summaries and return top 5 accessible, ordered by accessibility_metric
-- desc, then by accessible stops desc.
left join inaccessible_summary
    on
        accessible_summary.neighborhood_name
        = inaccessible_summary.neighborhood_name
order by
    accessible_summary.accessibility_metric,
    accessible_summary.num_bus_stops_accessible
limit 5;
```

**Result:**

| neighborhood_name | accessibility_metric | num_bus_stops_accessible | num_bus_stops_inaccessible |
|---|---|---|---|
| CRESTMONT_FARMS | 0 | 1 | 0 |
| WEST_TORRESDALE | 0 | 1 | 0 |
| WOODLAND_TERRACE | 0 | 2 | 8 |
| CHINATOWN | 0 | 4 | 0 |
| WISSAHICKON_HILLS | 0 | 4 | 0 |

8.  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

    **Structure (should be a single value):**
    ```sql
    (
        count_block_groups integer
    )
    ```

    **Discussion:** I chose to use the PWD parcels dataset to define Penn's main
  campus and filtered the parcels to include only those owned by entities
  that are likely associated with Penn, such as "TRS UNIV OF PENN", "TRUSTEES",
  "UNIVERSITY", and "U OF P" when I was looking at their interactive map. I
  also excluded parcels that are likely associated with other universities,
  such as "DREXEL" and "TEMPLE". By using the st_contains function, I was
  able to determine which census block groups are fully contained within the
  geographic boundaries of the selected parcels.

```sql
select count(bg.geoid) as count_block_groups
from
    census.blockgroups_2020 as bg
-- Join parcels to block groups where parcel geometry falls within block group.
inner join
    phl.pwd_parcels as parcels
    on st_contains(
        bg.geog::geometry,
        parcels.geog::geometry
    )
-- Filter to parcels where owner name matches UPenn ownership variations.
where (
    parcels.owner1 like 'TRS UNIV OF PENN'
    or parcels.owner1 like 'TRUSTEES'
    or parcels.owner1 like 'UNIVERSITY'
    or parcels.owner1 like 'U OF P'
)
-- Exclude other university parcels.
and parcels.owner1 not like 'DREXEL'
and parcels.owner1 not like 'TEMPLE'
```

**Result:**

| count_block_groups |
|---|
| 99 |

9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed.

    **Structure (should be a single value):**
    ```sql
    (
        geo_id text
    )
    ```

```sql
select bg.geoid as geo_id
from
    census.blockgroups_2020 as bg
-- Join parcels to block groups where parcel is within block group.
inner join
    phl.pwd_parcels as parcels
    on st_contains(
        bg.geog::geometry,
        parcels.geog::geometry
    )
where
    -- Address for Meyerson Hall for filtering as typed in parcel data.
    parcels.address like '220-30 S 34TH ST';
```

**Result:**

| geo_id |
|---|
| 421010369022 |

10. You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's `CASE` statements may be helpful for some operations.

    **Structure:**
    ```sql
    (
        stop_id integer,
        stop_name text,
        stop_desc text,
        stop_lon double precision,
        stop_lat double precision
    )
    ```

   As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)

   >**Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, use `FROM (SELECT * FROM tablename limit 10) as t`.

```sql
with liberty_bell as (
    -- Liberty Bell coordinates as ref point.
    select st_setsrid(
        st_makepoint(-75.15031592068193, 39.949548328739006),
        4326
    )::geography as geog
),

rail_stops_with_geom as (
    select
        rail_stops.stop_id,
        rail_stops.stop_name,
        rail_stops.stop_lat,
        rail_stops.stop_lon,
        -- Rail stop coordinates to geography for distance.
        st_setsrid(
            st_makepoint(rail_stops.stop_lon, rail_stops.stop_lat),
            4326
        )::geography as stop_geog
    from septa.rail_stops
),

distance_to_liberty_bell as (
    -- Calculate distance from rail stops to Liberty Bell.
    select
        rail_geom.stop_id,
        round(
            st_distance(rail_geom.stop_geog, bell.geog)::numeric,
            0
        ) as distance_meters
    from rail_stops_with_geom as rail_geom
    cross join liberty_bell as bell
),

containing_neighborhood as (
    -- Find which neighborhood contains rail stop.
    select
        rail_geom.stop_id,
        neighborhoods.name as neighborhood_name
    from rail_stops_with_geom as rail_geom
    left join phl.neighborhoods
        on st_within(
            rail_geom.stop_geog::geometry,
            st_setsrid(neighborhoods.geog::geometry, 4326)
        )
)

-- Combine Liberty Bell distance and neighborhood into description,
-- and reorder columns according to assignment.
select
    final.stop_id,
    final.stop_name,
    final.stop_desc,
    final.stop_lon,
    final.stop_lat
from (
    select
        rail_geom.stop_id,
        rail_geom.stop_name,
        rail_geom.stop_lon,
        rail_geom.stop_lat,
        concat(
            distance_to_liberty_bell.distance_meters::text,
            'm from LETTING THAT FREEDOM RING! 🔔🦅 #',
            upper(coalesce(containing_neighborhood.neighborhood_name, 'Philadelphia'))
        ) as stop_desc
    from rail_stops_with_geom as rail_geom
    left join distance_to_liberty_bell on rail_geom.stop_id = distance_to_liberty_bell.stop_id
    left join containing_neighborhood on rail_geom.stop_id = containing_neighborhood.stop_id
) as final
order by final.stop_id;
```

**Result:**

| stop_id | stop_name | stop_desc | stop_lon | stop_lat |
|---|---|---|---|---|
| 90001 | Cynwyd | 9408m from LETTING FREEDOM RING! 🔔🦅 #PHILADELPHIA  | -75.2316667 | 40.0066667 |
| 90002 | Bala | 8750m from LETTING FREEDOM RING! 🔔🦅 #PHILADELPHIA  | -75.2277778 | 40.0011111 |
| 90003 | Wynnefield Avenue | 7842m from LETTING FREEDOM RING! 🔔🦅 #WYNNEFIELD  | -75.2255556 | 39.99 |
| 90004 | Gray 30th Street | 2793m from LETTING FREEDOM RING! 🔔🦅 #UNIVERSITY_CITY  | -75.1816667 | 39.9566667 |
| 90005 | Suburban Station | 1568m from LETTING FREEDOM RING! 🔔🦅 #LOGAN_SQUARE  | -75.1677778 | 39.9538889 |

AI used to help with query. Free model Claude Haiku 4.5.

Prompt: Don't give me answer. Having trouble with upper function where
"function upper(record) does not exist", what's the issue behind
that error? On that note is there a function to reorder columns in
the final table?

(Resolved by using coalesce to handle null neighborhood names, and by
selecting columns in desired order in final select statement.)
