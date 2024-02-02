#!/bin/bash


PROJECT_ROOT_DIR=$1
IP_HOST=$2
AGENT_TYPE=$3
OS_TYPE=$4


GRPC_CLIENT_SERVICE="
[Unit]
Description=Impulse Sensor GRPC Client Service 

[Service]
Type=simple
WorkingDirectory=/opt/impulse/agentd

ExecStart=/opt/impulse/venv/bin/python3 /opt/impulse/agentd/sensor_grpc_client.py

Restart=always
RestartSec=20s

[Install]
WantedBy=multi-user.target
"
echo "$GRPC_CLIENT_SERVICE" > /etc/systemd/system/impulse-agent-grpc-client.service


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