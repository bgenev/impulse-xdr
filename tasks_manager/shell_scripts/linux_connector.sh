#!/bin/bash


AGENT_IP=$1
IP_MANAGER=$2
HOST_INTERFACE=$3 
AGENT_TYPE=$4
AGENT_ID=$5
AGENT_SECRET_KEY=$6
PACKAGE_MANAGER=$7
STATIC_IP_ADDR=$8

#############################################################################################################
NEW_AGENT_IP_HYPHENS=$(echo "$AGENT_IP" | tr . -)
dot_replaced=$(echo "$AGENT_IP" | tr . _)
NEW_AGENT_DB=$dot_replaced"_db"

/usr/bin/docker exec -i impulse-datastore psql --username=postgres -c 'CREATE DATABASE "'$NEW_AGENT_DB'";'
cat /opt/impulse/build/pgsql/agent_schema.sql | docker exec -i impulse-datastore psql -U postgres -d $NEW_AGENT_DB

# Export schema only 
# docker exec impulse-datastore pg_dump --schema-only -U postgres -d 192_168_33_11_db > /opt/impulse/build/pgsql/agent_schema.sql


NEW_AGENT_LIGHT='
# OSquery  
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/osquery-agent.log 
$InputFileTag osquery-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile osquery-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

template(name="osquery-template" type="list" option.sql="on") {
  constant(value="INSERT INTO osquery (message) values ('"'"'")
  property(name="msg")
  constant(value="'"'"')")
}
if $programname == "'"osquery-"$NEW_AGENT_IP_HYPHENS""'" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="osquery-template"
)

'


NEW_AGENT_HEAVY='
# OSquery  
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/osquery-agent.log 
$InputFileTag osquery-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile osquery-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-alert  
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-alert-agent.log 
$InputFileTag eve-alert-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-alert-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-flow 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-flow-agent.log 
$InputFileTag eve-flow-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-flow-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-dns 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-dns-agent.log 
$InputFileTag eve-dns-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-dns-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-ssh 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-ssh-agent.log 
$InputFileTag eve-ssh-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-ssh-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-http 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-http-agent.log 
$InputFileTag eve-http-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-http-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-tls 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-tls-agent.log 
$InputFileTag eve-tls-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-tls-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-dhcp 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-dhcp-agent.log 
$InputFileTag eve-dhcp-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-dhcp-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor


# eve-ftp 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-ftp-agent.log 
$InputFileTag eve-ftp-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-ftp-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-files 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-files-agent.log 
$InputFileTag eve-files-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-files-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-smb 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-smb-agent.log 
$InputFileTag eve-smb-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-smb-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-smtp 
$InputFileName /var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/eve-smtp-agent.log 
$InputFileTag eve-smtp-'$NEW_AGENT_IP_HYPHENS'
$InputFileStateFile eve-smtp-'$NEW_AGENT_IP_HYPHENS'
$InputFilePollInterval 10
$InputRunFileMonitor


template(name="osquery-template" type="list" option.sql="on") {
  constant(value="INSERT INTO osquery (message) values ('"'"'")
  property(name="msg")
  constant(value="'"'"')")
}
if $programname == "'"osquery-"$NEW_AGENT_IP_HYPHENS""'" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="osquery-template"
)



template(name="eve-alert-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_alerts (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                              
}                                                                                                                                                                                                                                       
if $programname == "'"eve-alert-"$NEW_AGENT_IP_HYPHENS""'" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-alert-template"
)


template(name="eve-flow-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_eve_flow (message) values ('"'"'")                                                         
  property(name="msg")                                                                                             
  constant(value="'"'"')")                                                                                              
}                                                                                                                                                                                                                                       
if $programname == "'"eve-flow-"$NEW_AGENT_IP_HYPHENS""'" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-flow-template"
)


template(name="eve-dns-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_dns (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-dns-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-dns-template"
)


template(name="eve-ssh-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_ssh (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-ssh-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-ssh-template"
)


template(name="eve-http-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_http (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-http-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-http-template"
) 


template(name="eve-tls-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_tls (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-tls-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-tls-template"
) 


template(name="eve-ftp-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_ftp (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-ftp-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-ftp-template"
) 

template(name="eve-files-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_files (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-files-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-files-template"
) 

template(name="eve-smb-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_smb (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-smb-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-smb-template"
) 

template(name="eve-dhcp-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_dhcp (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-dhcp-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-dhcp-template"
) 

template(name="eve-smtp-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_smtp (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "'"eve-smtp-"$NEW_AGENT_IP_HYPHENS""'" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="eve-smtp-template"
) 
'


