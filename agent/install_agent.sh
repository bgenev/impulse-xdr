#!/bin/bash

#
# Copyright (c) 2024, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

set -e 

BUILD_START_TIME=$(date)
PROJECT_ROOT_DIR=$(pwd)

$PROJECT_ROOT_DIR/install_modules/shared/sudo_user_check.sh


#$PROJECT_ROOT_DIR/install_modules/shared/move_project.sh $PROJECT_ROOT_DIR

OS_TYPE=$($PROJECT_ROOT_DIR/install_modules/shared/determine_os_distribution.sh) 
AGENT_OS_TYPE_VERBOSE=$($PROJECT_ROOT_DIR/install_modules/shared/determine_os_distribution.sh)
cd $PROJECT_ROOT_DIR

PACKAGE_MGR=$($PROJECT_ROOT_DIR/install_modules/shared/get_package_manager_type.sh)

FIREWALL_BACKEND=$($PROJECT_ROOT_DIR/install_modules/shared/get_firewall_type.sh $PACKAGE_MGR)

PYTH_USE_SYST_VER=$($PROJECT_ROOT_DIR/install_modules/shared/python_version_check.sh)


#AGENT_IP=$(awk -F "=" '/AGENT_IP/ {print $2}' impulse.conf | tr -d ' ')
AGENT_IP=$(awk -F "=" '/AGENT_ID/ {print $2}' impulse.conf | tr -d ' ')
STATIC_IP_ADDR=$(awk -F "=" '/STATIC_IP_ADDR/ {print $2}' impulse.conf | tr -d ' ')
HOST_INTERFACE=$(awk -F "=" '/HOST_INTERFACE/ {print $2}' impulse.conf | tr -d ' ')
IP_MANAGER=$(awk -F "=" '/IP_MANAGER/ {print $2}' impulse.conf | tr -d ' ')
AGENT_TYPE=$(awk -F "=" '/AGENT_TYPE/ {print $2}' impulse.conf | tr -d ' ')
SETUP_TYPE=$(awk -F "=" '/SETUP_TYPE/ {print $2}' impulse.conf | tr -d ' ')
AGENT_ID=$(awk -F "=" '/AGENT_ID/ {print $2}' impulse.conf | tr -d ' ')
dot_replaced=$(echo "$AGENT_IP" | tr . _)
IP_DASHES=$(echo "$AGENT_IP" | tr . -)
DB_NAME_MANAGER=$dot_replaced"_db"
IP_HOST=$AGENT_IP
AGENT_TAG_ID="agent-"$IP_DASHES

sed -i '/package_manager/c\    "package_manager": "'$PACKAGE_MGR'"' /opt/impulse/agentd/main/helpers/meta.json

echo "OS_TYPE: "$OS_TYPE
echo "PACKAGE_MGR: "$PACKAGE_MGR
echo "FIREWALL_BACKEND: "$FIREWALL_BACKEND
echo "PYTH_USE_SYST_VER: "$PYTH_USE_SYST_VER
echo "SETUP_TYPE: "$SETUP_TYPE
echo "AGENT_TYPE: "$AGENT_TYPE

$PROJECT_ROOT_DIR/install_modules/shared/supplied_config_values_check.sh $AGENT_IP $AGENT_TYPE $HOST_INTERFACE

if [ "$PYTH_USE_SYST_VER" == "false" ]; then
	# read -p "Your python3 version does not meet the minimal requirements. Should Impulse try to install python3.9 on your system (y/n)? " CONT
	# if [ "$CONT" = "y" ]; then
	# 	echo "Continue.."
	# elif [ "$CONT" = "n" ]; then
	# 	echo "Please install python3.8 or greater and pip >= 20.0.0.. and try again..";
	# 	exit 
	# else 
	# 	echo "Invalid option."
	# 	exit 
	# fi

	echo "Your Python version does not meet the minimal requirements. Minimum required 3.7. Exiting.."
	exit
else
	echo "Python version > 3.7. Continue.."
fi

## only if heavy
if [[ $AGENT_TYPE == 'heavy' ]]; then
	$PROJECT_ROOT_DIR/install_modules/shared/check_docker_installed.sh $OS_TYPE
fi 

$PROJECT_ROOT_DIR/install_modules/agent/syst_requirements_check_agent.sh $AGENT_TYPE
## skip checks
#$PROJECT_ROOT_DIR/install_modules/agent/confirm_config.sh $AGENT_IP $AGENT_TYPE $AGENT_ID $HOST_INTERFACE
$PROJECT_ROOT_DIR/install_modules/shared/update_syst.sh $OS_TYPE $PACKAGE_MGR

# Only install docker on manager or heavy sensor; 
$PROJECT_ROOT_DIR/install_modules/shared/impulse_deps.sh $OS_TYPE $PYTH_USE_SYST_VER $SETUP_TYPE $AGENT_TYPE

cd $PROJECT_ROOT_DIR 
#$PROJECT_ROOT_DIR/install_modules/agent/pip_venv.sh $PYTH_USE_SYST_VER
$PROJECT_ROOT_DIR/install_modules/shared/pip_venv.sh $PYTH_USE_SYST_VER


mkdir -p /opt
mkdir -p /var/impulse
mkdir -p /var/impulse/etc
mkdir -p /var/impulse/etc/ssl
mkdir -p /var/impulse/etc/ssl/certs
mkdir -p /var/impulse/etc/ssl/private
mkdir -p /var/impulse/etc/grpc
mkdir -p /var/impulse/etc/grpc/tls
mkdir -p /var/impulse/etc/nginx
mkdir -p /var/impulse/etc/nftables
mkdir -p /var/impulse/etc/rsyslog
mkdir -p /var/impulse/etc/rsyslog/ssl
mkdir -p /var/impulse/etc/rsyslog/rsyslog.d
mkdir -p /var/impulse/lib 
mkdir -p /var/impulse/data
mkdir -p /var/impulse/data/mysql
mkdir -p /var/impulse/data/rsyslog/spool
mkdir -p /var/impulse/data/quarantined_files
mkdir -p /var/log/impulse

