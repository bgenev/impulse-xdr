#!/bin/bash


rm -rf /opt/impulse/build/deb_sec_tracker/*
wget https://security-tracker.debian.org/tracker/data/json -P /opt/impulse/build/deb_sec_tracker
mv /opt/impulse/build/deb_sec_tracker/json /opt/impulse/build/deb_sec_tracker/deb_sec_tracker.json

/usr/bin/wget http://127.0.0.1:5020/local-endpoint/scan-installed-pkgs -O /dev/null
/usr/bin/wget http://127.0.0.1:5020/local-endpoint/update-pkgs-cves-map -O /dev/null