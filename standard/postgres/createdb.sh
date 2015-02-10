#!/bin/sh

gosu postgres postgres --single <<- EOSQL
    CREATE DATABASE canvas_development;
    CREATE DATABASE canvas_queue_development;
    GRANT ALL PRIVILEGES ON DATABASE canvas_development TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE canvas_queue_development TO postgres;
EOSQL