## with system rsyslog
mkdir -p /etc/ssl/impulse
mkdir -p /etc/rsyslog.d/impulse

cp /opt/impulse/build/agent/meta/meta.json /opt/impulse/agentd/main/helpers/meta.json


if [[ $AGENT_TYPE == 'heavy' ]]; then
	mkdir -p /var/impulse/etc/suricata
	mkdir -p /var/impulse/log/suricata
	mkdir -p /var/impulse/lib/suricata
	mkdir -p /var/impulse/lib/suricata/rules

	chown root:root /var/impulse/log/suricata
	chmod 755 /var/impulse/log/suricata
	chmod -R 755 /var/impulse/log/suricata

	$PROJECT_ROOT_DIR/install_modules/shared/nids_provision.sh $PROJECT_ROOT_DIR $AGENT_TYPE $STATIC_IP_ADDR
else 
	echo "Continue.."
fi

echo "Creating TLS certificates..."
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -subj "/CN=localhost" -nodes -out /var/impulse/etc/ssl/certs/impulse.crt -keyout /var/impulse/etc/ssl/private/impulse.key 

$PROJECT_ROOT_DIR/install_modules/agent/impulse_systemd_services.sh $PROJECT_ROOT_DIR $IP_HOST $AGENT_TYPE $OS_TYPE

echo "Create Indexer templates..."
$PROJECT_ROOT_DIR/install_modules/agent/impulse_rsyslog.sh $PROJECT_ROOT_DIR $AGENT_TYPE $IP_MANAGER $AGENT_TAG_ID $PACKAGE_MGR


#mv $PROJECT_ROOT_DIR/build/agent/tls/ca-cert.pem /var/impulse/etc/rsyslog/ssl/ca-cert.pem
mv $PROJECT_ROOT_DIR/build/agent/tls/ca-cert.pem /etc/ssl/impulse/ca-cert.pem

## GRPC client key 
cp $PROJECT_ROOT_DIR/build/agent/grpc/tls/ca-cert.pem /var/impulse/etc/grpc/tls/ca-cert.pem

if [[ "$AGENT_TYPE" == *"$endpoint"* ]]; then
	echo "Endpoint..no crontab and firewall settings."
else 
	## Crontab 
	$PROJECT_ROOT_DIR/install_modules/agent/impulse_crontab.sh $PROJECT_ROOT_DIR $AGENT_TYPE
fi

## Firewall
$PROJECT_ROOT_DIR/install_modules/shared/firewall.sh $PACKAGE_MGR


cp /opt/impulse/build/agent/meta/meta.json /opt/impulse/agentd/main/helpers/meta.json


cd $PROJECT_ROOT_DIR
if [[ $AGENT_TYPE == 'heavy' ]]; then
	cp $PROJECT_ROOT_DIR/build/shared/docker/docker-compose-agent.yml $PROJECT_ROOT_DIR/docker-compose-agent.yml
	cp $PROJECT_ROOT_DIR/build/shared/docker/docker-compose-nids.yml $PROJECT_ROOT_DIR/docker-compose-nids.yml

	docker compose --file ./docker-compose-nids.yml --env-file ./impulse.conf up -d
	sleep 5 
	[ "$(docker ps -a | grep impulse-suricata)" ] && docker exec -it -d impulse-suricata suricata-update -f
	
	#[ "$(docker ps -a | grep impulse-suricata)" ] && docker exec -it -d --user suricata impulse-suricata suricata-update -f
	#docker exec -it -d --user suricata impulse-suricata suricata-update -f

	docker compose --file ./docker-compose-nids.yml --env-file ./impulse.conf down
else 
	cp $PROJECT_ROOT_DIR/build/shared/docker/docker-compose-agent.yml $PROJECT_ROOT_DIR/docker-compose-agent.yml
fi

$PROJECT_ROOT_DIR/install_modules/shared/selinux_policy.sh $OS_TYPE

echo "Task: OSquery setup ..."
$PROJECT_ROOT_DIR/install_modules/shared/osquery.sh $PROJECT_ROOT_DIR $OS_TYPE $PACKAGE_MGR 


systemctl enable impulse-agent-grpc-client.service

if [[ $AGENT_TYPE == 'heavy' ]]; then
	systemctl start impulse-nids.service
    systemctl enable impulse-nids.service
else 
    echo "Continue."
fi

systemctl start impulse-agent-grpc-client.service

BUILD_END_TIME=$(date)
echo "START time build: "$BUILD_START_TIME
echo "END time build: "$BUILD_END_TIME


/opt/impulse/impulse-control.sh status





################## Ansible #######################
# ## Impulse user 
# adduser impulse_siem --disabled-password --gecos ""
# adduser impulse_siem sudo

# mkdir /home/impulse_siem/.ssh
# touch /home/impulse_siem/.ssh/authorized_keys
# chmod 600 /home/impulse_siem/.ssh/authorized_keys
# chown impulse_siem:impulse_siem /home/impulse_siem/.ssh/authorized_keys
# cat /opt/impulse/build/agent/ansible/id_rsa_impulse.pub >> /home/impulse_siem/.ssh/authorized_keys
# cat /opt/impulse/build/agent/ansible/id_rsa_impulse.pub >> /home/vagrant/.ssh/authorized_keys
###################################################