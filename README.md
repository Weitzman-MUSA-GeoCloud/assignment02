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
        select
            stops.stop_id,
            '1500000US' || bg.geoid as geoid
        from septa.bus_stops as stops
        inner join census.blockgroups_2020 as bg
            on
                st_dwithin(stops.geog, bg.geog, 800)
                and bg.countyfp = '101'
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
    where pop.estimated_pop_800m > 500
    order by pop.estimated_pop_800m asc
    limit 8;
    ```

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
        knn.stop_name,
        ROUND(knn.distance::NUMERIC, 2) as distance
    from phl.pwd_parcels
    cross join
        lateral (
            select
                bs.stop_name,
                pwd_parcels.geog <-> bs.geog as distance
            from septa.bus_stops as bs
            order by distance asc
            limit 1
        ) as knn
    order by distance desc;
    ```

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
    with route_lengths as (
        select
            shape_id,
            st_length(
                st_makeline(
                    array_agg(
                        st_setsrid(
                            st_makepoint(shape_pt_lon, shape_pt_lat), 4326
                        )
                        order by shape_pt_sequence
                    )
                )::geography
            ) as shape_length
        from septa.bus_shapes
        group by shape_id
    ),

    longest_routes as (
        select distinct on (rtes.route_id)
            rtes.route_id as route_short_name,
            trps.trip_headsign,
            rtln.shape_length
        from septa.bus_routes as rtes
        inner join septa.bus_trips as trps on rtes.route_id = trps.route_id
        inner join route_lengths as rtln on trps.shape_id = rtln.shape_id
        order by
            rtes.route_id asc,
            rtln.shape_length desc
    )

    select *
    from longest_routes
    order by shape_length desc;
    ```

5.  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.

    _NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case._

    Discuss your accessibility metric and how you arrived at it below:

    ```sql
    with bus_nbhds as (
        select
            stps.stop_id,
            stps.stop_name,
            stps.wheelchair_boarding,
            nbhd.listname
        from septa.bus_stops as stps
        inner join phl.neighborhoods as nbhd
            on
                st_dwithin(stps.geog, nbhd.geog, 50)
    )

    select
        listname as neighborhood_name_text,
        round(
            (
                (
                    count(*) filter (where wheelchair_boarding = 1)
                    - avg(count(*) filter (where wheelchair_boarding = 1)) over ()
                )::FLOAT
                / nullif(
                    stddev_pop(count(*) filter (where wheelchair_boarding = 1)) over (),
                    0
                )
            )::NUMERIC,
            2
        ) as accessibility_metric,
        count(*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
        count(*) filter (where wheelchair_boarding = 2 or wheelchair_boarding = 0) as num_bus_stops_inaccessible
    from bus_nbhds
    group by listname
    order by accessibility_metric desc;
    ```

    **Description:** Within the bus_stops file is a field for whether or not a stop is wheelchair accessible. This has three values: 0 = no data available, 1 = wheelchair accessible, 2 = not wheelchair accessible. This metric is based on the count of wheelchair accessible bus stops within a neighborhood with this value converted to a z-score (number of std. deviations from the mean count of 70 stations) across all neighborhoods. Values for this metric are negative if the neighborhood has less accessible stops than the mean.

6.  What are the _top five_ neighborhoods according to your accessibility metric?

    ```sql
    with bus_nbhds as (
        select
            stps.stop_id,
            stps.stop_name,
            stps.wheelchair_boarding,
            nbhd.listname
        from septa.bus_stops as stps
        inner join phl.neighborhoods as nbhd
            on
                st_dwithin(stps.geog, nbhd.geog, 50)
    )

    select
        listname as neighborhood_name_text,
        round(
            (
                (
                    count(*) filter (where wheelchair_boarding = 1)
                    - avg(count(*) filter (where wheelchair_boarding = 1)) over ()
                )::FLOAT
                / nullif(
                    stddev_pop(count(*) filter (where wheelchair_boarding = 1)) over (),
                    0
                )
            )::NUMERIC,
            2
        ) as accessibility_metric,
        count(*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
        count(*) filter (where wheelchair_boarding = 2 or wheelchair_boarding = 0) as num_bus_stops_inaccessible
    from bus_nbhds
    group by listname
    order by accessibility_metric desc
    limit 5;
    ```

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
    with bus_nbhds as (
    select
        stps.stop_id,
        stps.stop_name,
        stps.wheelchair_boarding,
        nbhd.listname
    from septa.bus_stops as stps
    inner join phl.neighborhoods as nbhd
        on
            st_dwithin(stps.geog, nbhd.geog, 50)
    )
    select
        listname as neighborhood_name_text,
        round(
            (
                (
                    count(*) filter (where wheelchair_boarding = 1)
                    - avg(count(*) filter (where wheelchair_boarding = 1)) over ()
                )::FLOAT
                / nullif(
                    stddev_pop(count(*) filter (where wheelchair_boarding = 1)) over (),
                    0
                )
            )::NUMERIC,
            2
        ) as accessibility_metric,
        count(*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
        count(*) filter (where wheelchair_boarding = 2 or wheelchair_boarding = 0) as num_bus_stops_inaccessible
    from bus_nbhds
    group by listname
    order by accessibility_metric asc
    limit 5;
    ```

8.  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

    **Structure (should be a single value):**
    ```sql
    (
        count_block_groups integer
    )
    ```
    ```sql
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
    ```

    **Discussion:** Despite the neighborhood of University City encompassing more than just Penn's campus (parts of Drexel), the block groups that overlap with Penn's campus also encompass some of Drexel. I therefore chose to select the University City neighborhood from Philadelphia's neighborhoods dataset.

9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed.

    **Structure (should be a single value):**
    ```sql
    (
        geo_id text
    )
    ```
    ```sql
    with
    meyerson as (
        select *
        from phl.pwd_parcels
        where address = '220-30 S 34TH ST'
    )

    select block_grps.geoid
    from census.blockgroups_2020 as block_grps
    inner join meyerson
        on st_intersects(block_grps.geog, meyerson.geog);
    ```

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

    ```sql
    create or replace function ST_CARDINALDIRECTION(azimuth float8) returns character varying as
    $BODY$SELECT CASE
    WHEN $1 < 0.0 THEN 'less than 0'
    WHEN degrees($1) < 22.5 THEN 'N'
    WHEN degrees($1) < 67.5 THEN 'NE'
    WHEN degrees($1) < 112.5 THEN 'E'
    WHEN degrees($1) < 157.5 THEN 'SE'
    WHEN degrees($1) < 202.5 THEN 'S'
    WHEN degrees($1) < 247.5 THEN 'SW'
    WHEN degrees($1) < 292.5 THEN 'W'
    WHEN degrees($1) < 337.5 THEN 'NW'
    WHEN degrees($1) <= 360.0 THEN 'N'
    END;$BODY$ language sql immutable cost 100;
    comment on function ST_CARDINALDIRECTION(float8) is 'input azimuth in radians; returns N, NW, W, SW, S, SE, E, or NE';

    with info as (
        select
            stops.stop_id,
            stops.stop_name,
            stops.stop_lon,
            stops.stop_lat,
            nbhds.listname as neighborhood,
            TO_CHAR(ROUND(knn.distance::numeric, 2)::real, '9D99') || ' meters ' as distance,
            ST_CARDINALDIRECTION(ST_AZIMUTH(ST_CENTROID(knn.parcel_geog), stops.geog)) as direction,
            INITCAP(knn.parcel_address) as parcel_address
        from septa.bus_stops as stops
        inner join phl.neighborhoods as nbhds
            on ST_INTERSECTS(stops.geog, nbhds.geog)
        cross join
            lateral (
                select
                    parcels.geog as parcel_geog,
                    parcels.address as parcel_address,
                    parcels.geog <-> stops.geog as distance
                from phl.pwd_parcels as parcels
                order by distance asc
                limit 1
            ) as knn
    )

    select
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        'In ' || neighborhood || ',' || distance || direction || ' of ' || parcel_address as stop_desc
    from info;
    ```
    As an example, your `stop_desc` for a station stop may be something like "37 meters NE of 1234 Market St" (that's only an example, feel free to be creative, silly, descriptive, etc.)

   >**Tip when experimenting:** Use subqueries to limit your query to just a few rows to keep query times faster. Once your query is giving you answers you want, scale it up. E.g., instead of `FROM tablename`, use `FROM (SELECT * FROM tablename limit 10) as t`.