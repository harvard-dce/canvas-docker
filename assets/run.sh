#!/bin/sh

cd /opt/canvas-lms \
    && bundle exec rake db:initial_setup \
    && foreman start -f Procfile.dev
