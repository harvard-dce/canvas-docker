#!/bin/bash
set -e

export POSTGRES_BIN=/usr/lib/postgresql/12/bin

sudo -u postgres $POSTGRES_BIN/createuser --superuser canvas
sudo -u postgres $POSTGRES_BIN/createdb -E UTF-8 -T template0 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 --owner canvas canvas_$RAILS_ENV
sudo -u postgres $POSTGRES_BIN/createdb -E UTF-8 -T template0 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 --owner canvas canvas_queue_$RAILS_ENV

export CANVAS_LMS_ADMIN_EMAIL="canvas@example.edu"
export CANVAS_LMS_ADMIN_PASSWORD="canvas-docker"
export CANVAS_LMS_ACCOUNT_NAME="Canvas Docker"
export CANVAS_LMS_STATS_COLLECTION="opt_out"

cd /opt/canvas/canvas-lms \
    && /opt/canvas/.gem/ruby/2.7.0/bin/bundle _2.2.19_ exec rake db:initial_setup

psql -U canvas -d canvas_development -c "INSERT INTO developer_keys (api_key, email, name, redirect_uri, root_account_id, access_token_count) VALUES ('test_developer_key', 'canvas@example.edu', 'Canvas Docker', 'http://localhost:8000', 1, 1);"

# 'crypted_token' value is hmac sha1 of 'canvas-docker' using default config/security.yml encryption_key value as secret
psql -U canvas -d canvas_development -c "INSERT INTO access_tokens (created_at, crypted_token, developer_key_id, purpose, token_hint, updated_at, user_id, root_account_id) SELECT now(), '4bb5b288bb301d3d4a691ebff686fc67ad49daa8', dk.id, 'canvas-docker', 'canva', now(), 1, 1 FROM developer_keys dk where dk.email = 'canvas@example.edu';"

psql -U canvas -d canvas_development -c "INSERT INTO developer_key_account_bindings (account_id, developer_key_id, workflow_state, created_at, root_account_id) SELECT 1, dk.id, 'on', now(), 1 FROM developer_keys dk where dk.email = 'canvas@example.edu';"
