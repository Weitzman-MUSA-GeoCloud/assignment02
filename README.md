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
"22272"	"Lombard St & 18th St"	57936
"25080"	"Rittenhouse Sq & 18th St "	57571
"24284"	"Snyder Av & 9th St "	57412
"22273"	"Lombard St & 19th St"	57019
"14958"	"19th St & Lombard St "	57019
"3042"	"16th St & Locust St "	56309
"25083"	"Locust St & 16th St "	56309
"22241"	"South St & 19th St"	55789

2.  Which **eight** bus stops have the smallest population above 500 people _inside of Philadelphia_ within 800 meters of the stop (Philadelphia county block groups have a geoid prefix of `42101` -- that's `42` for the state of PA, and `101` for Philadelphia county)?

    **The queries to #1 & #2 should generate results with a single row, with the following structure:**

    ```sql
    (
        stop_id text, -- The ID of the station
        stop_name text, -- The name of the station
        estimated_pop_800m integer -- The population within 800 meters
    )
    ```
"31500"	"Delaware Av & Venango St"	593
"30840"	"Delaware Av & Tioga St"	593
"31499"	"Delaware Av & Castor Av"	593
"31788"	"Northwestern Av & Stenton Av"	655
"31752"	"Stenton Av & Northwestern Av"	655
"27000"	"Bethlehem Pk & Chesney Ln"	655
"27152"	"Bethlehem Pk & Chesney Ln"	655
"30839"	"Delaware Av & Wheatsheaf Ln"	684

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
"170 SPRING LN"	"Ridge Av & Ivins Rd"	1658.82
"150 SPRING LN"	"Ridge Av & Ivins Rd"	1620.32
"130 SPRING LN"	"Ridge Av & Ivins Rd"	1611.02
"190 SPRING LN"	"Ridge Av & Ivins Rd"	1490.10
"630 SAINT ANDREW RD"	"Germantown Av & Springfield Av "	1418.42
"700 SAINT ANDREW RD"	"Wissahickon Av & Cathedral Rd - FS"	1415.18
"626 SAINT ANDREW RD"	"Germantown Av & Springfield Av "	1393.54
"706 SAINT ANDREW RD"	"Henry Av & Domino La - MBNS"	1373.15
"615 W HARTWELL LN"	"Germantown Av & Springfield Av "	1371.17
"107 SPRING LN"	"Ridge Av & Cathedral Rd - FS"	1365.64
"7940 CHEROKEE ST"	"Germantown Av & Moreland Av "	1365.63
"27 RIVER RD"	"Oak Hill Apartments Loop"	1359.83
"613 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1353.20
"624 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1335.39
"24 RIVER RD"	"Oak Hill Apartments Loop"	1332.36
"712 SAINT ANDREW RD"	"Henry Av & Domino La - MBNS"	1330.98
"1 MUSTIN ST"	"Front St & Pattison Av"	1328.30
"701 SAINT ANDREW RD"	"Wissahickon Av & Cathedral Rd - FS"	1326.69
"25 RIVER RD"	"Oak Hill Apartments Loop"	1325.74
"615 SAINT ANDREW RD"	"Wissahickon Av & Cathedral Rd - FS"	1324.00
"618 W HARTWELL LN"	"Germantown Av & Springfield Av "	1322.91
"24 RIVER RD"	"Oak Hill Apartments Loop"	1318.81
"119 SPRING LN"	"Ridge Av & Cathedral Rd - FS"	1318.26
"711 SAINT ANDREW RD"	"Wissahickon Av & Cathedral Rd - FS"	1313.46
"715 SAINT ANDREW RD"	"Wissahickon Av & Cathedral Rd - FS"	1307.34
"8520 HAGYS MILL RD"	"Ridge Av & Ivins Rd"	1305.45
"7824 MORELAND CIR"	"Mt Pleasant Av & Cherokee St "	1305.24
"23 RIVER RD"	"Oak Hill Apartments Loop"	1304.13
"8482 HAGYS MILL RD"	"Ridge Av & Cathedral Rd - FS"	1301.68
"705 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1294.69
"718 SAINT ANDREW RD"	"Henry Av & Domino La - MBNS"	1293.48
"8522 HAGYS MILL RD"	"Ridge Av & Ivins Rd"	1292.62
"612 W HARTWELL LN"	"Germantown Av & Springfield Av "	1290.83
"22 RIVER RD"	"Oak Hill Apartments Loop"	1284.21
"618 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1280.51
"21 RIVER RD"	"Oak Hill Apartments Loop"	1274.90
"546 W SPRINGFIELD AVE"	"Germantown Av & Roumfort Rd"	1272.22
"700 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1265.23
"611 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1261.34
"543 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1256.13
"8524 HAGYS MILL RD"	"Ridge Av & Ivins Rd"	1251.46
"544 W SPRINGFIELD AVE"	"Germantown Av & Roumfort Rd"	1249.95
"614 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1248.81
"717 SAINT ANDREW RD"	"Henry Av & Domino La - MBNS"	1247.40
"7800 MORELAND CIR"	"Mt Pleasant Av & Cherokee St "	1247.12
"724 SAINT ANDREW RD"	"Henry Av & Domino La - MBNS"	1246.30
"21 RIVER RD"	"Oak Hill Apartments Loop"	1244.05
"710 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1238.12
"601 W GRAVERS LN"	"Germantown Av & Highland Av "	1235.17
"550 W WILLOW GROVE AVE"	"Germantown Av & Moreland Av "	1232.10
"608 W HARTWELL LN"	"Germantown Av & Springfield Av "	1232.06
"718 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1232.02
"714 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1230.43
"716 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1229.75
"541 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1227.53
"20 RIVER RD"	"Oak Hill Apartments Loop"	1227.39
"605 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	1227.25
"100 SPRING LN"	"Ridge Av & Ivins Rd"	1223.25
"540 W SPRINGFIELD AVE"	"Germantown Av & Roumfort Rd"	1222.37
"610 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1218.05
"597 W GRAVERS LN"	"Germantown Av & Highland Av "	1215.49
"542 W MORELAND AVE"	"Mt Pleasant Av & Cherokee St "	1214.89
"7713 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1211.92
"18 RIVER RD"	"Oak Hill Apartments Loop"	1211.09
"8011 CHEROKEE ST"	"Germantown Av & Springfield Av "	1204.72
"720 GLENGARRY RD"	"Henry Av & Wigard Av"	1203.44
"539 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1201.63
"7714 MORELAND CIR"	"Mt Pleasant Av & Cherokee St "	1200.34
"7710 MORELAND CIR"	"Mt Pleasant Av & Cherokee St "	1200.22
"703 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1199.65
"8524 HAGYS MILL RD"	"Ridge Av & Ivins Rd"	1199.31
"7920 CHEROKEE ST"	"Henry Av & Cinnaminson St"	1195.71
"609 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1192.77
"17 RIVER RD"	"Oak Hill Apartments Loop"	1191.35
"609 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	1189.34
"606 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1186.52
"7900 CHEROKEE ST"	"Henry Av & Cinnaminson St"	1182.71
"532 W SPRINGFIELD AVE"	"Germantown Av & Roumfort Rd"	1178.39
"709 DAVIDSON RD"	"Mt Pleasant Av & McCallum St "	1178.38
"527 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1177.32
"730 SAINT ANDREW RD"	"Henry Av & Domino La - MBNS"	1174.55
"540 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1172.61
"16 1/2 RIVER RD"	"Oak Hill Apartments Loop"	1170.81
"1 DRUIM MOIR CT"	"Henry Av & Domino La - MBNS"	1170.54
"7710 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1169.73
"604 W HARTWELL LN"	"Germantown Av & Springfield Av "	1166.29
"7709 CHEROKEE ST"	"Germantown Av & Roumfort Rd"	1165.66
"4925R FORT MIFFLIN RD"	"26th St & Tastykake - 1"	1162.18
"611 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	1161.56
"809 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1157.55
"16 RIVER RD"	"Oak Hill Apartments Loop"	1155.87
"732 SAINT ANDREW RD"	"Henry Av & Domino La - MBNS"	1155.45
"525 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1152.40
"713 DAVIDSON RD"	"Henry Av & Cinnaminson St"	1152.16
"604 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1152.14
"603 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	1149.13
"50 MUSTIN ST"	"Front St & Pattison Av"	1147.25
"7705 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1147.07
"8520R HAGYS MILL RD"	"Ridge Av & Ivins Rd"	1146.93
"711-13 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1144.68
"14 RIVER RD"	"Oak Hill Apartments Loop"	1142.01
"5 DRUIM MOIR CT"	"Henry Av & Domino La - MBNS"	1141.44
"721 GLENGARRY RD"	"Henry Av & Wigard Av"	1138.03
"536 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1137.88
"124 S PIER"	"Front St & Pattison Av"	1135.03
"603 W HARTWELL LN"	"Germantown Av & Springfield Av "	1133.03
	"Ridge Av & Ivins Rd"	1132.58
"7700 MCCALLUM ST"	"Henry Av & Cinnaminson St"	1132.46
"301 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	1131.76
"545 W MERMAID LN"	"Mt Pleasant Av & Cherokee St "	1129.80
"3 DRUIM MOIR CT"	"Henry Av & Domino La - MBNS"	1128.11
"717 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1128.03
"715 W MERMAID LN"	"Mt Pleasant Av & Cherokee St "	1127.32
"705 W MERMAID LN"	"Mt Pleasant Av & Cherokee St "	1126.05
"7701 MCCALLUM ST"	"Mt Pleasant Av & McCallum St "	1126.04
"7700 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1125.87
"7701 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1125.55
"13 RIVER RD"	"Oak Hill Apartments Loop"	1125.45
"317 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	1121.04
"716 DAVIDSON RD"	"Mt Pleasant Av & McCallum St "	1117.75
"700 DAVIDSON RD"	"Mt Pleasant Av & McCallum St "	1117.06
"8 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1117.01
"712 DAVIDSON RD"	"Mt Pleasant Av & McCallum St "	1116.01
"708 DAVIDSON RD"	"Mt Pleasant Av & McCallum St "	1116.01
"718 DAVIDSON RD"	"Henry Av & Cinnaminson St"	1114.26
"595 W GRAVERS LN"	"Germantown Av & Highland Av "	1113.82
"607 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1113.58
"7 DRUIM MOIR CT"	"Henry Av & Domino La - MBNS"	1113.49
"717 DAVIDSON RD"	"Henry Av & Cinnaminson St"	1111.99
"535 W MERMAID LN"	"Germantown Av & Roumfort Rd"	1111.50
"511 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1110.96
"4 DRUIM MOIR LN"	"Henry Av & Cinnaminson St"	1110.57
"530 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1110.28
"8520R HAGYS MILL RD"	"Ridge Av & Ivins Rd"	1107.39
"1 FORT MIFFLIN RD"	"Enterprise Av & Fort Mifflin Rd"	1101.19
"4701 FORT MIFFLIN RD"	"Enterprise Av & Fort Mifflin - FS"	1098.91
"10 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1097.92
"600 W HARTWELL LN"	"Germantown Av & Springfield Av "	1096.94
"321 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	1095.46
"6 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1095.20
"4 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1093.82
"711-25 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1092.61
"805 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1092.09
"802 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1092.02
"12 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1091.83
"8000 CHEROKEE ST"	"Henry Av & Domino La - MBNS"	1091.42
"3 FORT MIFFLIN RD"	"Enterprise Av & Fort Mifflin Rd"	1089.41
"528 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1088.93
"531 W MERMAID LN"	"Germantown Av & Roumfort Rd"	1088.20
"9 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1085.93
"601 W HARTWELL LN"	"Germantown Av & Willow Grove Av"	1085.76
"8500 TOWANDA AVE"	"Germantown Av & Highland Av "	1085.09
"801 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1082.61
"607R W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	1082.39
"11 RIVER RD"	"Oak Hill Apartments Loop"	1081.33
"720 DAVIDSON RD"	"Henry Av & Cinnaminson St"	1080.36
"14 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1077.59
"2 DRUIM MOIR LN"	"Henry Av & Cinnaminson St"	1075.31
"721 DAVIDSON RD"	"Henry Av & Cinnaminson St"	1071.60
"300 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	1065.81
"593 W GRAVERS LN"	"Germantown Av & Abington Av "	1065.19
"719 GLENGARRY RD"	"Wissahickon Av & Cathedral Rd - FS"	1065.14
"525 W MERMAID LN"	"Germantown Av & Roumfort Rd"	1064.84
"580 W MERMAID LN"	"Mt Pleasant Av & Emlen St "	1064.01
"16 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1063.85
"591 ADMIRALS PEARY WAY"	"Flagship Dr & 11th St "	1062.50
"4800 FORT MIFFLIN RD"	"Fort Mifflin Rd & Enterprise Av"	1062.10
"520 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1061.70
"415 W WILLOW GROVE AVE"	"Germantown Av & Springfield Av "	1061.49
"586 W MERMAID LN"	"Mt Pleasant Av & Cherokee St "	1061.25
"806 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1060.38
"7615 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1058.16
"604 W MERMAID LN"	"Mt Pleasant Av & Cherokee St "	1058.08
"602 W MERMAID LN"	"Mt Pleasant Av & Cherokee St "	1058.07
"606 W MERMAID LN"	"Mt Pleasant Av & McCallum St "	1055.97
"18 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1055.05
"701 CORNELIA PL"	"Henry Av & Cinnaminson St"	1054.54
"10 RIVER RD"	"Oak Hill Apartments Loop"	1052.59
"723 GLENGARRY RD"	"Henry Av & Wigard Av"	1050.32
"8 RIVER RD"	"Oak Hill Apartments Loop"	1045.48
"725 GLENGARRY RD"	"Henry Av & Wigard Av"	1041.04
"327 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	1039.20
"20 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1039.19
"566 SAINT ANDREW RD"	"Germantown Av & Willow Grove Av"	1038.01
"521 W MERMAID LN"	"Germantown Av & Roumfort Rd"	1037.70
"8 RIVER RD"	"Oak Hill Apartments Loop"	1037.62
"703 CORNELIA PL"	"Henry Av & Cinnaminson St"	1037.25
"22-24 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1036.64
"516 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1036.22
"701 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	1034.94
"728 DAVIDSON RD"	"Henry Av & Cinnaminson St"	1034.77
"30 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1033.93
"501-41 W WILLOW GROVE AVE"	"Germantown Av & Moreland Av "	1033.13
"11 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1026.18
"520 W MERMAID LN"	"Mt Pleasant Av & Emlen St "	1025.32
"725 DAVIDSON RD"	"Henry Av & Cinnaminson St"	1025.04
"567 W HARTWELL LN"	"Germantown Av & Willow Grove Av"	1023.13
"8 RIVER RD"	"Oak Hill Apartments Loop"	1022.88
"7616 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1022.59
"30 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1021.48
"265 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	1021.22
"8820 TOWANDA AVE"	"Germantown Av & Laughlin Ln "	1019.31
"8800 TOWANDA AVE"	"Germantown Av & Laughlin Ln "	1017.22
"729 GLENGARRY RD"	"Henry Av & Domino La - MBNS"	1014.99
"363 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	1014.45
"732-40 WOLCOTT DR"	"Henry Av & Cinnaminson St"	1014.06
"560 W MERMAID LN"	"Mt Pleasant Av & Emlen St "	1012.60
"460 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	1012.55
"517 W MERMAID LN"	"Germantown Av & Roumfort Rd"	1012.50
"108R MOREDUN AVE"	"Darlington Rd & Alburger Av "	1011.87
"108 MOREDUN AVE"	"Darlington Rd & Alburger Av "	1010.70
"707 CORNELIA PL"	"Henry Av & Cinnaminson St"	1010.13
"6 1/2 RIVER RD"	"Oak Hill Apartments Loop"	1009.37
"7 RIVER RD"	"Oak Hill Apartments Loop"	1009.32
"13 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	1007.17
"7609 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	1007.11
"501 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	1003.03
"8601-39 TOWANDA AVE"	"Germantown Av & Rex Av "	1001.17
"201 SPRING LN"	"Ridge Av & Cathedral Rd - FS"	1000.58
	"Ridge Av & Cathedral Rd - FS"	999.43
"120 MOREDUN AVE"	"Darlington Rd & Alburger Av "	998.93
"8400 TOWANDA AVE"	"Germantown Av & Abington Av "	998.30
"731 GLENGARRY RD"	"Henry Av & Domino La - MBNS"	995.49
"6 1/2 RIVER RD"	"Oak Hill Apartments Loop"	994.87
"705 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	991.09
"511 W MERMAID LN"	"Germantown Av & Roumfort Rd"	990.90
"100 LONGMEAD LN"	"Verree Rd & Bloomfield Av - 2 MBFS"	989.33
"17 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	988.61
"712 CORNELIA PL"	"Henry Av & Cinnaminson St"	988.39
"7614 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	987.66
"711 CORNELIA PL"	"Henry Av & Cinnaminson St"	983.72
"510 W MERMAID LN"	"Germantown Av & Roumfort Rd"	981.12
"6 1/2 RIVER RD"	"Oak Hill Apartments Loop"	981.05
"8862 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	976.19
"14 SHAWMONT AVE"	"Oak Hill Apartments Loop"	975.97
"2 MUSTIN ST"	"Front St & Pattison Av"	972.59
"253 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	971.58
"18 SHAWMONT AVE"	"Ridge Av & Flamingo St "	969.37
"8868 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	968.82
"12 SHAWMONT AVE"	"Oak Hill Apartments Loop"	968.30
"507 W TELNER ST"	"Mt Pleasant Av & Emlen St "	967.11
"8318 CHEROKEE ST"	"Wissahickon Av & Cathedral Rd - FS"	966.69
"7638 MCCALLUM ST"	"Mt Pleasant Av & McCallum St "	965.20
"519 W TELNER ST"	"Mt Pleasant Av & Emlen St "	964.87
"505 W MERMAID LN"	"Germantown Av & Roumfort Rd"	964.60
"527 W TELNER ST"	"Mt Pleasant Av & Emlen St "	964.42
"525 W TELNER ST"	"Mt Pleasant Av & Emlen St "	964.33
"716 CORNELIA PL"	"Henry Av & Cinnaminson St"	962.73
"463 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	961.45
"6 RIVER RD"	"Oak Hill Apartments Loop"	960.22
"455 REX AVE"	"Germantown Av & Chestnut Hill Av"	959.65
"535 W TELNER ST"	"Mt Pleasant Av & Cherokee St "	957.94
"500 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	957.55
"717 CORNELIA PL"	"Henry Av & Cinnaminson St"	954.45
"8840 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	953.87
"7612 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	952.87
"249 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	951.16
"20 SHAWMONT AVE"	"Ridge Av & Flamingo St "	947.18
"13 SHAWMONT AVE"	"Oak Hill Apartments Loop"	945.63
"504 W MERMAID LN"	"Germantown Av & Roumfort Rd"	945.62
"108 MOREDUN AVE"	"Darlington Rd & Alburger Av "	945.14
"108 MOREDUN AVE"	"Darlington Rd & Alburger Av "	945.08
"711 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	943.91
"8830 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	943.83
"8872 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	943.77
"537 REX AVE"	"Wissahickon Av & Cathedral Rd - FS"	941.61
"501 W MERMAID LN"	"Germantown Av & Roumfort Rd"	940.81
"450 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	938.66
"141 PHEASANT HILL DR"	"Darlington Rd & Alburger Av "	937.67
"5 FORT MIFFLIN RD"	"Enterprise Av & Fort Mifflin Rd"	937.53
"720 CORNELIA PL"	"Henry Av & Cinnaminson St"	937.07
"7600 MCCALLUM ST"	"Mt Pleasant Av & McCallum St "	936.38
"111 LONGMEAD LN"	"Verree Rd & Bloomfield Av - 2 MBFS"	933.28
"505 W TELNER ST"	"Germantown Av & Roumfort Rd"	932.67
"120 PHEASANT HILL DR"	"Darlington Rd & Alburger Av "	931.34
"200 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	930.66
"120 MOREDUN AVE"	"Darlington Rd & Alburger Av "	929.75
"385 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	929.12
"461 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	927.16
"307 PORT ROYAL AVE"	"Ridge Av & Flamingo St "	927.05
"645 GATEHOUSE LN"	"Henry Av & Cinnaminson St"	926.91
"7617 MCCALLUM ST"	"Mt Pleasant Av & McCallum St "	925.65
"435 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	921.75
"8860 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	918.13
"721 CORNELIA PL"	"Henry Av & Cinnaminson St"	917.47
"455 W CHESTNUT HILL AVE"	"Germantown Av & Norman Ln"	917.26
"434 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	916.65
"7811 HURON ST"	"Germantown Av & Moreland Av "	915.38
"724 CORNELIA PL"	"Henry Av & Cinnaminson St"	911.42
"7616 HURON ST"	"Germantown Av & Roumfort Rd"	910.99
"108 MOREDUN AVE"	"Darlington Rd & Alburger Av "	909.37
"8807 TOWANDA AVE"	"Germantown Av & Norman Ln"	907.39
"446 W CHESTNUT HILL AVE"	"Germantown Av & Chestnut Hill Av"	906.20
"541 REX AVE"	"Wissahickon Av & Cathedral Rd - FS"	906.14
"5 1/2 RIVER RD"	"Oak Hill Apartments Loop"	905.87
"227 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	904.97
"131 PHEASANT HILL DR"	"Darlington Rd & Alburger Av "	904.32
"640 GATEHOUSE LN"	"Mt Pleasant Av & McCallum St "	902.06
"101 LONGMEAD LN"	"Verree Rd & Bloomfield Av - 2 MBFS"	901.21
"511 W GRAVERS LN"	"Germantown Av & Abington Av "	900.10
"27 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	899.44
"102 MOREDUN AVE"	"Darlington Rd & Alburger Av "	899.28
"432 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	894.61
"110 PHEASANT HILL DR"	"Darlington Rd & Alburger Av "	894.36
"3 1/2 RIVER RD"	"Oak Hill Apartments Loop"	893.99
"100 PHEASANT HILL DR"	"Verree Rd & Bloomfield Av "	891.75
"7600 HURON ST"	"Germantown Av & Roumfort Rd"	891.32
"655 GATEHOUSE LN"	"Henry Av & Cinnaminson St"	891.23
"725 CORNELIA PL"	"Henry Av & Cinnaminson St"	891.16
"30 DRUIM MOIR LN"	"Henry Av & Domino La - MBNS"	888.68
"715 W GRAVERS LN"	"Wissahickon Av & Cathedral Rd - FS"	886.54
"8850 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	884.55
"5 RIVER RD"	"Oak Hill Apartments Loop"	884.53
"728 CORNELIA PL"	"Henry Av & Cinnaminson St"	883.94
"8318 SAINT MARTINS LN"	"Germantown Av & Abington Av "	882.29
"8800 PINE RD"	"Verree Rd & Bloomfield Av - 3 MBFS"	882.26
"3 1/2 RIVER RD"	"Oak Hill Apartments Loop"	881.58
"520 W TELNER ST"	"Mt Pleasant Av & Emlen St "	879.64
"383 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	875.97
"359 SPRING LN"	"Ridge Av & Ivins Rd"	875.82
"7504 MCCALLUM ST"	"Mt Pleasant Av & McCallum St "	875.00
"515 W HARTWELL LN"	"Germantown Av & Willow Grove Av"	874.47
"530 W TELNER ST"	"Mt Pleasant Av & Emlen St "	871.31
"526 W TELNER ST"	"Mt Pleasant Av & Emlen St "	871.26
"8970 PINE RD"	"Verree Rd & Bloomfield Av - 2 MBFS"	870.92
"4 1/2 RIVER RD"	"Oak Hill Apartments Loop"	870.53
"515 W GRAVERS LN"	"Germantown Av & Highland Av "	870.47
"391 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	869.00
"8980 PINE RD"	"Verree Rd & Bloomfield Av - 2 MBFS"	868.75
"430 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	868.00
"540 W TELNER ST"	"Mt Pleasant Av & Cherokee St "	867.73
"100 SHAWMONT AVE"	"Ridge Av & Flamingo St "	867.71
"104 MOREDUN AVE"	"Darlington Rd & Alburger Av "	867.41
"8986 PINE RD"	"Verree Rd & Bloomfield Av - 2 MBFS"	867.38
"8990 PINE RD"	"Verree Rd & Bloomfield Av - 2 MBFS"	867.13
"120 MOREDUN AVE"	"Darlington Rd & Alburger Av "	866.73
"427 W MERMAID LN"	"Germantown Av & Roumfort Rd"	866.70
"8860R TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	865.83
"729 CORNELIA PL"	"Henry Av & Cinnaminson St"	865.39
"4 RIVER RD"	"Oak Hill Apartments Loop"	863.95
"121 PHEASANT HILL DR"	"Darlington Rd & Alburger Av "	861.71
"699 W HARTWELL LN"	"Henry Av & Domino La - MBNS"	861.09
"111 PHEASANT HILL DR"	"Darlington Rd & Alburger Av "	860.54
"101 PHEASANT HILL DR"	"Darlington Rd & Alburger Av "	860.43
"8992 PINE RD"	"Verree Rd & Bloomfield Av "	858.94
"150 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	858.29
"341 PORT ROYAL AVE"	"Ridge Av & Flamingo St "	856.62
"8300 SAINT MARTINS LN"	"Germantown Av & Abington Av "	856.47
"732 CORNELIA PL"	"Henry Av & Cinnaminson St"	856.46
"8870 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	853.51
"140 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	852.86
"500 W TELNER ST"	"Mt Pleasant Av & Emlen St "	852.86
"8868R-72 TOWANDA AVE"	"Wissahickon Av & Cathedral Rd - FS"	852.72
"2 RIVER RD"	"Oak Hill Apartments Loop"	852.23
"3 1/2 RIVER RD"	"Oak Hill Apartments Loop"	850.72
"225 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	848.89
"168 SHAWMONT AVE"	"Ridge Av & Flamingo St "	848.72
"444 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	848.55
"440 REX AVE"	"Germantown Av & Chestnut Hill Av"	847.32
"424 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	847.22
"429 W MORELAND AVE"	"Germantown Av & Mermaid Ln"	846.94
"490 W TELNER ST"	"Germantown Av & Roumfort Rd"	845.29
"8994 PINE RD"	"Verree Rd & Bloomfield Av "	845.16
"4301 N DELAWARE AVE"	"Delaware Av & Wheatsheaf Ln"	841.74
"501 W GRAVERS LN"	"Germantown Av & Gravers Ln "	839.38
"425 W MERMAID LN"	"Germantown Av & Roumfort Rd"	839.09
"620 GATEHOUSE LN"	"Mt Pleasant Av & McCallum St "	838.52
"271 HILLSIDE AVE"	"Domino Ln & Fowler St"	838.42
"106 MOREDUN AVE"	"Darlington Rd & Alburger Av "	837.42
"3 RIVER RD"	"Oak Hill Apartments Loop"	835.78
"8450 PINE RD"	"Verree Rd & Susquehanna Rd "	835.39
"733 CORNELIA PL"	"Henry Av & Cinnaminson St"	833.83
"110R MOREDUN AVE"	"Darlington Rd & Alburger Av "	833.00
"8212 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	832.88
"437 W CHESTNUT HILL AVE"	"Germantown Av & Norman Ln"	831.02
"2 RIVER RD"	"Oak Hill Apartments Loop"	829.04
"709 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	827.84
"16 SHAWMONT AVE"	"Oak Hill Apartments Loop"	826.82
"110 MOREDUN AVE"	"Darlington Rd & Alburger Av "	824.76
"734 CORNELIA PL"	"Henry Av & Cinnaminson St"	822.57
"8811 TOWANDA AVE"	"Germantown Av & Norman Ln"	822.04
"501 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	820.06
"2 RIVER RD"	"Oak Hill Apartments Loop"	819.76
"114 MOREDUN AVE"	"Darlington Rd & Alburger Av "	819.02
"393 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	817.06
"399 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	816.98
"241 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	814.54
"440 W MERMAID LN"	"Germantown Av & Roumfort Rd"	814.29
"120 MOREDUN AVE"	"Darlington Rd & Alburger Av "	813.71
"512 W TELNER ST"	"Mt Pleasant Av & Emlen St "	813.69
"8200 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	813.21
"7990 PENROSE FERRY RD"	"Enterprise Av & Fort Mifflin Rd"	811.60
"371 PORT ROYAL AVE"	"Ridge Av & Flamingo St "	811.53
"5150 S 19TH ST"	"Broad St & Flagship Dr "	811.27
"440 W CHESTNUT HILL AVE"	"Germantown Av & Chestnut Hill Av"	810.99
"126 MOREDUN AVE"	"Darlington Rd & Alburger Av "	810.31
"136 MOREDUN AVE"	"Darlington Rd & Alburger Av "	808.15
"7401 SHERMAN ST"	"Mt Pleasant Av & McCallum St "	807.25
"144 MOREDUN AVE"	"Darlington Rd & Alburger Av "	807.23
"150 MOREDUN AVE"	"Darlington Rd & Alburger Av "	807.12
"8450 SAINT MARTINS LN"	"Germantown Av & Gravers Ln "	806.91
"709 SAINT GEORGES RD"	"Henry Av & Crease Ln"	805.39
"422 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	804.76
"110 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	803.52
"176 SHAWMONT AVE"	"Ridge Av & Flamingo St "	802.56
"1925 KITTY HAWK AVE"	"26th St & Tastykake - 2"	801.23
"610 GATEHOUSE LN"	"Mt Pleasant Av & McCallum St "	801.12
"420 REX AVE"	"Germantown Av & Chestnut Hill Av"	798.31
"434 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	796.44
"104 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	796.06
"2 RIVER RD"	"Oak Hill Apartments Loop"	795.99
"503 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	795.74
"290 HILLSIDE AVE"	"Domino Ln & Fowler St"	795.03
"51 MUSTIN ST"	"11th St & Kitty Hawk Av"	794.69
"7515 SHAW ST"	"Domino Ln & Fowler St"	794.49
"8128 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	793.69
"415 W MORELAND AVE"	"Germantown Av & Moreland Av "	793.36
"737 CORNELIA PL"	"Henry Av & Cinnaminson St"	793.12
"709 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	791.07
"758 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	791.04
"524 W TELNER ST"	"Mt Pleasant Av & Emlen St "	790.87
"7502 SAINT MARTINS LN"	"Germantown Av & Roumfort Rd"	790.71
"1900 KITTY HAWK AVE"	"Broad St & Kitty Hawk Av "	790.41
"7542 SHAW ST"	"Domino Ln & Fowler St"	790.06
"7500 MCCALLUM ST"	"Mt Pleasant Av & McCallum St "	789.83
"451 W WILLOW GROVE AVE"	"Germantown Av & Springfield Av "	789.46
"604 GATEHOUSE LN"	"Mt Pleasant Av & McCallum St "	789.21
"501 GREENHILL LN"	"Ridge Av & Manatawna Av"	787.87
"8124 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	785.99
"8440 SAINT MARTINS LN"	"Germantown Av & Highland Av "	784.97
"245 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	784.38
"193 FLAMINGO ST"	"Domino Ln & Fowler St"	784.00
"8219 SAINT MARTINS LN"	"Germantown Av & Abington Av "	782.92
"427 W GRAVERS LN"	"Germantown Av & Gravers Ln "	782.86
"121 PORT ROYAL AVE"	"Oak Hill Apartments Loop"	781.78
"202 SHAWMONT AVE"	"Ridge Av & Flamingo St "	781.30
"736 CORNELIA PL"	"Henry Av & Cinnaminson St"	780.62
"190 SHAWMONT AVE"	"Ridge Av & Flamingo St "	778.70
"2 RIVER RD"	"Oak Hill Apartments Loop"	778.55
"7509 SHAW ST"	"Domino Ln & Fowler St"	778.25
"1 1/2 RIVER RD"	"Oak Hill Apartments Loop"	777.68
"715 SAINT GEORGES RD"	"Henry Av & Crease Ln"	777.11
"204 SHAWMONT AVE"	"Ridge Av & Flamingo St "	777.03
"8112 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	776.99
"421 W MERMAID LN"	"Germantown Av & Roumfort Rd"	776.68
"532 W TELNER ST"	"Mt Pleasant Av & Emlen St "	774.97
"192 SHAWMONT AVE"	"Ridge Av & Flamingo St "	774.10
"206 SHAWMONT AVE"	"Ridge Av & Flamingo St "	773.88
"195 FLAMINGO ST"	"Domino Ln & Fowler St"	773.67
"16 SHAWMONT AVE"	"Oak Hill Apartments Loop"	773.64
"7540 SHAW ST"	"Domino Ln & Fowler St"	773.55
"503 GREENHILL LN"	"Ridge Av & Manatawna Av"	772.93
"406 REX AVE"	"Germantown Av & Chestnut Hill Av"	772.85
"490 SPRING LN"	"Ridge Av & Cathedral Rd - FS"	772.22
"8215 SAINT MARTINS LN"	"Germantown Av & Abington Av "	770.27
"711 SAINT GEORGES RD"	"Henry Av & Crease Ln"	769.93
"500 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	769.92
"208 SHAWMONT AVE"	"Ridge Av & Flamingo St "	769.67
"194 SHAWMONT AVE"	"Ridge Av & Flamingo St "	769.53
"387 PORT ROYAL AVE"	"Ridge Av & Flamingo St "	769.06
"8420 SAINT MARTINS LN"	"Germantown Av & Highland Av "	768.93
"505 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd  - MBNS"	768.69
"756 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	767.31
"196 SHAWMONT AVE"	"Ridge Av & Flamingo St "	764.98
"4468 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	764.33
"3150 ORTHODOX ST"	"Richmond St & Orthodox St"	763.83
"210 SHAWMONT AVE"	"Ridge Av & Flamingo St "	763.71
"420 W MERMAID LN"	"Germantown Av & Roumfort Rd"	762.94
"405 REX AVE"	"Germantown Av & Chestnut Hill Av"	762.92
"7601 MCCALLUM ST"	"Mt Pleasant Av & Cherokee St "	760.80
"198 SHAWMONT AVE"	"Ridge Av & Flamingo St "	760.45
"212 SHAWMONT AVE"	"Ridge Av & Flamingo St "	759.98
"4466 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	759.64
"403 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	759.56
"707 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	758.91
"505 GREENHILL LN"	"Ridge Av & Manatawna Av"	758.57
"8104 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	758.43
"7505 SHAW ST"	"Domino Ln & Fowler St"	758.19
"214 SHAWMONT AVE"	"Ridge Av & Flamingo St "	757.51
"1030 LIVEZEY LN"	"Henry Av & Livezey Ln"	757.04
"416 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	756.07
"7524-28 LAWN ST"	"Domino Ln & Fowler St"	756.03
"534 W TELNER ST"	"Mt Pleasant Av & Cherokee St "	755.29
"500 LANTERN LN"	"Ridge Av & Manatawna Av"	755.24
"411 W MORELAND AVE"	"Germantown Av & Moreland Av "	755.13
"4464 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	754.63
"4470 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	754.23
"216 SHAWMONT AVE"	"Ridge Av & Flamingo St "	753.86
"200 SHAWMONT AVE"	"Ridge Av & Flamingo St "	753.69
"7538 SHAW ST"	"Domino Ln & Fowler St"	750.39
"354 FLAMINGO ST"	"Ridge Av & Wigard Av "	750.38
"4462 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	749.96
"7518 LAWN ST"	"Domino Ln & Fowler St"	747.87
"8040 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	747.36
"101 MOREDUN AVE"	"Darlington Rd & Alburger Av "	746.81
"542 W TELNER ST"	"Mt Pleasant Av & Cherokee St "	746.47
"502 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	745.17
"4460 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	745.06
"4472 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	744.36
"507 GREENHILL LN"	"Ridge Av & Manatawna Av"	743.99
"8 SHAWMONT AVE"	"Oak Hill Apartments Loop"	743.64
"502 LANTERN LN"	"Ridge Av & Manatawna Av"	743.04
"125 MOREDUN AVE"	"Darlington Rd & Alburger Av "	742.41
"1020 LIVEZEY LN"	"Sedgwick St & Wayne Av Loop"	742.32
"8209 SAINT MARTINS LN"	"Germantown Av & Abington Av "	742.08
"356 FLAMINGO ST"	"Domino Ln & Fowler St"	741.54
"7391 SHERMAN ST"	"Mt Pleasant Av & McCallum St "	741.35
"8996 PINE RD"	"Darlington Rd & Alburger Av "	741.30
"101 BLOOMFIELD AVE"	"Verree Rd & Bloomfield Av "	740.81
"9001 PINE RD"	"Verree Rd & Bloomfield Av "	740.81
"4458 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	740.45
"7504 SAINT MARTINS LN"	"Germantown Av & Roumfort Rd"	740.36
"7516 LAWN ST"	"Domino Ln & Fowler St"	739.28
"4474 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	738.34
"7501 SHAW ST"	"Domino Ln & Fowler St"	738.23
"8030 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	737.38
"4456 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	736.42
"1 RIVER RD"	"Oak Hill Apartments Loop"	736.23
"415 W MERMAID LN"	"Germantown Av & Roumfort Rd"	734.89
"1019 W ALLENS LN"	"Henry Av & Livezey Ln"	734.20
"1901 KITTY HAWK AVE"	"26th St & Tastykake - 2"	733.29
"418 W MERMAID LN"	"Germantown Av & Roumfort Rd"	733.28
"4454 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	732.63
"750-52 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	732.33
"504 LANTERN LN"	"Ridge Av & Manatawna Av"	732.21
"4476 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	732.09
"15057 POQUESSING CREEK LN"	"Somerton Rd & Metropolitan Dr"	731.31
"200 MOREDUN AVE"	"Darlington Rd & Alburger Av "	731.24
"8400 JEANES ST"	"Verree Rd & Strahle St "	731.10
"759 W ALLENS LN"	"Mt Pleasant Av & McCallum St "	730.36
"1001 LIVEZEY LN"	"Sedgwick St & Wayne Av Loop"	730.34
"509 GREENHILL LN"	"Ridge Av & Manatawna Av"	730.27
"8402 JEANES ST"	"Verree Rd & Strahle St "	729.50
"8020 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	728.55
"969 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	728.01
"1040 LIVEZEY LN"	"Henry Av & Livezey Ln"	727.49
"8404 JEANES ST"	"Verree Rd & Strahle St "	727.47
"7890 NIXON ST"	"Oak Hill Apartments Loop"	726.93
"8406 JEANES ST"	"Verree Rd & Kendrick St "	726.70
"15055 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	726.68
"111 MOREDUN AVE"	"Darlington Rd & Alburger Av "	726.54
"8203 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	726.46
"713 SAINT GEORGES RD"	"Henry Av & Crease Ln"	726.28
"1373 POQUESSING CREEK DR"	"Southampton Rd & Endicott St"	726.23
"4478 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	726.22
"4452 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	726.10
"416 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	725.94
"356 FLAMINGO ST"	"Domino Ln & Fowler St"	725.78
"507 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd  - MBNS"	725.74
"7600 CHEROKEE ST"	"Mt Pleasant Av & Cherokee St "	725.26
"1375 POQUESSING CREEK DR"	"Southampton Rd & Endicott St"	725.21
"15045 LIBERTY LN"	"Southampton Rd & London Rd"	725.13
"1015 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	723.88
"15052 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	723.44
"8408 JEANES ST"	"Verree Rd & Kendrick St "	723.11
"204 MOREDUN AVE"	"Verree Rd & Bloomfield Av "	723.11
"15054 POQUESSING CREEK LN"	"Somerton Rd & Metropolitan Dr"	722.45
"15176 ENDICOTT ST"	"Southampton Rd & Endicott St"	722.27
"963 MANATAWNA AVE"	"Grakyn Ln & Wissahickon Av - FS"	721.27
"748 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	720.73
"186 SHAWMONT AVE"	"Ridge Av & Flamingo St "	720.70
"404 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	720.46
"504 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	720.45
"4480 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	720.45
"7510 LAWN ST"	"Domino Ln & Fowler St"	720.22
"389 PORT ROYAL AVE"	"Ridge Av & Shawmont Av "	719.88
"8410 JEANES ST"	"Verree Rd & Kendrick St "	719.69
"4451 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	719.63
"501 LANTERN LN"	"Ridge Av & Manatawna Av"	719.32
"15044 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	719.26
"422 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	719.02
"506 LANTERN LN"	"Ridge Av & Manatawna Av"	718.73
"3099 ORTHODOX ST"	"Richmond St & Lefevre St "	718.66
"721 SAINT GEORGES RD"	"Henry Av & Crease Ln"	718.20
"401 W WILLOW GROVE AVE"	"Germantown Av & Springfield Av "	717.84
"15053 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	717.11
"15042 LIBERTY LN"	"Southampton Rd & London Rd"	716.55
"511 GREENHILL LN"	"Ridge Av & Manatawna Av"	716.53
"15047 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	716.17
"8412 JEANES ST"	"Verree Rd & Kendrick St "	716.09
"4450 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	716.06
"4449 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	715.98
"15174 ENDICOTT ST"	"Southampton Rd & Endicott St"	715.17
"15043 LIBERTY LN"	"Southampton Rd & London Rd"	714.56
"4482 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	714.51
"4101 CARBON ST"	"Richmond St & Alresford St "	714.40
"8412 SEMINOLE AVE"	"Germantown Av & Highland Av "	714.28
"15059 POQUESSING CREEK LN"	"Somerton Rd & Metropolitan Dr"	714.21
"286 DEARNLEY ST"	"Domino Ln & Fowler St"	713.97
"4453 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	713.95
"414 W MERMAID LN"	"Germantown Av & Roumfort Rd"	713.27
"965 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	713.22
"8414 JEANES ST"	"Verree Rd & Kendrick St "	712.76
"15056 POQUESSING CREEK LN"	"Somerton Rd & Metropolitan Dr"	712.54
"501 RIDGERUN LN"	"Verree Rd & Susquehanna Rd  - MBNS"	712.35
"8400 SEMINOLE AVE"	"Germantown Av & Gravers Ln "	712.23
"15050 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	711.98
"8500 SEMINOLE AVE"	"Germantown Av & Bethlehem Pk - FS"	711.94
"290 DEARNLEY ST"	"Ridge Av & Wigard Av "	711.30
"1023 W ALLENS LN"	"Henry Av & Livezey Ln"	711.17
"959 MANATAWNA AVE"	"Grakyn Ln & Wissahickon Av - FS"	711.11
"3100 ORTHODOX ST"	"Richmond St & Orthodox St"	710.74
"4448 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	710.57
"8201 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	710.50
"768 SAINT GEORGES RD"	"Sedgwick St & Wayne Av Loop"	710.30
"4447 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	710.08
"15046 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	710.06
"1011 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	709.80
"8416 JEANES ST"	"Verree Rd & Kendrick St "	709.51
"500 ARNOLD ST"	"Rhawn St & Jeanes St"	709.43
"15218 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	708.85
"964 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	708.52
"701 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	708.41
"429 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	708.06
"4484 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	708.02
"7450 EMLEN ST"	"Mt Pleasant Av & Lincoln Dr "	707.93
"502 ARNOLD ST"	"Rhawn St & Jeanes St"	707.88
"15051 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	707.80
"4455 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	707.79
"7512 SAINT MARTINS LN"	"Germantown Av & Roumfort Rd"	707.78
"15172 ENDICOTT ST"	"Southampton Rd & Endicott St"	707.60
"504 ARNOLD ST"	"Rhawn St & Jeanes St"	707.21
"506 ARNOLD ST"	"Rhawn St & Jeanes St"	707.13
"15217 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	706.99
"400 W WILLOW GROVE AVE"	"Germantown Av & Springfield Av "	706.68
"15040 LIBERTY LN"	"Southampton Rd & London Rd"	706.57
"8418 JEANES ST"	"Verree Rd & Kendrick St "	706.29
"508 ARNOLD ST"	"Verree Rd & Strahle St "	706.07
"408 W MORELAND AVE"	"Germantown Av & Roumfort Rd"	705.97
"15049 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	705.65
"3101 ORTHODOX ST"	"Richmond St & Lefevre St "	705.56
"967 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	705.36
"101R MOREDUN AVE"	"Darlington Rd & Alburger Av "	705.19
"358 FLAMINGO ST"	"Domino Ln & Fowler St"	705.10
"15041 LIBERTY LN"	"Southampton Rd & London Rd"	705.07
"4445 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	704.69
"4446 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	704.50
"201 FLAMINGO ST"	"Domino Ln & Fowler St"	704.30
"11750 TELFAIR RD"	"Knights Rd & Patrician Dr "	703.75
"503 LANTERN LN"	"Ridge Av & Manatawna Av"	703.67
"15219 BERNITA DR"	"Southampton Rd & Edison Av"	703.42
"8420 JEANES ST"	"Verree Rd & Kendrick St "	703.22
"15171 ENDICOTT ST"	"Southampton Rd & Endicott St"	703.10
"7508 LAWN ST"	"Domino Ln & Fowler St"	702.56
"15048 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	702.54
"15058 POQUESSING CREEK LN"	"Somerton Rd & Metropolitan Dr"	702.44
"4457 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	701.95
"4486 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	701.90
"510 GREENHILL LN"	"Ridge Av & Manatawna Av"	701.47
"413 W MERMAID LN"	"Germantown Av & Roumfort Rd"	701.33
"961 MANATAWNA AVE"	"Grakyn Ln & Wissahickon Av - FS"	701.05
"1010 LIVEZEY LN"	"Sedgwick St & Wayne Av Loop"	700.87
"8600 SEMINOLE AVE"	"Germantown Av & Rex Av "	700.75
"8422 JEANES ST"	"Verree Rd & Kendrick St "	700.44
"15048 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	700.35
"15170 ENDICOTT ST"	"Southampton Rd & Endicott St"	700.09
"757 W ALLENS LN"	"Mt Pleasant Av & McCallum St "	699.61
"4443 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	699.02
"15219 WAYSIDE RD"	"Somerton Rd & Trevose Rd - MBNS"	698.71
"15038 LIBERTY LN"	"Southampton Rd & London Rd"	698.52
"4444 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	698.47
"475 SPRING LN"	"Ridge Av & Caledonia St - MBFS"	698.46
"513 GREENHILL LN"	"Ridge Av & Spring  Ln"	698.14
"107 BLOOMFIELD AVE"	"Verree Rd & Bloomfield Av "	698.12
"8500 JEANES ST"	"Verree Rd & Kendrick St "	697.98
"11748 TELFAIR RD"	"Knights Rd & Patrician Dr "	697.91
"510 ARNOLD ST"	"Verree Rd & Strahle St "	697.51
"15049 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	697.10
"1007 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	696.93
"7906 SAINT MARTINS LN"	"Germantown Av & Moreland Av "	696.89
"4488 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	696.81
"501 ARNOLD ST"	"Verree Rd & Strahle St "	696.60
"15039 LIBERTY LN"	"Southampton Rd & London Rd"	695.88
"15051 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	695.82
"506 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	695.76
"8502 JEANES ST"	"Verree Rd & Kendrick St "	695.71
"508 LANTERN LN"	"Ridge Av & Caledonia St - MBFS"	695.56
"15169 ENDICOTT ST"	"Southampton Rd & Endicott St"	695.43
"8616 SEMINOLE AVE"	"Germantown Av & Rex Av "	695.40
"8504 JEANES ST"	"Verree Rd & Kendrick St "	693.66
"15222 BERNITA DR"	"Somerton Rd & Trevose Rd - 2"	693.49
"15220 WAYSIDE RD"	"Somerton Rd & Trevose Rd - 2"	693.45
"101 MOREDUN AVE"	"Darlington Rd & Alburger Av "	693.00
"15158 MILFORD ST"	"Southampton Rd & Endicott St"	692.78
"15168 ENDICOTT ST"	"Southampton Rd & Endicott St"	692.71
"4442 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	692.49
"15216 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	692.17
"8320 SEMINOLE AVE"	"Germantown Av & Abington Av "	692.16
"11746 TELFAIR RD"	"Knights Rd & Patrician Dr "	692.10
"15221 BERNITA DR"	"Somerton Rd & Trevose Rd - 2"	692.03
"8506 JEANES ST"	"Verree Rd & Kendrick St "	691.96
"15046 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	691.95
"15060 POQUESSING CREEK LN"	"Somerton Rd & Metropolitan Dr"	691.84
"1050 LIVEZEY LN"	"Henry Av & Livezey Ln"	691.18
"8508 JEANES ST"	"Verree Rd & Kendrick St "	690.67
"4441 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	690.48
"7532 SHAW ST"	"Domino Ln & Fowler St - MBFS"	690.34
"4301 N DELAWARE AVE"	"Delaware Av & Wheatsheaf Ln"	690.32
"15050 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	690.29
"15215 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	690.14
"4459 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	690.08
"11747 TELFAIR RD"	"Knights Rd & Patrician Dr "	689.80
"505 LANTERN LN"	"Ridge Av & Manatawna Av"	689.67
"8510 JEANES ST"	"Verree Rd & Kendrick St "	689.56
"15053 LIBERTY LN"	"Somerton Rd & Metropolitan Dr"	689.40
"512 ARNOLD ST"	"Verree Rd & Strahle St "	688.96
"7515 LAWN ST"	"Domino Ln & Fowler St"	688.92
"8512 JEANES ST"	"Verree Rd & Kendrick St "	688.68
"11745 TELFAIR RD"	"Knights Rd & Patrician Dr "	688.31
"962 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	688.09
"503 ARNOLD ST"	"Verree Rd & Strahle St "	688.07
"15047 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	688.01
"8514 JEANES ST"	"Verree Rd & Kendrick St "	687.87
"15167 ENDICOTT ST"	"Southampton Rd & Endicott St"	687.77
"1070 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	687.62
"8115 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	687.50
"15036 LIBERTY LN"	"Southampton Rd & London Rd"	687.45
"401 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	687.22
"300 DEARNLEY ST"	"Ridge Av & Wigard Av "	687.20
"8516 JEANES ST"	"Verree Rd & Kendrick St "	687.17
"956 CALEDONIA ST"	"Grakyn Ln & Wissahickon Av - FS"	687.00
	"Delaware Av & Wheatsheaf Ln"	686.94
"8518 JEANES ST"	"Verree Rd & Kendrick St "	686.60
"4440 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	686.36
"503 RIDGERUN LN"	"Verree Rd & Susquehanna Rd  - MBNS"	686.30
"8520 JEANES ST"	"Verree Rd & Kendrick St "	686.14
"11743 TELFAIR RD"	"Knights Rd & Patrician Dr "	685.85
"15166 ENDICOTT ST"	"Southampton Rd & Endicott St"	685.82
"8522 JEANES ST"	"Verree Rd & Kendrick St "	685.80
"8524 JEANES ST"	"Verree Rd & Kendrick St "	685.56
"8998 PINE RD"	"Darlington Rd & Alburger Av "	685.45
"8526 JEANES ST"	"Verree Rd & Susquehanna Rd "	685.34
"7506 LAWN ST"	"Domino Ln & Fowler St"	684.95
"15156 MILFORD ST"	"Southampton Rd & Endicott St"	684.51
"15037 LIBERTY LN"	"Southampton Rd & London Rd"	684.49
"15217 BERNITA DR"	"Southampton Rd & Edison Av"	684.30
"400 REX AVE"	"Germantown Av & Chestnut Hill Av"	684.23
"512 GREENHILL LN"	"Ridge Av & Manatawna Av"	683.97
"1027 W ALLENS LN"	"Henry Av & Livezey Ln"	683.62
"1 MOREDUN PL"	"Verree Rd & Bloomfield Av "	683.10
"11741 TELFAIR RD"	"Knights Rd & Patrician Dr "	683.09
"500 KENDRICK ST"	"Verree Rd & Kendrick St "	682.95
"15220 BERNITA DR"	"Southampton Rd & Edison Av"	682.53
"2 MOREDUN PL"	"Darlington Rd & Alburger Av "	682.53
"509 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd  - MBNS"	682.27
"9040 PINE RD"	"Darlington Rd & Alburger Av "	681.85
"957 CALEDONIA ST"	"Grakyn Ln & Wissahickon Av - FS"	681.65
"8750 HAGYS MILL RD"	"Ridge Av & Cathedral Rd - FS"	681.07
"4301 N DELAWARE AVE"	"Delaware Av & Wheatsheaf Ln"	681.01
"206-08 MOREDUN AVE"	"Verree Rd & Bloomfield Av "	680.80
"4439 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	680.77
"6953 GREENHILL RD"	"Haverford Av & Sherwood Rd - FS"	680.72
"15221 WAYSIDE RD"	"Somerton Rd & Trevose Rd - MBNS"	680.60
"515 GREENHILL LN"	"Ridge Av & Spring  Ln"	680.53
"8998A PINE RD"	"Darlington Rd & Alburger Av "	680.47
"4438 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	680.42
"514 ARNOLD ST"	"Verree Rd & Strahle St "	680.40
"400 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	680.26
"15044 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	680.17
"201-27 SHAWMONT AVE"	"Domino Ln & Fowler St - MBFS"	680.05
"953 MANATAWNA AVE"	"Grakyn Ln & Wissahickon Av - FS"	679.80
"755 W ALLENS LN"	"Mt Pleasant Av & McCallum St "	679.69
"3103 MAUREEN DR"	"Townsend Rd & Natl Archives -opp entrance"	679.67
"15165 ENDICOTT ST"	"Southampton Rd & Endicott St"	679.59
"121R PORT ROYAL AVE"	"Oak Hill Apartments Loop"	679.40
"505 ARNOLD ST"	"Verree Rd & Strahle St "	679.37
"15155 MILFORD ST"	"Southampton Rd & Carter Rd"	679.11
"8528 JEANES ST"	"Verree Rd & Susquehanna Rd "	679.10
"15164 ENDICOTT ST"	"Southampton Rd & Endicott St"	679.06
"15045 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	678.92
"7403 EMLEN ST"	"Mt Pleasant Av & Lincoln Dr "	678.81
"1001 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	678.79
"7518 NEWLAND ST"	"Domino Ln & Fowler St"	678.71
"401 STRAHLE ST"	"Rhawn St & Jeanes St"	678.66
"401 W MORELAND AVE"	"Germantown Av & Moreland Av "	678.48
"4461 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	678.44
"4490 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	678.13
"403 STRAHLE ST"	"Rhawn St & Jeanes St"	677.91
"8111 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	677.70
"8316 SEMINOLE AVE"	"Germantown Av & Abington Av "	677.57
"502 SUSQUEHANNA RD"	"Verree Rd & Susquehanna Rd "	677.37
"405 STRAHLE ST"	"Rhawn St & Jeanes St"	677.22
"407 STRAHLE ST"	"Rhawn St & Jeanes St"	676.64
"3115 MAUREEN DR"	"Medford Rd & Lester Rd"	676.62
"3117 MAUREEN DR"	"Medford Rd & Lester Rd"	676.56
"4437 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	676.53
"409 STRAHLE ST"	"Rhawn St & Jeanes St"	676.15
"15224 BERNITA DR"	"Somerton Rd & Trevose Rd - 2"	676.02
"643R SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	675.96
"9709 LOCHWOOD RD"	"Verree Rd & Pine Hill Rd - MBNS"	675.94
"15214 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	675.87
"411 STRAHLE ST"	"Rhawn St & Jeanes St"	675.75
"15154 MILFORD ST"	"Southampton Rd & Endicott St"	675.63
"413 STRAHLE ST"	"Rhawn St & Jeanes St"	675.37
"510 LANTERN LN"	"Ridge Av & Caledonia St - MBFS"	675.27
"415 STRAHLE ST"	"Rhawn St & Jeanes St"	675.19
"417 STRAHLE ST"	"Rhawn St & Jeanes St"	675.11
"501 STRAHLE ST"	"Rhawn St & Jeanes St"	675.11
"15035 LIBERTY LN"	"Southampton Rd & London Rd"	675.11
"419 STRAHLE ST"	"Rhawn St & Jeanes St"	675.10
"15034 LIBERTY LN"	"Southampton Rd & London Rd"	675.01
"6943 GREENHILL RD"	"Lankenau Medical Center"	674.95
"8530 JEANES ST"	"Verree Rd & Susquehanna Rd "	674.89
"502 KENDRICK ST"	"Verree Rd & Kendrick St "	674.56
"4436 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	674.48
"9707 LOCHWOOD RD"	"Verree Rd & Pine Hill Rd - MBNS"	674.39
"4435 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	674.28
"503 STRAHLE ST"	"Rhawn St & Ridgeway St"	673.80
"9705 LOCHWOOD RD"	"Verree Rd & Pine Hill Rd - MBNS"	673.46
"742 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	673.33
"4463 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	673.24
"507 LANTERN LN"	"Ridge Av & Manatawna Av"	673.21
"1003 LIVEZEY LN"	"Henry Av & Livezey Ln"	673.20
"15213 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	673.13
"7245 ORWELL RD"	"Sedgwick St & Wayne Av Loop"	672.84
"15163 ENDICOTT ST"	"Southampton Rd & Endicott St"	672.36
"505 STRAHLE ST"	"Rhawn St & Ridgeway St"	672.24
"516 ARNOLD ST"	"Verree Rd & Strahle St "	671.85
"7884 NIXON ST"	"Oak Hill Apartments Loop"	671.76
"362 FLAMINGO ST"	"Domino Ln & Fowler St"	671.76
"15042 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	671.75
"4219 ARAMINGO AVE"	"Butler St & Aramingo Av - FS"	671.74
"508 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	671.12
"507 ARNOLD ST"	"Verree Rd & Strahle St "	670.84
"507 STRAHLE ST"	"Rhawn St & Ridgeway St"	670.73
"15162 ENDICOTT ST"	"Southampton Rd & Endicott St"	670.63
"500 SPRING LN"	"Ridge Av & Cathedral Rd - FS"	670.57
"9711 LOCHWOOD RD"	"Bustleton Av & Bowler St"	670.46
"15153 MILFORD ST"	"Southampton Rd & Carter Rd"	670.31
"504 SUSQUEHANNA RD"	"Verree Rd & Susquehanna Rd "	669.60
"815 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	669.55
"3119 MAUREEN DR"	"Medford Rd & Lester Rd"	669.46
"505 BERGEN ST"	"Verree Rd & Susquehanna Rd "	669.41
"509 STRAHLE ST"	"Verree Rd & Strahle St "	669.17
"8109 SAINT MARTINS LN"	"Germantown Av & Willow Grove Av"	669.14
"8700 SEMINOLE AVE"	"Germantown Av & Chestnut Hill Av"	669.12
"105 MOREDUN AVE"	"Darlington Rd & Alburger Av "	669.09
"7006 CITY AVE"	"Haverford Av & Sherwood Rd - FS"	669.08
"15215 BERNITA DR"	"Southampton Rd & Edison Av"	669.07
"402 W MORELAND AVE"	"Germantown Av & Mermaid Ln"	669.07
"506R-10 LANTERN LN"	"Ridge Av & Caledonia St - MBFS"	668.78
"4434 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	668.75
"15043 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	668.73
"331R W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	668.71
"15218 BERNITA DR"	"Southampton Rd & Edison Av"	668.45
"4433 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	668.37
"960 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	668.19
"1050 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	668.08
"4465 ERNIE DAVIS CIR"	"Bristol Pk & Gravel Pk - MBFS"	668.07
"7504 LAWN ST"	"Domino Ln & Fowler St"	668.01
"515 CLOISTER CIR"	"Ridge Av & Cathedral Rd - FS"	667.63
"7516 NEWLAND ST"	"Domino Ln & Fowler St"	667.54
"9713 LOCHWOOD RD"	"Bustleton Av & Bowler St"	667.50
"8702 SEMINOLE AVE"	"Germantown Av & Chestnut Hill Av"	667.47
"3113 MAUREEN DR"	"Medford Rd & Lester Rd"	667.31
"404 W MERMAID LN"	"Germantown Av & Roumfort Rd"	667.20
"3102 MAUREEN DR"	"Medford Rd & Lester Rd"	667.03
"15152 MILFORD ST"	"Southampton Rd & Endicott St"	666.94
"961 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	666.78
"201 MOREDUN AVE"	"Darlington Rd & Alburger Av "	666.69
"15033 LIBERTY LN"	"Southampton Rd & London Rd"	666.34
"15032 LIBERTY LN"	"Southampton Rd & London Rd"	666.30
"504 KENDRICK ST"	"Verree Rd & Kendrick St "	666.25
"10 SUMMIT PL"	"Henry Av & Summit Av"	666.19
"11744 TELFAIR RD"	"Knights Rd & Patrician Dr "	666.17
"514 GREENHILL LN"	"Ridge Av & Manatawna Av"	665.98
"15223 BERNITA DR"	"Somerton Rd & Trevose Rd - 2"	665.87
"15222 WAYSIDE RD"	"Somerton Rd & Trevose Rd - 2"	665.17
"7660 SAINT MARTINS LN"	"Germantown Av & Roumfort Rd"	665.09
"7516 SHAW ST"	"Domino Ln & Fowler St - MBFS"	664.96
"15161 ENDICOTT ST"	"Southampton Rd & Endicott St"	664.89
"119 BLOOMFIELD AVE"	"Verree Rd & Bloomfield Av "	664.89
"3105 MAUREEN DR"	"Medford Rd & Lester Rd"	664.83
"399 DEARNLEY ST"	"Ridge Av & Wigard Av "	664.76
"7654 SAINT MARTINS LN"	"Germantown Av & Roumfort Rd"	664.72
"517 GREENHILL LN"	"Ridge Av & Spring  Ln"	663.81
"15152 CARTER RD"	"Southampton Rd & Carter Rd"	663.77
"7250 ORWELL RD"	"Henry Av & Gates St"	663.73
"6 SHAWMONT AVE"	"Oak Hill Apartments Loop"	663.63
"15160 ENDICOTT ST"	"Southampton Rd & Endicott St"	663.54
"8005 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	663.45
"8216 SEMINOLE AVE"	"Germantown Av & Abington Av "	663.35
"518 ARNOLD ST"	"Verree Rd & Strahle St "	663.30
"954 CALEDONIA ST"	"Grakyn Ln & Wissahickon Av - FS"	663.21
"4431 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	663.15
"516 CLOISTER CIR"	"Ridge Av & Cathedral Rd - FS"	663.14
"4410 GREENMOUNT RD"	"Knights Rd & Patrician Dr "	663.00
"509 ARNOLD ST"	"Verree Rd & Strahle St "	662.46
"3700 MOORE ST"	"Grays Av & 51st St"	662.41
"3121 MAUREEN DR"	"Medford Rd & Lester Rd"	662.37
"801 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	662.18
"777 W ALLENS LN"	"Sedgwick St & Wayne Av Loop"	661.90
"15151 MILFORD ST"	"Southampton Rd & Carter Rd"	661.80
"15040 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	661.45
"506 SUSQUEHANNA RD"	"Verree Rd & Susquehanna Rd "	661.31
"511 STRAHLE ST"	"Verree Rd & Strahle St "	661.25
"7511-13 LAWN ST"	"Domino Ln & Fowler St"	661.09
"3100 HEDLEY ST"	"Delaware Av & Wheatsheaf Ln"	660.76
"326 W WILLOW GROVE AVE"	"Germantown Av & Springfield Av "	660.64
"505 RIDGERUN LN"	"Verree Rd & Susquehanna Rd  - MBNS"	660.63
"220 SHAWMONT AVE"	"Ridge Av & Flamingo St "	660.60
"753 W ALLENS LN"	"Mt Pleasant Av & McCallum St "	660.57
"955 CALEDONIA ST"	"Grakyn Ln & Wissahickon Av - FS"	660.52
"655 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	660.52
"210 MOREDUN AVE"	"Verree Rd & Bloomfield Av "	659.88
"951 MANATAWNA AVE"	"Grakyn Ln & Wissahickon Av - FS"	659.79
"631R SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	659.73
"507 BERGEN ST"	"Verree Rd & Susquehanna Rd "	659.47
"15223 WAYSIDE RD"	"Somerton Rd & Trevose Rd - MBNS"	659.45
"9715 LOCHWOOD RD"	"Bustleton Av & President St"	659.05
"1031 W ALLENS LN"	"Henry Av & Livezey Ln"	658.80
"3 MOREDUN PL"	"Darlington Rd & Alburger Av "	658.76
"8101 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	658.75
"4 MOREDUN PL"	"Darlington Rd & Alburger Av "	658.73
"516 GREENHILL LN"	"Ridge Av & Manatawna Av"	658.72
"6929 GREENHILL RD"	"Lankenau Medical Center"	658.46
"329R W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	658.46
"3111 MAUREEN DR"	"Medford Rd & Lester Rd"	658.26
"11725-37 TELFAIR RD"	"Knights Rd & Dorchester Rd - MBFS"	658.25
"15150 MILFORD ST"	"Southampton Rd & Endicott St"	658.17
"506 KENDRICK ST"	"Verree Rd & Kendrick St "	657.71
"15159 ENDICOTT ST"	"Southampton Rd & Endicott St"	657.68
"4429 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	657.67
"509 LANTERN LN"	"Ridge Av & Manatawna Av"	657.47
"7514 NEWLAND ST"	"Domino Ln & Fowler St"	657.14
"4408 GREENMOUNT RD"	"Knights Rd & Patrician Dr "	656.64
"15031 LIBERTY LN"	"Southampton Rd & London Rd"	656.48
"15212 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	656.40
"368 FLAMINGO ST"	"Ridge Av & Wigard Av "	656.37
"410 W CHESTNUT HILL AVE"	"Germantown Av & Laughlin Ln "	656.36
"10620 LOCKART RD"	"Sandmeyer Ln & 10090"	656.29
"8003 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	656.29
"15158 ENDICOTT ST"	"Southampton Rd & Endicott St"	656.23
"15041 POQUESSING CREEK LN"	"Southampton Rd & Endicott St"	656.08
"3770 GLENN ST"	"Morrell Av & Prince Cir "	656.01
"331 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	655.45
"15030 LIBERTY LN"	"Southampton Rd & London Rd"	655.32
"15150 CARTER RD"	"Southampton Rd & Carter Rd"	655.32
"15211 WAYSIDE RD"	"Southampton Rd & Theresa Dr"	654.83
"7264 ALLENS PL"	"Sedgwick St & Wayne Av Loop"	654.62
"520 ARNOLD ST"	"Verree Rd & Strahle St "	654.59
"115 BLOOMFIELD AVE"	"Verree Rd & Bloomfield Av "	654.24
"9706 WALLEY AVE"	"Bustleton Av & Bowler St"	654.07
"338 W SPRINGFIELD AVE"	"Germantown Av & Moreland Av "	653.97
"15226 BERNITA DR"	"Somerton Rd & Trevose Rd - 2"	653.85
"511 ARNOLD ST"	"Verree Rd & Strahle St "	653.77
"8325 PINE RD"	"Rhawn St & Jeanes St"	653.73
"512 LANTERN LN"	"Ridge Av & Caledonia St - MBFS"	653.43
"511 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd  - MBNS"	653.40
"340 WIGARD AVE"	"Domino Ln & Fowler St - MBFS"	653.32
"508 SUSQUEHANNA RD"	"Verree Rd & Susquehanna Rd "	653.15
"10622 LOCKART RD"	"Sandmeyer Ln & 10090"	653.04
"513 STRAHLE ST"	"Verree Rd & Strahle St "	653.00
"401 DEARNLEY ST"	"Ridge Av & Wigard Av "	652.87
"11742 TELFAIR RD"	"Knights Rd & Patrician Dr "	652.82
"6918 CITY AVE"	"Lankenau Medical Center"	652.49
"7243 ORWELL RD"	"Sedgwick St & Wayne Av Loop"	652.49
"15216 BERNITA DR"	"Southampton Rd & Edison Av"	652.40
"4427 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	652.26
"740 SAINT GEORGES RD"	"Mt Pleasant Av & McCallum St "	652.25
"3100 MAUREEN DR"	"Townsend Rd & Natl Archives -opp entrance"	652.07
"15149 MILFORD ST"	"Southampton Rd & Carter Rd"	651.74
"15038 POQUESSING CREEK LN"	"Southampton Rd & London Rd"	651.70
"7502 LAWN ST"	"Domino Ln & Fowler St"	651.61
"15213 BERNITA DR"	"Southampton Rd & Edison Av"	651.51
"11740 TELFAIR RD"	"Knights Rd & Patrician Dr "	650.86
"4406 GREENMOUNT RD"	"Knights Rd & Patrician Dr "	650.84
"8515 SEMINOLE AVE"	"Germantown Av & Evergreen Av"	650.71
"3123 MAUREEN DR"	"Medford Rd & Lester Rd"	650.66
"509 BERGEN ST"	"Verree Rd & Susquehanna Rd "	650.63
"7750 MINGO AVE"	"Holstein Av & 78th St"	650.46
"8332 JEANES ST"	"Rhawn St & Jeanes St"	650.39
"8212 SEMINOLE AVE"	"Germantown Av & Abington Av "	650.24
"15157 ENDICOTT ST"	"Southampton Rd & Endicott St"	649.93
"10624 LOCKART RD"	"Sandmeyer Ln & 10090"	649.91
"10618 LOCKART RD"	"Gantry Rd & Red Lion Rd"	649.71
"7012 CITY AVE"	"Haverford Av & City Av"	649.67
"15148 MILFORD ST"	"Southampton Rd & Endicott St"	649.53
"508 KENDRICK ST"	"Verree Rd & Kendrick St "	649.22
"3109 MAUREEN DR"	"Medford Rd & Lester Rd"	649.01
"11738 TELFAIR RD"	"Knights Rd & Patrician Dr "	648.95
"15156 ENDICOTT ST"	"Southampton Rd & Endicott St"	648.76
"519 CLOISTER CIR"	"Ridge Av & Cathedral Rd - FS"	648.19
"4350 WOODHAVEN RD"	"Philadelphia Mills & Marshalls"	648.19
"9717 LOCHWOOD RD"	"Bustleton Av & President St"	647.97
"958 CLYDE LN"	"Grakyn Ln & Wissahickon Av - FS"	647.77
"4432 ERNIE DAVIS CIR"	"Knights Rd & Lancelot Pl - MBFS"	647.56
"7909 SAINT MARTINS LN"	"Germantown Av & Moreland Av "	647.31
"8001 SAINT MARTINS LN"	"Germantown Av & Springfield Av "	647.19
"9708 WALLEY AVE"	"Bustleton Av & Bowler St"	647.17
"11736 TELFAIR RD"	"Knights Rd & Patrician Dr "	647.09
"7512 NEWLAND ST"	"Domino Ln & Fowler St"	646.81
"8349 JEANES ST"	"Rhawn St & Ridgeway St"	646.79
"10626 LOCKART RD"	"Sandmeyer Ln & 10090"	646.77
"519 GREENHILL LN"	"Ridge Av & Spring  Ln"	646.75
"15148 CARTER RD"	"Southampton Rd & Carter Rd"	646.74
"4425 ERNIE DAVIS CIR"	"Philadelphia Mills & Marshalls"	646.72
"510 PARKHOLLOW LN"	"Verree Rd & Susquehanna Rd "	646.53
"11707 STEVENS RD"	"Bustleton Av & Rennard St"	646.51
"952 CALEDONIA ST"	"Grakyn Ln & Wissahickon Av - FS"	646.36

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
"130"	"Bucks County Community College"	46505
"130"	"Bucks County Community College"	46505

5.  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.

    _NOTE: There is no automated test for this question, as there's no one right answer. With urban data analysis, this is frequently the case._

    Discuss your accessibility metric and how you arrived at it below:

    **Description:**

"OLNEY"	172	172	0	0	1.00	1
"BUSTLETON"	158	158	0	0	1.00	2
"OXFORD_CIRCLE"	139	139	0	0	1.00	3
"RHAWNHURST"	128	128	0	0	1.00	4
"WEST_OAK_LANE"	122	122	0	0	1.00	5
"STRAWBERRY_MANSION"	120	120	0	0	1.00	6
"RICHMOND"	109	109	0	0	1.00	7
"FISHTOWN"	108	108	0	0	1.00	8
"FOX_CHASE"	107	107	0	0	1.00	9
etc.

My accessibility metric calculates the ratio of wheelchair-accessible bus stops (wheelchair_boarding = 1) to total bus 
stops within each neighborhood. I used ST_Covers to assign each bus stop to its containing neighborhood. Neighborhoods 
are then ranked by this ratio, with ties broken by total stop count (more stops = better coverage). This metric 
captures both the proportion of stops that are accessible and rewards neighborhoods with greater overall transit coverage. 
A limitation is that stops with unknown accessibility (wheelchair_boarding = 0) are counted in the total but not as 
accessible, which may undercount accessibility in neighborhoods where data is missing.

6.  What are the _top five_ neighborhoods according to your accessibility metric?

"OLNEY"	172	172	0	0	1.00	1
"BUSTLETON"	158	158	0	0	1.00	2
"OXFORD_CIRCLE"	139	139	0	0	1.00	3
"RHAWNHURST"	128	128	0	0	1.00	4
"WEST_OAK_LANE"	122	122	0	0	1.00	5

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

"CEDAR_PARK"	40	20	20	0	0.50	154
"PASCHALL"	70	32	38	0	0.46	155
"SOUTHWEST_SCHUYLKILL"	53	23	30	0	0.43	156
"WOODLAND_TERRACE"	10	2	8	0	0.20	157
"BARTRAM_VILLAGE"	14	0	14	0	0.00	158

8.  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.

    **Structure (should be a single value):**
    ```sql
    (
        count_block_groups integer
    )
    ```

    **Discussion:**
    
0. I was really confused by this and I had to run it a not of times before I realized why I was getting 0. To define Penn’s “main campus,” I used the 
City of Philadelphia parcel dataset (phl.pwd_parcels) and selected parcels owned by the Trustees of the University of Pennsylvania using variations of 
the owner name in the owner1 field. I then used ST_Union to combine those parcels into a single campus geometry.

To answer the question, I used a spatial containment (ST_Within) to count census block groups from census.blockgroups_2020 that were fully contained 
within this campus geometry. The result was 0.

Although Penn’s campus occupies portions of several block groups (as confirmed using ST_Intersects), it does not completely contain any single block 
group. The campus boundary does not align with census boundaries, and block groups extend beyond university-owned parcels to include surrounding streets, 
private residences, and commercial properties.

Therefore, by saying “fully contains” using topological containment, Penn’s main campus does not fully contain any census block groups. I am not sure if
this was the answer that the question was asking neccessarily, but I think this is technically sound. 


9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed.

    **Structure (should be a single value):**
    ```sql
    (
        geo_id text
    )
    ```
421010369022

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

"90001"	"Cynwyd"	"759 meters SE of 4900 CITY AVE - Maybe grab a bottle of water for this trek"	-75.2316667	40.0066667
"90002"	"Bala"	"61 meters E of 4900 CITY AVE - A short stroll away"	-75.2277778	40.0011111
"90003"	"Wynnefield Avenue"	"19 meters NW of 2201 BRYN MAWR AVE in WYNNEFIELD - You’re almost there!"	-75.2255556	39.99
"90004"	"Gray 30th Street"	"33 meters S of 1 N 30TH ST in UNIVERSITY_CITY - A short stroll away"	-75.1816667	39.9566667
"90005"	"Suburban Station"	"9 meters SW of 1628-40 JOHN F KENNEDY BLVD in LOGAN_SQUARE - You’re almost there!"	-75.1677778	39.9538889
etc. 
