#!/bin/bash

#
# Copyright (c) 2024, Bozhidar Genev,Impulse XDR. All Rights Reserved.    
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

set -e 

BUILD_START_TIME=$(date)
PROJECT_ROOT_DIR=$(pwd)

$PROJECT_ROOT_DIR/install_modules/shared/sudo_user_check.sh

$PROJECT_ROOT_DIR/install_modules/manager/syst_requirements_check_manager.sh

#$PROJECT_ROOT_DIR/install_modules/shared/move_project.sh $PROJECT_ROOT_DIR

OS_TYPE=$($PROJECT_ROOT_DIR/install_modules/shared/determine_os_distribution.sh) 
AGENT_OS_TYPE_VERBOSE=$($PROJECT_ROOT_DIR/install_modules/shared/determine_os_distribution.sh)

cd $PROJECT_ROOT_DIR

PACKAGE_MGR=$($PROJECT_ROOT_DIR/install_modules/shared/get_package_manager_type.sh)

FIREWALL_BACKEND=$($PROJECT_ROOT_DIR/install_modules/shared/get_firewall_type.sh $PACKAGE_MGR)

PYTH_USE_SYST_VER=$($PROJECT_ROOT_DIR/install_modules/shared/python_version_check.sh)

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

#$PROJECT_ROOT_DIR/install_modules/shared/check_docker_installed.sh $OS_TYPE

IP_MANAGER=$(awk -F "=" '/IP_MANAGER/ {print $2}' impulse.conf | tr -d ' ')
STATIC_IP_ADDR=$(awk -F "=" '/STATIC_IP_ADDR/ {print $2}' impulse.conf | tr -d ' ')
MANAGER_PROXY_IP=$(awk -F "=" '/MANAGER_PROXY_IP/ {print $2}' impulse.conf | tr -d ' ')
MANAGER_VM_INSTANCE_PUBLIC_IP=$(awk -F "=" '/MANAGER_VM_INSTANCE_PUBLIC_IP/ {print $2}' impulse.conf | tr -d ' ')

IMPULSE_DB_SERVER_PWD=$(awk -F "=" '/IMPULSE_DB_SERVER_PWD/ {print $2}' impulse.conf | tr -d ' ')
HOST_INTERFACE=$(awk -F "=" '/HOST_INTERFACE/ {print $2}' impulse.conf | tr -d ' ')
SETUP_TYPE=$(awk -F "=" '/SETUP_TYPE/ {print $2}' impulse.conf | tr -d ' ')
AGENT_TYPE=$(awk -F "=" '/AGENT_TYPE/ {print $2}' impulse.conf | tr -d ' ')
FIREWALL_BACKEND=$(awk -F "=" '/FIREWALL_BACKEND/ {print $2}' impulse.conf | tr -d ' ')
dot_replaced=$(echo "$IP_MANAGER" | tr . _)
IP_DASHES=$(echo "$IP_MANAGER" | tr . -)
DB_NAME_MANAGER=$dot_replaced"_db"
IP_HOST=$IP_MANAGER
AGENT_TAG_ID="manager-"$IP_DASHES

echo "OS_TYPE: "$OS_TYPE
echo "PACKAGE_MGR: "$PACKAGE_MGR
echo "FIREWALL_BACKEND: "$FIREWALL_BACKEND
echo "PYTH_USE_SYST_VER: "$PYTH_USE_SYST_VER
echo "SETUP_TYPE: "$SETUP_TYPE
echo "AGENT_TYPE: "$AGENT_TYPE

$PROJECT_ROOT_DIR/install_modules/manager/confirm_config.sh $IP_MANAGER $AGENT_TYPE $HOST_INTERFACE

$PROJECT_ROOT_DIR/install_modules/shared/update_syst.sh $OS_TYPE $PACKAGE_MGR

$PROJECT_ROOT_DIR/install_modules/shared/impulse_deps.sh $OS_TYPE $PYTH_USE_SYST_VER $SETUP_TYPE $AGENT_TYPE
cd $PROJECT_ROOT_DIR

mkdir -p /var/impulse
mkdir -p /var/impulse/etc
mkdir -p /var/impulse/etc/ssl
mkdir -p /var/impulse/etc/ssl/certs
mkdir -p /var/impulse/etc/ssl/private
mkdir -p /var/impulse/etc/grpc
mkdir -p /var/impulse/etc/grpc/tls
mkdir -p /var/impulse/etc/ansible
mkdir -p /var/impulse/etc/ansible/tls
mkdir -p /var/impulse/etc/suricata
mkdir -p /var/impulse/etc/nginx
mkdir -p /var/impulse/etc/rsyslog
mkdir -p /var/impulse/etc/rsyslog/ssl
mkdir -p /var/impulse/etc/rsyslog/rsyslog.d
mkdir -p /var/impulse/etc/osquery
mkdir -p /var/impulse/etc/osquery/packs
mkdir -p /var/impulse/etc/nftables

