-- Active: 1770745616986@@127.0.0.1@5433@assignment02

docker run -it \
  -e POSTGRES_PASSWORD=postgres\
  -v "C:/Users/antho/OneDrive/Documents/GitHub/MUSA 5090/pg-mount/assignment02:/app" \
  -p 5432:5432 \
   postgis/postgis:latest 

docker exec -it a313363c484b bash

