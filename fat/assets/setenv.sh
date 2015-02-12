#!/bin/bash

export RAILS_ENV=${RAILS_ENV:-"development"}
export DBUSER=${DBUSER:-"canvas"}
export DBPASS=${DBPASS:-"canvas"}
export POSTGRESQL_DATA=${POSTGRESQL_DATA:-"/var/lib/postgresql/$POSTGRES_VERSION/main"}

eval "$@"