mkdir -p /var/impulse/log/suricata
mkdir -p /var/impulse/lib
mkdir -p /var/impulse/lib/suricata
mkdir -p /var/impulse/lib/suricata/rules
mkdir -p /var/impulse/data
mkdir -p /var/impulse/data/manager
mkdir -p /var/impulse/data/mysql
mkdir -p /var/impulse/data/cvedb
mkdir -p /var/impulse/data/rsyslog/spool
mkdir -p /var/impulse/data/quarantined_files
mkdir -p /var/impulse/data/policy_packs
mkdir -p /var/impulse/data/nft_ruleset

mkdir -p /var/log/impulse
mkdir -p /var/log/impulse

chown root:root /var/impulse/log/suricata
chmod 755 /var/impulse/log/suricata
chmod -R 755 /var/impulse/log/suricata
chmod 755 -R /var/log/impulse
chmod -R 755 /var/impulse
chown -R 755 /var/impulse

if [[ $AGENT_TYPE == 'heavy' ]]; then
	$PROJECT_ROOT_DIR/install_modules/shared/nids_provision.sh $PROJECT_ROOT_DIR $AGENT_TYPE $STATIC_IP_ADDR
else 
	echo "Continue.."
fi

echo "Creating TLS certificates..."
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -subj "/CN=localhost" -nodes -out /var/impulse/etc/ssl/certs/impulse.crt -keyout /var/impulse/etc/ssl/private/impulse.key

$PROJECT_ROOT_DIR/install_modules/manager/impulse_grpc_tls.sh $IP_MANAGER
cp /opt/impulse/build/grpc_tls_manager/ca-cert.pem /opt/impulse/build/agent/grpc/tls


cd $PROJECT_ROOT_DIR
cp ./build/nginx/impulse /var/impulse/etc/nginx/ 

echo "Setting up Rsyslog..."
$PROJECT_ROOT_DIR/install_modules/manager/impulse_rsyslog.sh $PROJECT_ROOT_DIR $AGENT_TYPE $DB_NAME_MANAGER $IP_HOST $IMPULSE_DB_SERVER_PWD $AGENT_TAG_ID
cp /var/impulse/etc/rsyslog/ssl/ca-cert.pem /opt/impulse/build/agent/tls/ca-cert.pem

cd $PROJECT_ROOT_DIR

$PROJECT_ROOT_DIR/install_modules/manager/impulse_manager_systemd.sh $PROJECT_ROOT_DIR $IP_HOST $AGENT_TYPE $OS_TYPE

systemctl start impulse-auxiliary.service
systemctl enable impulse-auxiliary.service

if [[ $AGENT_TYPE == 'heavy' ]]; then
    systemctl start impulse-nids.service
    systemctl enable impulse-nids.service
else 
    echo "Continue."
fi 

sudo docker compose --file ./docker-compose-manager.yml --env-file ./impulse.conf up --detach

sleep 10

systemctl start impulse-manager.service impulse-manager-grpc-server.service
systemctl enable impulse-manager.service impulse-manager-grpc-server.service

docker exec -it impulse-datastore psql --username=postgres -c 'CREATE DATABASE "'$DB_NAME_MANAGER'";'
docker exec -it impulse-datastore psql --username=postgres -c 'CREATE DATABASE "impulse_manager";'

docker exec -it impulse-datastore psql --username=postgres -c 'CREATE DATABASE "cvedb";'

## Manager main and aux 
$PROJECT_ROOT_DIR/install_modules/manager/impulse_aux.sh $PROJECT_ROOT_DIR

rm -rf $PROJECT_ROOT_DIR/managerd/migrations
docker exec -it impulse-managerd flask db init --multidb
docker exec -it impulse-managerd flask db migrate 
docker exec -it impulse-managerd flask db upgrade 

docker exec impulse-datastore pg_dump --schema-only -U postgres -d $DB_NAME_MANAGER > /opt/impulse/build/pgsql/agent_schema.sql

$PROJECT_ROOT_DIR/install_modules/shared/selinux_policy.sh $OS_TYPE

echo "Setting up cron tasks..."
$PROJECT_ROOT_DIR/install_modules/manager/impulse_crontab.sh $PROJECT_ROOT_DIR $AGENT_TYPE

echo "Task: OSquery setup ..."
$PROJECT_ROOT_DIR/install_modules/shared/osquery.sh $PROJECT_ROOT_DIR $OS_TYPE $PACKAGE_MGR

docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO osquery_packs (pack_name, pack_id, pack_version, pack_type) VALUES ('impulse_core_pack', '0001', '1', 'ioc')"

