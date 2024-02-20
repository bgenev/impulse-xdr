#!/bin/bash

wget https://github.com/bgenev/cve-db/releases/download/10-feb/cvedb.tar.gz -P /tmp

#cp /opt/impulse/build/cvedb/cvedb.tar.gz /tmp
cd /tmp 

tar xf /tmp/cvedb.tar.gz 

cat /tmp/cvedb.sql | docker exec -i impulse-datastore psql -U postgres -d cvedb

rm /tmp/cvedb.sql
rm /tmp/cvedb.tar.gz
