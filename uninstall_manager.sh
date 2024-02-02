#!/bin/bash

#
# Copyright (c) 2024, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

./impulse-control.sh stop

# stop and remove containers and images 
docker compose --file ./docker-compose-manager.yml down
docker compose --file ./docker-compose-nids.yml down



# purge osquery 
apt purge -y osquery

# stop and remove systemd services
systemctl stop impulse-manager impulse-auxiliary impulse-nids osquery
systemctl disable impulse-manager impulse-auxiliary impulse-bgtasks impulse-nids osquery

rm /etc/systemd/system/impulse-manager.service 
rm /etc/systemd/system/impulse-auxiliary.service
rm /etc/systemd/system/impulse-nids.service

docker rmi $(docker images -a -q)

# restart systemd
systemctl daemon-reload
systemctl reset-failed

# remove project folders and files 
rm -rf /var/impulse
rm -rf /var/log/impulse
rm -rf /var/log/impulse
rm -rf /etc/cron.d/impulse
rm -rf /var/osquery
rm -rf /var/log/osquery

# restart services affected by impulse 
systemctl restart cron 
systemctl restart docker

#deluser impulse_siem

nft flush table inet impulse_table