IP_HOST_INSERT="'"$IP_HOST"'"
docker exec -it impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO pack_deployments (asset_ip, pack_id, pack_version, pack_status_on_agent, deployment_status) VALUES("$IP_HOST_INSERT", '0001', '1', true, true);"

docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO suricata_custom_rulesets (ruleset_name, ruleset_latest_version) VALUES ('suricata_custom_rules', '1')"

public_id=$(dig +short myip.opendns.com @resolver1.opendns.com)

docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) SELECT ('"$public_id"') where not exists (SELECT ip_addr FROM whitelisted_ips WHERE ip_addr = '"$public_id"');"
docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) SELECT ('"$IP_MANAGER"') where not exists (SELECT ip_addr FROM whitelisted_ips WHERE ip_addr = '"$IP_MANAGER"');"

if [[ $MANAGER_PROXY_IP != '' ]]; then
	docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) VALUES ('"$MANAGER_PROXY_IP"')"
fi 

$PROJECT_ROOT_DIR/install_modules/shared/firewall.sh $SETUP_TYPE $IP_MANAGER $PACKAGE_MGR $OS_TYPE $FIREWALL_BACKEND


# Vulnerability Management
$PROJECT_ROOT_DIR/install_modules/manager/cvedb_vulns.sh


echo "Post-Installation Setup..."

curl -i -X POST -H "Content-Type: application/json" --data '{"ip_addr":"'"$IP_HOST"'","manager_database":"'"$DB_NAME_MANAGER"'"}' http://127.0.0.1:5020/local-endpoint/fleet/register-manager

curl -i -X POST -H "Content-Type: application/json" --data '{"ip_addr":"'"$IP_HOST"'","agent_db":"'"$DB_NAME_MANAGER"'","alias":"manager"}' http://127.0.0.1:5020/local-endpoint/fleet/set-active-database

curl -i -X POST -H "Content-Type: application/json" --data '{"os_type":"linux", "os_type_verbose":"'"$AGENT_OS_TYPE_VERBOSE"'", "manager_id": "'"$IP_HOST"'", "package_manager": "'"$PACKAGE_MGR"'", "manager_ip": "'"$IP_HOST"'"}' http://127.0.0.1:5020/local-endpoint/manager-init

echo "Generate admin password for web interface..."
WEB_INTERFACE_USERNAME="impulse"
WEB_INTERFACE_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

curl -i -X POST -H "Content-Type: application/json" --data '{"username":"'$WEB_INTERFACE_USERNAME'", "email": "admin@localhost", "name": "impulse", "password":"'$WEB_INTERFACE_PASSWORD'", "user_type":"admin"}' http://127.0.0.1:5020/api/register

## Whitelist client; all additional IPs used to ssh into the server or access the UI, must be whitelisted or they 
## will get blocked by the fleet firewall. To whitelist, go to /fleet/firewall -> Manage IP 



## Make sure the interface is accessible 
if [[ $PACKAGE_MGR = "deb" ]]; then
	ufw allow 7001/tcp
fi

if [[ $PACKAGE_MGR = "rpm" ]]; then
	firewall-cmd --permanent --add-port=7001/tcp
fi 


## Post-Install Tasks 
sleep 5
/usr/bin/wget http://127.0.0.1:5020/local-endpoint/set-default-whitelisted -O /dev/null

/opt/impulse/tasks_manager/cron_tasks/syst_posture_task.sh

sleep 10
/opt/impulse/tasks_manager/cron_tasks/sca_tests.sh

sleep 5
/opt/impulse/tasks_manager/cron_tasks/scan_installed_packages.sh


touch /var/impulse/data/manager/manager_creds.txt
chmod 600 /var/impulse/data/manager/manager_creds.txt
printf "username:"$WEB_INTERFACE_USERNAME >> /var/impulse/data/manager/manager_creds.txt
printf "\npassword:"$WEB_INTERFACE_PASSWORD"\n" >> /var/impulse/data/manager/manager_creds.txt

echo "WEB_INTERFACE_USERNAME:" 
echo $WEB_INTERFACE_USERNAME
echo "WEB_INTERFACE_PASSWORD:" 
echo $WEB_INTERFACE_PASSWORD

echo "" 
echo "User interface access:" 
echo "https://"$IP_MANAGER":7001/" 

echo "" 
echo "To stop, start or check manager status:" 
echo "/opt/impulse/impulse-control.sh stop/start/status" 


## Status
sleep 5
/opt/impulse/impulse-control.sh status

BUILD_END_TIME=$(date)
echo "START time build: "$BUILD_START_TIME
echo "END time build: "$BUILD_END_TIME


## reset change password: 
## curl -i -X POST -H "Content-Type: application/json" --data '{"username":"impulse","new_password":"pass1234"}' http://127.0.0.1:5020/local-endpoint/reset_password

