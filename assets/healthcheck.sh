#!/bin/bash

STATUS=$(/usr/bin/curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000")
if [ "$STATUS" == "500" ]
then
  /usr/bin/supervisorctl restart canvas_web
fi
