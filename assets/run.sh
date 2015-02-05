#!/bin/sh

cd /opt/canvas-lms && bundle exec rake db:initial_setup
