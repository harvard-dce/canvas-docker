#!/bin/sh

gosu postgres postgres --single <<- EOSQL
    CREATE USER canvas;
    CREATE DATABASE canvas_development;
    CREATE DATABASE canvas_queue_development;
    GRANT ALL PRIVILEGES ON DATABASE canvas_development TO canvas;
    GRANT ALL PRIVILEGES ON DATABASE canvas_queue_development TO canvas;
EOSQL
