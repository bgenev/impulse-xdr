#!/bin/bash


AGENT_IP=$1
IP_MANAGER=$2
AGENT_TYPE=$3
AGENT_ID=$4
AGENT_SECRET_KEY=$5


NEW_AGENT_IP_HYPHENS=$(echo "$AGENT_IP" | tr . -)
dot_replaced=$(echo "$AGENT_IP" | tr . _)
NEW_AGENT_DB=$dot_replaced"_db"

/usr/bin/docker exec -i impulse-datastore psql --username=postgres -c 'CREATE DATABASE "'$NEW_AGENT_DB'";'
cat /opt/impulse/build/pgsql/agent_schema.sql | docker exec -i impulse-datastore psql -U postgres -d $NEW_AGENT_DB


NEW_AGENT_LIGHT_WINDOWS='
# OSquery  
input(type="imfile" File="/var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/osquery-agent.log" Tag="osquery-'$NEW_AGENT_IP_HYPHENS'")

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


## Windows Defender  
input(type="imfile" File="/var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/Microsoft-Windows-Windows_Defender.log" Tag="windows-defender-'$NEW_AGENT_IP_HYPHENS'")

template(name="windows-defender-template" type="list" option.sql="on") {
  constant(value="INSERT INTO windows_defender (message) values ('"'"'")
  property(name="msg")
  constant(value="'"'"')")
}
if $programname == "'"windows-defender-"$NEW_AGENT_IP_HYPHENS""'" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="windows-defender-template"
)


## Windows Security Center  
input(type="imfile" File="/var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/SecurityCenter.log" Tag="windows-security-center-'$NEW_AGENT_IP_HYPHENS'")

template(name="windows-security-center-template" type="list" option.sql="on") {
  constant(value="INSERT INTO windows_security_center (message) values ('"'"'")
  property(name="msg")
  constant(value="'"'"')")
}
if $programname == "'"windows-security-center-"$NEW_AGENT_IP_HYPHENS""'" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="windows-security-center-template"
)

## Windows Security Auditing  
input(type="imfile" File="/var/log/impulse/agent-'$NEW_AGENT_IP_HYPHENS'/Microsoft-Windows-Security-Auditing.log" Tag="windows-security-auditing-'$NEW_AGENT_IP_HYPHENS'")

template(name="windows-security-auditing-template" type="list" option.sql="on") {
  constant(value="INSERT INTO windows_security_auditing (message) values ('"'"'")
  property(name="msg")
  constant(value="'"'"')")
}
if $programname == "'"windows-security-auditing-"$NEW_AGENT_IP_HYPHENS""'" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$NEW_AGENT_DB'" 
	template="windows-security-auditing-template"
)


'

echo "$NEW_AGENT_LIGHT_WINDOWS" > "/var/impulse/etc/rsyslog/rsyslog.d/agent-$NEW_AGENT_IP_HYPHENS.conf"
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

#/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) VALUES ('"$AGENT_IP"')"


NEW_AGENT_DIR_NAME='impulse-'$NEW_AGENT_IP_HYPHENS
NEW_AGENT_DIR_PATH='/tmp/'$NEW_AGENT_DIR_NAME'/impulse'


echo "##############################################"
echo "NEW_AGENT_DIR_NAME: "$NEW_AGENT_DIR_NAME
echo "NEW_AGENT_DIR_PATH: "$NEW_AGENT_DIR_PATH
echo "NEW_AGENT_IP_HYPHENS: "$NEW_AGENT_IP_HYPHENS
echo "##############################################"


cp /var/impulse/etc/rsyslog/ssl/ca-cert.pem /opt/impulse/build/agent/tls/ca-cert.pem

cp /var/impulse/etc/grpc/tls/ca-cert.pem /opt/impulse/build/agent/grpc/tls/ca-cert.pem


rm -f '/opt/impulse/build/agent_build/agent-'$NEW_AGENT_IP_HYPHENS'.tar.gz'
rm -rf '/tmp/'$NEW_AGENT_DIR_NAME
mkdir -p $NEW_AGENT_DIR_PATH
cp -rf /opt/impulse/agent/agentd $NEW_AGENT_DIR_PATH

