#!/bin/sh

# listen for remote connections
sed -i "/^#listen_addresses/i listen_addresses='*'" /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf

cat > /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf <<EOS
# Generated by dbconf.sh
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all         all                               trust

# local network connections
host    all         all         127.0.0.1/32          trust

# all remote connections from ips in docker's default netmask
host    all         all         172.17.0.0/16         trust
EOS