#!/bin/bash
set -e

export POSTGRES_BIN=/usr/lib/postgresql/$POSTGRES_VERSION/bin

sudo -u postgres $POSTGRES_BIN/createuser --superuser canvas
sudo -u postgres $POSTGRES_BIN/createdb -E UTF-8 -T template0 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 --owner canvas canvas_$RAILS_ENV
sudo -u postgres $POSTGRES_BIN/createdb -E UTF-8 -T template0 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 --owner canvas canvas_queue_$RAILS_ENV

export CANVAS_LMS_ADMIN_EMAIL="canvas@example.edu"
export CANVAS_LMS_ADMIN_PASSWORD="canvas"
export CANVAS_LMS_ACCOUNT_NAME="Canvas Docker"
export CANVAS_LMS_STATS_COLLECTION="opt_out"

cd /opt/canvas/canvas-lms \
    && bundle exec rake db:initial_setup

#Todo: this might be useful to keep later
#psql -U canvas -d canvas_$RAILS_ENV -c "INSERT INTO developer_keys (api_key, email, name, redirect_uri, tool_id) VALUES ('test_developer_key', 'canvas@example.edu', 'DCE Course Admin', 'http://localhost:8000', 'canvas-docker');"

# 'crypted_token' value is hmac sha1 of 'canvas-docker' using default config/security.yml encryption_key value as secret
psql -U canvas -d canvas_$RAILS_ENV -c "INSERT INTO access_tokens (created_at, crypted_token, developer_key_id, purpose, token_hint, updated_at, user_id) VALUES ('2015-07-01 19:33:37.596812', '4bb5b288bb301d3d4a691ebff686fc67ad49daa8', 1, 'canvas-docker', '', '2015-07-01 19:33:37.596812', 1);"

