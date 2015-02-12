#!/bin/bash
set -e

# source our entrypoint vars
. /setenv.sh

export CANVAS_LMS_ADMIN_EMAIL=${CANVAS_LMS_ADMIN_EMAIL:-"canvas@example.edu"}
export CANVAS_LMS_ADMIN_PASSWORD=${CANVAS_LMS_ADMIN_PASSWORD:-"canvas"}
export CANVAS_LMS_ACCOUNT_NAME=${CANVAS_LMS_ACCOUNT_NAME:-"Canvas Dev"}
export CANVAS_LMS_STATS_COLLECTION=${CANVAS_LMS_STATS_COLLECTION:-"opt_out"}

if [ ! -d $POSTGRESQL_DATA ]; then
    mkdir -p $POSTGRESQL_DATA
    chown -R postgres:postgres $POSTGRESQL_DATA
    sudo -u postgres /usr/lib/postgresql/$POSTGRES_VERSION/bin/initdb -D $POSTGRESQL_DATA -E 'UTF-8' --lc-collate='en_US.UTF-8' --lc-ctype='en_US.UTF-8'
    ln -s /etc/ssl/certs/ssl-cert-snakeoil.pem $POSTGRESQL_DATA/server.crt
    ln -s /etc/ssl/private/ssl-cert-snakeoil.key $POSTGRESQL_DATA/server.key
fi

sudo -u postgres psql <<< "CREATE USER $DBUSER WITH SUPERUSER;"
sudo -u postgres psql <<< "ALTER USER $DBUSER WITH PASSWORD '$DBPASS';"
sudo -u postgres psql <<< "CREATE DATABASE canvas_$RAILS_ENV OWNER $DBUSER"
sudo -u postgres psql <<< "CREATE DATABASE canvas_queue_$RAILS_ENV OWNER $DBUSER"

cd /opt/canvas-lms \
    && bundle exec rake db:initial_setup

