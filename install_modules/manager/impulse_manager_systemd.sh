#!/bin/bash


PROJECT_ROOT_DIR=$1
IP_HOST=$2
AGENT_TYPE=$3
OS_TYPE=$4


IMPULSE_MANAGER_AUXILIARY="
[Unit]
Description=Impulse Auxiliary Service 

[Service]
Type=simple
WorkingDirectory=/opt/impulse/aux_server
ExecStart=/opt/impulse/aux_server/aux-venv/bin/python3 /opt/impulse/aux_server/aux-venv/bin/gunicorn -b 127.0.0.1:5021 --reload wsgi:app --timeout 900
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
"
echo "$IMPULSE_MANAGER_AUXILIARY" > /etc/systemd/system/impulse-auxiliary.service


IMPULSE_MANAGER_SERVICE="
[Unit]
Description=Impulse Manager Main Services

[Service]
Type=simple
WorkingDirectory=/opt/impulse

ExecStart=/opt/impulse/tasks_manager/shell_scripts/managerd_service.sh start
ExecStop=/opt/impulse/tasks_manager/shell_scripts/managerd_service.sh stop

Restart=on-failure
RestartSec=15s

[Install]
WantedBy=multi-user.target
"
echo "$IMPULSE_MANAGER_SERVICE" > /etc/systemd/system/impulse-manager.service

IMPULSE_NIDS_SERVICE="
[Unit]
Description=Impulse Manager NIDS Service

[Service]
Type=simple
WorkingDirectory=/opt/impulse
ExecStart=/usr/bin/docker compose --file ./docker-compose-nids.yml --env-file ./impulse.conf up
ExecStop=/usr/bin/docker compose --file ./docker-compose-nids.yml down 
Restart=on-failure
RestartSec=15s

[Install]
WantedBy=multi-user.target
"
echo "$IMPULSE_NIDS_SERVICE" > /etc/systemd/system/impulse-nids.service

systemctl daemon-reload

