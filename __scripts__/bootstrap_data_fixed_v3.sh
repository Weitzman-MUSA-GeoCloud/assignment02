#!/bin/env bash

set -e
set -x

POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_NAME=${POSTGRES_NAME:-Assignment2}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASS=${POSTGRES_PASS:-030110}
PYTHON_COMMAND=${PYTHON_COMMAND:-python3}

SEPTA_GTFS_ZIP_URL='https://github.com/septadev/GTFS/releases/download/v202502230/gtfs_public.zip'
CENSUS_BLOCKGROUP_POP_URL='https://api.census.gov/data/2020/dec/pl?get=NAME,GEO_ID,P1_001N&for=block%20group:*&in=state:42%20county:*'
CENSUS_BLOCKGROUP_SHAPES_URL='https://www2.census.gov/geo/tiger/TIGER2020/BG/tl_2020_42_bg.zip'
PWD_PARCELS_URL='https://opendata.arcgis.com/api/v3/datasets/84baed491de44f539889f2af178ad85c_0/downloads/data?format=shp&spatialRefId=4326&where=1%3D1'
PHILA_NEIGHBORHOODS_URL='https://github.com/opendataphilly/open-geo-data/raw/refs/heads/master/philadelphia-neighborhoods/philadelphia-neighborhoods.geojson'

SCRIPTDIR=$(readlink -f $(dirname $0))
DATADIR=$(readlink -f $(dirname $0)/../__data__)
WIN_DATADIR=$(cygpath -m "${DATADIR}")
mkdir -p ${DATADIR}

# Download and unzip gtfs data
if [ ! -f ${DATADIR}/gtfs_public.zip ]; then
    echo "Downloading SEPTA GTFS data..."
    curl -L "${SEPTA_GTFS_ZIP_URL}" > ${DATADIR}/gtfs_public.zip
fi
unzip -o ${DATADIR}/gtfs_public.zip -d ${DATADIR}/gtfs_public
unzip -o ${DATADIR}/gtfs_public/google_bus.zip -d ${DATADIR}/google_bus
unzip -o ${DATADIR}/gtfs_public/google_rail.zip -d ${DATADIR}/google_rail

# Create a convenience function for running psql with DB credentials
function run_psql() {
  PGPASSWORD=${POSTGRES_PASS} psql \
  -h ${POSTGRES_HOST} \
  -p ${POSTGRES_PORT} \
  -U ${POSTGRES_USER} \
  -d ${POSTGRES_NAME} \
  "$@"
}

# Create a connection string for ogr2ogr
POSTGRES_CONNSTRING="host=${POSTGRES_HOST} port=${POSTGRES_PORT} dbname=${POSTGRES_NAME} user=${POSTGRES_USER} password=${POSTGRES_PASS}"

# Create database
PGPASSWORD=${POSTGRES_PASS} psql \
  -h ${POSTGRES_HOST} \
  -p ${POSTGRES_PORT} \
  -U ${POSTGRES_USER} \
  -c "CREATE DATABASE ${POSTGRES_NAME};" || echo "Database may already exist"

# Initialize table structure
run_psql -f "${SCRIPTDIR}/create_tables.sql"

# Load trip gtfs data into database
#sed -i 's/\r//g' ${DATADIR}/google_bus/stops.txt
#run_psql -c "\copy septa.bus_stops FROM '${DATADIR}/google_bus/stops.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' ${DATADIR}/google_bus/stops.txt
run_psql -c "\copy septa.bus_stops FROM '${WIN_DATADIR}/google_bus/stops.txt' DELIMITER ',' CSV HEADER;"



# Use sed to replace \r\n with \n in the google_bus/routes.txt file
#sed -i 's/\r//g' ${DATADIR}/google_bus/routes.txt
#run_psql -c "\copy septa.bus_routes FROM '${DATADIR}/google_bus/routes.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' ${DATADIR}/google_bus/routes.txt
run_psql -c "\copy septa.bus_routes FROM '${WIN_DATADIR}/google_bus/routes.txt' DELIMITER ',' CSV HEADER;"


#sed -i 's/\r//g' ${DATADIR}/google_bus/trips.txt
#run_psql -c "\copy septa.bus_trips FROM '${DATADIR}/google_bus/trips.txt' DELIMITER ',' CSV HEADER;"
sed -i 's/\r//g' ${DATADIR}/google_bus/trips.txt
run_psql -c "\copy septa.bus_trips FROM '${WIN_DATADIR}/google_bus/trips.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' ${DATADIR}/google_bus/shapes.txt
run_psql -c "\copy septa.bus_shapes FROM '${WIN_DATADIR}/google_bus/shapes.txt' DELIMITER ',' CSV HEADER;"
#sed -i 's/\r//g' ${DATADIR}/google_bus/shapes.txt
#run_psql -c "\copy septa.bus_shapes FROM '${DATADIR}/google_bus/shapes.txt' DELIMITER ',' CSV HEADER;"

