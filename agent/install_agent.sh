#!/bin/bash

#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
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


IP_AGENT=$(awk -F "=" '/IP_AGENT/ {print $2}' impulse.conf | tr -d ' ')
HOST_INTERFACE=$(awk -F "=" '/HOST_INTERFACE/ {print $2}' impulse.conf | tr -d ' ')
IP_MANAGER=$(awk -F "=" '/IP_MANAGER/ {print $2}' impulse.conf | tr -d ' ')
AGENT_TYPE=$(awk -F "=" '/AGENT_TYPE/ {print $2}' impulse.conf | tr -d ' ')
SETUP_TYPE=$(awk -F "=" '/SETUP_TYPE/ {print $2}' impulse.conf | tr -d ' ')
AGENT_ID=$(awk -F "=" '/AGENT_ID/ {print $2}' impulse.conf | tr -d ' ')
dot_replaced=$(echo "$IP_AGENT" | tr . _)
IP_DASHES=$(echo "$IP_AGENT" | tr . -)
DB_NAME_MANAGER=$dot_replaced"_db"
IP_HOST=$IP_AGENT
AGENT_TAG_ID="agent-"$IP_DASHES

echo "OS_TYPE: "$OS_TYPE
echo "PACKAGE_MGR: "$PACKAGE_MGR
echo "FIREWALL_BACKEND: "$FIREWALL_BACKEND
echo "PYTH_USE_SYST_VER: "$PYTH_USE_SYST_VER
echo "SETUP_TYPE: "$SETUP_TYPE
echo "AGENT_TYPE: "$AGENT_TYPE

$PROJECT_ROOT_DIR/install_modules/shared/supplied_config_values_check.sh $IP_AGENT $AGENT_TYPE $HOST_INTERFACE

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

$PROJECT_ROOT_DIR/install_modules/shared/check_docker_installed.sh $OS_TYPE

$PROJECT_ROOT_DIR/install_modules/agent/syst_requirements_check_agent.sh $AGENT_TYPE
## skip checks
#$PROJECT_ROOT_DIR/install_modules/agent/confirm_config.sh $IP_AGENT $AGENT_TYPE $AGENT_ID $HOST_INTERFACE
$PROJECT_ROOT_DIR/install_modules/shared/update_syst.sh $OS_TYPE $PACKAGE_MGR
$PROJECT_ROOT_DIR/install_modules/shared/impulse_deps.sh $OS_TYPE $PYTH_USE_SYST_VER $PACKAGE_MGR
cd $PROJECT_ROOT_DIR 
#$PROJECT_ROOT_DIR/install_modules/agent/pip_venv.sh $PYTH_USE_SYST_VER
$PROJECT_ROOT_DIR/install_modules/shared/pip_venv.sh $PYTH_USE_SYST_VER


mkdir -p /opt
mkdir -p /var/impulse
mkdir -p /var/impulse/etc
mkdir -p /var/impulse/etc/ssl
mkdir -p /var/impulse/etc/ssl/certs
mkdir -p /var/impulse/etc/ssl/private
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

if [[ $AGENT_TYPE == 'heavy' ]]; then
	mkdir -p /var/impulse/etc/suricata
	mkdir -p /var/impulse/log/suricata
	mkdir -p /var/impulse/lib/suricata
	mkdir -p /var/impulse/lib/suricata/rules

	chown root:root /var/impulse/log/suricata
	chmod 755 /var/impulse/log/suricata
	chmod -R 755 /var/impulse/log/suricata

	$PROJECT_ROOT_DIR/install_modules/shared/nids_provision.sh $PROJECT_ROOT_DIR $AGENT_TYPE $IP_HOST
else 
	echo "Continue.."
fi

echo "Creating TLS certificates..."
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -subj "/CN=localhost" -nodes -out /var/impulse/etc/ssl/certs/impulse.crt -keyout /var/impulse/etc/ssl/private/impulse.key 

$PROJECT_ROOT_DIR/install_modules/agent/impulse_systemd_services.sh $PROJECT_ROOT_DIR $IP_HOST $AGENT_TYPE $OS_TYPE

echo "Create Indexer templates..."
$PROJECT_ROOT_DIR/install_modules/agent/impulse_rsyslog.sh $PROJECT_ROOT_DIR $AGENT_TYPE $IP_MANAGER $AGENT_TAG_ID

mv $PROJECT_ROOT_DIR/build/agent/tls/ca-cert.pem /var/impulse/etc/rsyslog/ssl/ca-cert.pem

cd $PROJECT_ROOT_DIR
if [[ $AGENT_TYPE == 'heavy' ]]; then
	cp $PROJECT_ROOT_DIR/build/shared/docker/docker-compose-agent.yml $PROJECT_ROOT_DIR/docker-compose-agent.yml
	cp $PROJECT_ROOT_DIR/build/shared/docker/docker-compose-nids.yml $PROJECT_ROOT_DIR/docker-compose-nids.yml

	/usr/local/bin/docker-compose --file ./docker-compose-nids.yml --env-file ./impulse.conf up -d
	sleep 5 
	[ "$(docker ps -a | grep impulse-suricata)" ] && docker exec -it -d impulse-suricata suricata-update -f
	
	#[ "$(docker ps -a | grep impulse-suricata)" ] && docker exec -it -d --user suricata impulse-suricata suricata-update -f
	#docker exec -it -d --user suricata impulse-suricata suricata-update -f

	/usr/local/bin/docker-compose --file ./docker-compose-nids.yml --env-file ./impulse.conf down
else 
	cp $PROJECT_ROOT_DIR/build/shared/docker/docker-compose-agent.yml $PROJECT_ROOT_DIR/docker-compose-agent.yml
fi

#docker load --input /opt/impulse/build/shared/rsyslog-image/impulse_rsyslog_image.tar

$PROJECT_ROOT_DIR/install_modules/shared/selinux_policy.sh $OS_TYPE

echo "Task: OSquery setup ..."
$PROJECT_ROOT_DIR/install_modules/shared/osquery.sh $PROJECT_ROOT_DIR $OS_TYPE $PACKAGE_MGR 


## Crontab 
$PROJECT_ROOT_DIR/install_modules/agent/impulse_crontab.sh $PROJECT_ROOT_DIR $AGENT_TYPE



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


$PROJECT_ROOT_DIR/install_modules/shared/firewall.sh $SETUP_TYPE $IP_MANAGER $PACKAGE_MGR $OS_TYPE $FIREWALL_BACKEND

systemctl enable impulse-main.service
systemctl enable impulse-containers.service
if [[ $AGENT_TYPE == 'heavy' ]]; then
	systemctl start impulse-nids.service
    systemctl enable impulse-nids.service
else 
    echo "Continue."
fi

systemctl restart impulse-main.service
systemctl restart impulse-containers.service

##  provision via build 
# if [[ $AGENT_TYPE == 'heavy' ]]; then
# 	docker exec -it -d --user suricata impulse-suricata suricata-update -f
# else 
#     echo "Continue."
# fi

sleep 2
/opt/impulse/impulse-control.sh status

BUILD_END_TIME=$(date)
echo "START time build: "$BUILD_START_TIME
echo "END time build: "$BUILD_END_TIME
