#!/bin/bash


rm -rf /opt/impulse/build/deb_sec_tracker/*
wget https://security-tracker.debian.org/tracker/data/json -P /opt/impulse/build/deb_sec_tracker
mv /opt/impulse/build/deb_sec_tracker/json /opt/impulse/build/deb_sec_tracker/deb_sec_tracker.json

/usr/bin/wget http://127.0.0.1:5020/local-endpoint/gather-installed-packages -O /dev/null

sleep 12

/usr/bin/wget http://127.0.0.1:5020/local-endpoint/discover-cves -O /dev/null