#!/bin/bash


IP_AGENT=$1
IP_MANAGER=$2
HOST_INTERFACE=$3 
AGENT_TYPE=$4
AGENT_ID=$5
AGENT_SECRET_KEY=$6
PACKAGE_MANAGER=$7


# FIREWALL_BACKEND=$7
# OS_TYPE=$8


NEW_AGENT_IP_HYPHENS=$(echo "$IP_AGENT" | tr . -)

NEW_AGENT_DIR_NAME='impulse-'$NEW_AGENT_IP_HYPHENS

NEW_AGENT_DIR_PATH='/tmp/'$NEW_AGENT_DIR_NAME'/impulse'


cp /var/impulse/etc/rsyslog/ssl/ca-cert.pem /opt/impulse/build/agent/tls/ca-cert.pem
rm -f '/opt/impulse/build/agent_build/agent-'$NEW_AGENT_IP_HYPHENS'.tar.gz'

rm -rf '/tmp/'$NEW_AGENT_DIR_NAME

mkdir -p $NEW_AGENT_DIR_PATH

cp -rf /opt/impulse/agent/* $NEW_AGENT_DIR_PATH



AGENT_IMPULSE_CONF='
[Env]
IP_AGENT='$IP_AGENT'
IP_MANAGER='$IP_MANAGER'
HOST_INTERFACE='$HOST_INTERFACE'
AGENT_TYPE='$AGENT_TYPE'
SETUP_TYPE=agent
NIDS_ENABLED=true
NIDS_MODE=IDS
IPS_SETUP=auto
IPS_MODE_PORTS=22,80
AGENT_ID='$AGENT_ID'
AGENT_SECRET_KEY='$AGENT_SECRET_KEY'

##################################################

# IP_AGENT: IP address of the monitored machine 
# IP_MANAGER: manager instance interface 
# AGENT_ID: id is provided by the manager on asset enrollment 
# SETUP_TYPE: agent or manager for the manager instance 
# NIDS_ENABLED: enable or disable NIDS capabilities. Only relevant if heavy agent.
# NIDS_MODE: IPS or IDS.
# IPS_SETUP: traffic forwarding to NFQ based on ports definition in impulse.conf or manual setup via iptables.
# IPS_MODE_PORTS: ports to monitor in IPS mode. 
# AGENT_TYPE: light - host ids and iocs capabilities, light + network ids capabilities. Suitable for assets open directly to the internet, e.g. gateway, bastion or standalone VPS instances not in cloud network. 
# AGENT_SECRET_KEY: provided by the manager on asset enrollment 
# HOST_INTERFACE: network interface of the monitored machine. " 
'

echo $AGENT_IMPULSE_CONF

# when new agent archive is created, pre-build should be done in custom /tmp/impulse-agent-ip-dir
# to avoid overlap

rm $NEW_AGENT_DIR_PATH/impulse.conf
echo "$AGENT_IMPULSE_CONF" > $NEW_AGENT_DIR_PATH"/impulse.conf"
#echo "$AGENT_IMPULSE_CONF" > "/tmp/impulse/impulse.conf"

rm -rf $NEW_AGENT_DIR_PATH/install_modules
rm -rf $NEW_AGENT_DIR_PATH/build 
rm -rf $NEW_AGENT_DIR_PATH/venv

mkdir $NEW_AGENT_DIR_PATH/install_modules
mkdir $NEW_AGENT_DIR_PATH/install_modules/agent
mkdir $NEW_AGENT_DIR_PATH/install_modules/shared

mkdir $NEW_AGENT_DIR_PATH/build 
mkdir $NEW_AGENT_DIR_PATH/build/agent
mkdir $NEW_AGENT_DIR_PATH/build/shared
mkdir -p $NEW_AGENT_DIR_PATH/agentd/main/helpers/shared

cp -rf /opt/impulse/install_modules/agent/* $NEW_AGENT_DIR_PATH/install_modules/agent
cp -rf /opt/impulse/install_modules/shared/* $NEW_AGENT_DIR_PATH/install_modules/shared

cp -rf /opt/impulse/build/agent/* $NEW_AGENT_DIR_PATH/build/agent
cp -rf /opt/impulse/build/shared/* $NEW_AGENT_DIR_PATH/build/shared

cp -rf /opt/impulse/managerd/main/helpers/shared/* $NEW_AGENT_DIR_PATH/agentd/main/helpers/shared/
cp -rf /opt/impulse/managerd/main/grpc_gateway/grpc_pb/* $NEW_AGENT_DIR_PATH/agentd/main/grpc_pb/

## pull via compose instead
# if [[ $AGENT_TYPE == 'heavy' ]]; then
#     cp -rf /opt/impulse/build/shared/docker/impulse_suricata_image.tar.gz $NEW_AGENT_DIR_PATH/build/shared/docker/
#     cp -rf /opt/impulse/build/shared/docker/impulse_zeek_image.tar.gz $NEW_AGENT_DIR_PATH/build/shared/docker/
# else 
#     echo "Light so not copying nids deps."
# fi

## Download instead 
# if [[ $PACKAGE_MANAGER == 'deb' ]]; 
# then
#     cp -rf /opt/impulse/build/shared/osquery/package_bin/osquery_5.8.2-1.linux_amd64.deb $NEW_AGENT_DIR_PATH/build/shared/osquery/package_bin/
# elif [[  $PACKAGE_MANAGER == 'rpm' ]]; then
#     cp -rf /opt/impulse/build/shared/osquery/package_bin/osquery-5.8.2-1.linux.x86_64.rpm $NEW_AGENT_DIR_PATH/build/shared/osquery/package_bin/
# else
# 	echo "No pkg manager specified. Exit"
# fi

### Generate GRPC TLS keys, signed by the Manager's CA
cd $NEW_AGENT_DIR_PATH
openssl req -newkey rsa:4096 -nodes -keyout server-key.pem -out server-req.pem -subj "/C=EU/ST=local/L=local/O=local/OU=localhost/CN=localhost/emailAddress=localhost"

printf "subjectAltName=IP:"$IP_AGENT > server-ext.cnf
openssl x509 -req -in server-req.pem -days 60 -CA /var/impulse/etc/grpc/tls/ca-cert.pem -CAkey /var/impulse/etc/grpc/tls/ca-key.pem -CAcreateserial -out server-cert.pem -extfile server-ext.cnf
mv server-key.pem $NEW_AGENT_DIR_PATH/build/agent/grpc/tls
mv server-cert.pem $NEW_AGENT_DIR_PATH/build/agent/grpc/tls
rm server-ext.cnf server-req.pem

## TODO: Ansible; copy ssh key for ansible hardening
# cp /var/impulse/etc/ansible/tls/id_rsa_impulse.pub /tmp/impulse/build/agent/ansible

tar czf '/opt/impulse/build/agent_build/agent-'$NEW_AGENT_IP_HYPHENS'.tar.gz' -C '/tmp/'$NEW_AGENT_DIR_NAME impulse

cd /tmp
rm -rf '/tmp/'$NEW_AGENT_DIR_NAME