AGENT_IMPULSE_CONF='
[Env]
AGENT_IP='$AGENT_IP'
IP_MANAGER='$IP_MANAGER'
AGENT_TYPE='$AGENT_TYPE'
AGENT_ID='$AGENT_ID'
AGENT_SECRET_KEY='$AGENT_SECRET_KEY'

##################################################
# There should be no space between key and value.

# AGENT_IP: IP address of the monitored machine 
# IP_MANAGER: manager instance public IP
# AGENT_ID: id is provided by the manager on asset enrollment
# AGENT_TYPE: light/heavy. this must be selected prior to generating the archive. If you wish to change agent type, you must regenerate the archive by deleting the agent in Managed Assets of the UI and recreating it
# AGENT_SECRET_KEY: provided by the manager on asset enrollment 
'

rm $NEW_AGENT_DIR_PATH/impulse.conf
echo "$AGENT_IMPULSE_CONF" > $NEW_AGENT_DIR_PATH"/impulse.conf"

rm -rf $NEW_AGENT_DIR_PATH/install_modules
rm -rf $NEW_AGENT_DIR_PATH/build 
rm -rf $NEW_AGENT_DIR_PATH/venv
rm -rf $NEW_AGENT_DIR_PATH/backup

mkdir $NEW_AGENT_DIR_PATH/build 
mkdir -p $NEW_AGENT_DIR_PATH/build/grpc/tls

mkdir -p $NEW_AGENT_DIR_PATH/agentd/main/helpers/shared
cp -rf /opt/impulse/managerd/main/helpers/shared/* $NEW_AGENT_DIR_PATH/agentd/main/helpers/shared/
cp -rf /opt/impulse/managerd/main/manager_grpc_server/grpc_pb/* $NEW_AGENT_DIR_PATH/agentd/manager_grpc_server_pb

## Windows files 
cp -rf /opt/impulse/build/windows-agent/build/nxlog '/tmp/'$NEW_AGENT_DIR_NAME'/impulse/build'
cp -rf /var/impulse/etc/rsyslog/ssl/ca-cert.pem '/tmp/'$NEW_AGENT_DIR_NAME'/impulse/build/nxlog'

cp -rf /opt/impulse/build/agent/grpc/tls/ca-cert.pem '/tmp/'$NEW_AGENT_DIR_NAME'/impulse/build/grpc/tls'

cp -rf /opt/impulse/build/windows-agent/build/nssm-2.24 '/tmp/'$NEW_AGENT_DIR_NAME'/impulse/build'
cp -rf /opt/impulse/build/windows-agent/build/osquery '/tmp/'$NEW_AGENT_DIR_NAME'/impulse/build'
cp -rf /opt/impulse/build/windows-agent/build/impulse-files/impulse-service.bat '/tmp/'$NEW_AGENT_DIR_NAME'/impulse'

cp -rf /opt/impulse/build/windows-agent/install_win_agent.ps1 '/tmp/'$NEW_AGENT_DIR_NAME'/impulse'
cp -rf /opt/impulse/build/windows-agent/uninstall_agent.ps1 '/tmp/'$NEW_AGENT_DIR_NAME'/impulse'

sed -i '/define HOSTNAME_ID/c\define HOSTNAME_ID "agent-'$NEW_AGENT_IP_HYPHENS'"' '/tmp/'$NEW_AGENT_DIR_NAME'/impulse/build/nxlog/nxlog.conf'
sed -i '/define IP_MANAGER/c\define IP_MANAGER '$IP_MANAGER'' '/tmp/'$NEW_AGENT_DIR_NAME'/impulse/build/nxlog/nxlog.conf'

tar czf '/opt/impulse/build/agent_build/agent-'$NEW_AGENT_IP_HYPHENS'.tar.gz' -C '/tmp/'$NEW_AGENT_DIR_NAME impulse

cd /tmp
rm -rf '/tmp/'$NEW_AGENT_DIR_NAME