if [[ $AGENT_TYPE == 'heavy' ]]; 
then
	echo "$NEW_AGENT_HEAVY" > "/var/impulse/etc/rsyslog/rsyslog.d/agent-$NEW_AGENT_IP_HYPHENS.conf"

	/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) VALUES ('"$STATIC_IP_ADDR"')"
else 
	echo "$NEW_AGENT_LIGHT" > "/var/impulse/etc/rsyslog/rsyslog.d/agent-$NEW_AGENT_IP_HYPHENS.conf"
fi

chmod 755 /var/impulse/etc/rsyslog/rsyslog.d/"agent-$NEW_AGENT_IP_HYPHENS.conf"


docker restart impulse-indexer


if [ -x "$(command -v ufw)" ]; then
	ufw allow from $AGENT_IP proto tcp to any port 7001
	ufw allow from $AGENT_IP proto any to any port 7514
	ufw reload
fi

if [ -x "$(command -v firewall-cmd)" ]; then
	firewall-cmd --permanent --zone=impulse_siem --add-source=$AGENT_IP
	firewall-cmd --reload
fi

ssh-keygen -f "/root/.ssh/known_hosts" -R $AGENT_IP

#/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) VALUES ('"$AGENT_IP"')"

#############################################################################################################


NEW_AGENT_IP_HYPHENS=$(echo "$AGENT_IP" | tr . -)

NEW_AGENT_DIR_NAME='impulse-'$NEW_AGENT_IP_HYPHENS

NEW_AGENT_DIR_PATH='/tmp/'$NEW_AGENT_DIR_NAME'/impulse'


cp /var/impulse/etc/rsyslog/ssl/ca-cert.pem /opt/impulse/build/agent/tls/ca-cert.pem
## TODO copy the grpc TLS for the agent 

rm -f '/opt/impulse/build/agent_build/agent-'$NEW_AGENT_IP_HYPHENS'.tar.gz'

rm -rf '/tmp/'$NEW_AGENT_DIR_NAME

mkdir -p $NEW_AGENT_DIR_PATH

cp -rf /opt/impulse/agent/* $NEW_AGENT_DIR_PATH



AGENT_IMPULSE_CONF='
[Env]
IP_MANAGER='$IP_MANAGER'
STATIC_IP_ADDR='$STATIC_IP_ADDR'
HOST_INTERFACE='$HOST_INTERFACE'
AGENT_TYPE='$AGENT_TYPE'
SETUP_TYPE=agent
NIDS_ENABLED=false
NIDS_MODE=IDS
IPS_SETUP=auto
IPS_MODE_PORTS=22,80
AGENT_ID='$AGENT_ID'
AGENT_SECRET_KEY='$AGENT_SECRET_KEY'

##################################################
# There should be no space between key and value.

# IP_MANAGER: manager instance public IP
# STATIC_IP_ADDR: static IP if available
# AGENT_ID: id is provided by the manager on asset enrollment
# SETUP_TYPE: "agent" in sensors conf and "manager" for the manager instance
# NIDS_ENABLED: enable or disable NIDS capabilities. Only relevant if heavy agent
# NIDS_MODE: mode is set to IDS by default (ref. docs)
# IPS_SETUP: traffic forwarding to NFQ based on ports definition in impulse.conf or manual setup via iptables (ref. docs)
# AGENT_TYPE: light/heavy. this must be selected prior to generating the archive. If you wish to change agent type, you must regenerate the archive by deleting the agent in Managed Assets of the UI and recreating it
# AGENT_SECRET_KEY: provided by the manager on asset enrollment 
# HOST_INTERFACE: network interface of the monitored machine, e.g. eth0 
'

echo $AGENT_IMPULSE_CONF

rm $NEW_AGENT_DIR_PATH/impulse.conf
echo "$AGENT_IMPULSE_CONF" > $NEW_AGENT_DIR_PATH"/impulse.conf"

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
cp -rf /opt/impulse/managerd/main/manager_grpc_server/grpc_pb/* $NEW_AGENT_DIR_PATH/agentd/manager_grpc_server_pb


cp /opt/impulse/build/grpc_tls_manager/ca-cert.pem $NEW_AGENT_DIR_PATH/build/agent/grpc/tls

tar czf '/opt/impulse/build/agent_build/agent-'$NEW_AGENT_IP_HYPHENS'.tar.gz' -C '/tmp/'$NEW_AGENT_DIR_NAME impulse

cd /tmp
rm -rf '/tmp/'$NEW_AGENT_DIR_NAME