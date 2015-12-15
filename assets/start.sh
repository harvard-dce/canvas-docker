#!/bin/bash

set -e

sed -i "s/EMAIL_DELIVERY_METHOD/${EMAIL_DELIVERY_METHOD-test}/" /opt/canvas-lms/config/outgoing_mail.yml
sed -i "s/SMTP_ADDRESS/${SMTP_ADDRESS-localhost}/" /opt/canvas-lms/config/outgoing_mail.yml
sed -i "s/SMTP_PORT/${SMTP_PORT-25}/" /opt/canvas-lms/config/outgoing_mail.yml
sed -i "s/SMTP_USER/${SMTP_USER-}/" /opt/canvas-lms/config/outgoing_mail.yml
sed -i "s/SMTP_PASS/${SMTP_PASS-}/" /opt/canvas-lms/config/outgoing_mail.yml

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
