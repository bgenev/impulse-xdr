#!/bin/bash

#
# Copyright (c) 2024, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

## Only run on agent - danger deleting /opt/impulse

cd /opt/impulse
./impulse-control.sh stop

docker compose --file ./docker-compose-agent.yml down
docker compose --file ./docker-compose-nids.yml down

apt purge -y osquery

systemctl stop impulse-main impulse-containers impulse-nids osquery
systemctl disable impulse-main impulse-containers impulse-nids osquery

rm /etc/systemd/system/impulse-agent-grpc-client.service 
rm /etc/systemd/system/impulse-containers.service
rm /etc/systemd/system/impulse-nids.service

docker rmi $(docker images -a -q)

# restart systemd
systemctl daemon-reload
systemctl reset-failed

# remove project folders and files 
rm -rf /var/impulse
rm -rf /var/log/impulse
rm /etc/cron.d/impulse
rm -rf /var/osquery
rm -rf /var/log/osquery
rm -rf /tmp/impulse
rm -rf /etc/osquery
rm -rf /usr/share/osquery


cd /opt 
rm -rf /opt/impulse

systemctl restart cron crond 

# deluser impulse_siem
# rm -rf /home/impulse_siem

# iptables -F
# iptables -X

# ufw disable 
# ufw -f reset
# ufw allow 22
# ufw -f enable

nft flush table inet impulse_table 
cd /opt
rm *agent-*


