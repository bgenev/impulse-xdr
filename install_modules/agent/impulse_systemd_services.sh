#!/bin/bash


PROJECT_ROOT_DIR=$1
IP_HOST=$2
AGENT_TYPE=$3
OS_TYPE=$4


IMPULSE_MAIN_SERVICE="
[Unit]
Description=Impulse Agent Main Service 

[Service]
Type=simple
WorkingDirectory=/opt/impulse/agentd

ExecStart=/opt/impulse/tasks_manager/shell_scripts/agentd_service.sh start
ExecStop=/opt/impulse/tasks_manager/shell_scripts/agentd_service.sh stop

Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
"
echo "$IMPULSE_MAIN_SERVICE" > /etc/systemd/system/impulse-main.service


## Only for containerized rsyslog
# IMPULSE_CONTAINERS_SERVICE="
# [Unit]
# Description=Impulse Containers Main

# [Service]
# Type=simple
# WorkingDirectory=/opt/impulse
# ExecStart=/usr/local/bin/docker compose --file ./docker-compose-agent.yml --env-file ./impulse.conf up
# ExecStop=/usr/local/bin/docker compose --file ./docker-compose-agent.yml down
# Restart=on-failure
# RestartSec=15s

# [Install]
# WantedBy=multi-user.target
# "
# echo "$IMPULSE_CONTAINERS_SERVICE" > /etc/systemd/system/impulse-containers.service
##


if [[ $AGENT_TYPE == 'heavy' ]]; then
IMPULSE_NIDS_SERVICE="
[Unit]
Description=Impulse Containers Nids 

[Service]
Type=simple
WorkingDirectory=/opt/impulse
ExecStart=/opt/impulse/tasks_manager/shell_scripts/nids_service.sh start
ExecStop=/opt/impulse/tasks_manager/shell_scripts/nids_service.sh stop
Restart=on-failure
RestartSec=15s

[Install]
WantedBy=multi-user.target
"
echo "$IMPULSE_NIDS_SERVICE" > /etc/systemd/system/impulse-nids.service
else 
    echo "Not heavy, do not create impulse-nids service."
fi

systemctl daemon-reload