sed -i 's/\r//g' ${DATADIR}/google_rail/stops.txt
run_psql -c "\copy septa.rail_stops FROM '${WIN_DATADIR}/google_rail/stops.txt' DELIMITER ',' CSV HEADER;"
#sed -i 's/\r//g' ${DATADIR}/google_rail/stops.txt
#run_psql -c "\copy septa.rail_stops FROM '${DATADIR}/google_rail/stops.txt' DELIMITER ',' CSV HEADER;"


# Download and unzip census population data (didn't find download url)
if [ ! -f ${WIN_DATADIR}/census_population_2020.json ]; then
    echo "Downloading census population data..."
    curl -L "${CENSUS_BLOCKGROUP_POP_URL}" > ${WIN_DATADIR}/census_population_2020.json
fi
# unzip -o ${DATADIR}/census_population.zip -d ${DATADIR}/census_population

# Convert the JSON population data into CSV
${PYTHON_COMMAND} <<EOF
import csv
import json
import pathlib

RAW_DATA_DIR = pathlib.Path('${WIN_DATADIR}')
PROCESSED_DATA_DIR = pathlib.Path('${WIN_DATADIR}')

with open(
    RAW_DATA_DIR / 'census_population_2020.json',
    'r', encoding='utf-8',
) as infile:
    data = json.load(infile)

print(f"Total rows in JSON: {len(data)}")
print(f"First row (header): {data[0]}")
print(f"Second row (sample data): {data[1] if len(data) > 1 else 'N/A'}")

with open(
    PROCESSED_DATA_DIR / 'census_population_2020.csv',
    'w', encoding='utf-8',
    newline='',  # Important for CSV on Windows
) as outfile:
    # Use QUOTE_ALL to quote all fields (handles commas in data)
    writer = csv.writer(outfile, quoting=csv.QUOTE_ALL)
    # Write header row - column names MUST match table definition
    # JSON structure: [NAME, GEO_ID, P1_001N, state, county, tract, block group]
    # We want: geoname (from NAME), geo_id (from GEO_ID), population (from P1_001N)
    writer.writerow(['geoname', 'geo_id', 'population'])
    
    # Write data rows, skip first row (it's the header in JSON)
    valid_rows = 0
    for row in data[1:]:  # Skip first row (header)
        # Check we have at least 3 elements and they're not empty
        if len(row) >= 3 and row[0] and row[1] and row[2]:
            # Write in order: NAME, GEO_ID, P1_001N
            writer.writerow((row[0], row[1], row[2]))
            valid_rows += 1
    
    print(f"Written {valid_rows} valid data rows to CSV")
EOF

# load data into database
#run_psql -c "\copy census.population_2020 FROM '${DATADIR}/census_population_2020.csv' DELIMITER ',' CSV HEADER;"
# load data into database
run_psql -c "\copy census.population_2020 FROM '${WIN_DATADIR}/census_population_2020.csv' DELIMITER ',' CSV HEADER;"

# Download and unzip PWD Stormwater Billing parcel data
if [ ! -f ${DATADIR}/phl_pwd_parcels.zip ]; then
    echo "Downloading PWD Stormwater Billing parcel data..."
    curl -L "${PWD_PARCELS_URL}" > ${DATADIR}/phl_pwd_parcels.zip
fi
unzip -o ${DATADIR}/phl_pwd_parcels.zip -d ${DATADIR}/phl_pwd_parcels




# Download philly neighborhood data
if [ ! -f ${DATADIR}/Neighborhoods_Philadelphia.geojson ]; then
    echo "Downloading Philadelphia neighborhood data..."
    curl -L "${PHILA_NEIGHBORHOODS_URL}" > ${DATADIR}/Neighborhoods_Philadelphia.geojson
fi

# load neighbourhoods data into database


# Download and unzip census data
if [ ! -f ${DATADIR}/census_blockgroups_2020.zip ]; then
    echo "Downloading census blockgroup geographical data for PA..."
    curl -L "${CENSUS_BLOCKGROUP_SHAPES_URL}" > ${DATADIR}/census_blockgroups_2020.zip
fi
unzip -o ${DATADIR}/census_blockgroups_2020.zip -d ${DATADIR}/census_blockgroups_2020

# Load census data into database
ogr2ogr \
    -f "PostgreSQL" \
    PG:"${POSTGRES_CONNSTRING}" \
    -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON \
    -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog \
    -lco GEOM_TYPE=GEOGRAPHY \
    -overwrite \
    "${DATADIR}/census_blockgroups_2020/tl_2020_42_bg.shp"



















