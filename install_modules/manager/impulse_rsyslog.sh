#!/bin/bash


PROJECT_ROOT_DIR=$1
AGENT_TYPE=$2
DB_NAME_MANAGER=$3
IP_HOST=$4
IMPULSE_DB_SERVER_PWD=$5
AGENT_TAG_ID=$6


MANAGER_GENERAL_CONF_TEMPLATE='
### DO NOT MODIFY. THIS FILE IS MANAGED BY IMPULSE ###

## Remote Agent Unique ID
$LocalHostName '$AGENT_TAG_ID'
$PreserveFQDN on

#################
#### MODULES ####
#################

module(load="imuxsock") # provides support for local system logging
#module(load="immark")  # provides --MARK-- message capability

$ModLoad imfile 

# Load Postgres module 
module(load="ompgsql")

# provides kernel logging support and enable non-kernel klog messages
# module(load="imklog" permitnonkernelfacility="on")

####### TLS Setup #########
# make gtls driver the default
$DefaultNetstreamDriver gtls

# certificate files
$DefaultNetstreamDriverCAFile /etc/ssl/impulse/ca-cert.pem
$DefaultNetstreamDriverCertFile /etc/ssl/impulse/server-cert.pem
$DefaultNetstreamDriverKeyFile /etc/ssl/impulse/server-key.pem

# provides TCP syslog reception with encryption
module(load="imtcp" StreamDriver.Name="gtls" StreamDriver.Mode="1" StreamDriver.AuthMode="anon")
input(type="imtcp" port="7514" )

###########################


###########################
#### GLOBAL DIRECTIVES ####
###########################

## Use traditional timestamp format.
## To enable high precision timestamps, comment out the following line.

## $ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

$template myFormat,"%msg%\n"
$ActionFileDefaultTemplate myFormat


## Filter duplicated messages
$RepeatedMsgReduction on

## Set the default permissions for all log files.

$FileOwner root
$FileGroup root
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
$PrivDropToUser root
$PrivDropToGroup root

## Allowed Senders 
# $AllowedSender TCP, 192.168.33.25, 192.168.33.26 #  127.0.0.1, 10.111.1.0/24, *.evoltek.test.com

## Where to place spool and state files
$WorkDirectory /var/spool/rsyslog
#$WorkDirectory /var/impulse/data/rsyslog/spool/rsyslog


## Include all config files in /etc/rsyslog.d/

$IncludeConfig /etc/rsyslog.d/*.conf


$template remote-incoming-logs, "/var/log/impulse/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?remote-incoming-logs

'

MANAGER_LIGHT='
# OSquery  
$InputFileName /var/log/osquery/osqueryd.results.log
$InputFileTag osquery-manager
$InputFileStateFile osquery-manager
$InputFilePollInterval 10
$InputRunFileMonitor


template(name="osquery-template" type="list" option.sql="on") {
  constant(value="INSERT INTO osquery (message) values ('"'"'")
  property(name="msg")
  constant(value="'"'"')")
}
if $programname == "osquery-manager" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="osquery-template"
)
'

MANAGER_HEAVY='
# OSquery  
$InputFileName /var/log/osquery/osqueryd.results.log
$InputFileTag osquery-manager
$InputFileStateFile osquery-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-alert  
$InputFileName /var/impulse/log/suricata/eve-alert.json 
$InputFileTag eve-alert-manager
$InputFileStateFile eve-alert-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-flow  
$InputFileName /var/impulse/log/suricata/eve-flow.json 
$InputFileTag eve-flow-manager
$InputFileStateFile eve-flow-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-dns  
$InputFileName /var/impulse/log/suricata/eve-dns.json 
$InputFileTag eve-dns-manager
$InputFileStateFile eve-dns-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-ssh 
$InputFileName /var/impulse/log/suricata/eve-ssh.json 
$InputFileTag eve-ssh-manager
$InputFileStateFile eve-ssh-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-http 
$InputFileName /var/impulse/log/suricata/eve-http.json 
$InputFileTag eve-http-manager
$InputFileStateFile eve-http-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-tls 
$InputFileName /var/impulse/log/suricata/eve-tls.json 
$InputFileTag eve-tls-manager
$InputFileStateFile eve-tls-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-dhcp 
$InputFileName /var/impulse/log/suricata/eve-dhcp.json 
$InputFileTag eve-dhcp-manager
$InputFileStateFile eve-dhcp-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-ftp 
$InputFileName /var/impulse/log/suricata/eve-ftp.json 
$InputFileTag eve-ftp-manager
$InputFileStateFile eve-ftp-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-files 
$InputFileName /var/impulse/log/suricata/eve-files.json 
$InputFileTag eve-files-manager
$InputFileStateFile eve-files-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-smb 
$InputFileName /var/impulse/log/suricata/eve-smb.json 
$InputFileTag eve-smb-manager
$InputFileStateFile eve-smb-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-smtp 
$InputFileName /var/impulse/log/suricata/eve-smtp.json 
$InputFileTag eve-smtp-manager
$InputFileStateFile eve-smtp-manager
$InputFilePollInterval 10
$InputRunFileMonitor


# zeek conn.log 
$InputFileName /var/impulse/log/zeek/conn.log
$InputFileTag zeek-conn-manager
$InputFileStateFile zeek-conn-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# zeek http.log 
$InputFileName /var/impulse/log/zeek/http.log
$InputFileTag zeek-http-manager
$InputFileStateFile zeek-http-manager
$InputFilePollInterval 10
$InputRunFileMonitor

# zeek files.log 
$InputFileName /var/impulse/log/zeek/files.log
$InputFileTag zeek-files-manager
$InputFileStateFile zeek-files-manager
$InputFilePollInterval 10
$InputRunFileMonitor



template(name="osquery-template" type="list" option.sql="on") {
  constant(value="INSERT INTO osquery (message) values ('"'"'")
  property(name="msg")
  constant(value="'"'"')")
}
if $programname == "osquery-manager" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="osquery-template"
)


template(name="eve-alert-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_alerts (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                              
}                                                                                                                                                                                                                                       
if $programname == "eve-alert-manager" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-alert-template"
)


template(name="eve-flow-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_eve_flow (message) values ('"'"'")                                                         
  property(name="msg")                                                                                             
  constant(value="'"'"')")                                                                                              
}                                                                                                                                                                                                                                       
if $programname == "eve-flow-manager" then 
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-flow-template"
)


template(name="eve-dns-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_dns (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-dns-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-dns-template"
)    


template(name="eve-ssh-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_ssh (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-ssh-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-ssh-template"
)


template(name="eve-http-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_http (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-http-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-http-template"
) 


template(name="eve-tls-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_tls (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-tls-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-tls-template"
) 


template(name="eve-ftp-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_ftp (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-ftp-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-ftp-template"
) 

template(name="eve-files-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_files (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-files-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-files-template"
) 

template(name="eve-smb-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_smb (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-smb-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-smb-template"
) 

template(name="eve-dhcp-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_dhcp (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-dhcp-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-dhcp-template"
) 

template(name="eve-smtp-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO suricata_smtp (message) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "eve-smtp-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="eve-smtp-template"
)


template(name="zeek-conn-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO zeek_logs (conn) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "zeek-conn-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="zeek-conn-template"
)

template(name="zeek-http-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO zeek_logs (http) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "zeek-http-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="zeek-http-template"
)

template(name="zeek-files-template" type="list" option.sql="on") {                                                     
  constant(value="INSERT INTO zeek_logs (files) values ('"'"'")                                                         
  property(name="msg")                                                                                              
  constant(value="'"'"')")                                                                                             
}
if $programname == "zeek-files-manager" then
action(
	type="ompgsql" 
	server="127.0.0.1" 
	port="7543" 
	user="postgres" 
	pass=`echo $POSTGRES_PASSWORD` db="'$DB_NAME_MANAGER'" 
	template="zeek-files-template"
)

'

if [[ $AGENT_TYPE == 'heavy' ]]; 
then
	echo "$MANAGER_HEAVY" > "/var/impulse/etc/rsyslog/rsyslog.d/manager-$IP_HOST.conf"
else 
	echo "$MANAGER_LIGHT" > "/var/impulse/etc/rsyslog/rsyslog.d/manager-$IP_HOST.conf"
fi
echo "$MANAGER_GENERAL_CONF_TEMPLATE" > "/var/impulse/etc/rsyslog/rsyslog.conf"

chmod 755 /var/impulse/etc/rsyslog/rsyslog.d/
chmod 755 /var/impulse/etc/rsyslog/rsyslog.conf

sed -e '/RANDFILE/ s/^#*/#/' -i /etc/ssl/openssl.cnf # Comment out 'RANDFILE = $ENV::HOME/.rnd' in /etc/ssl/openssl.cnf # creates error when generating keys; safe to remove 
cd /var/impulse/etc/rsyslog/ssl
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 3600 -key ca-key.pem -out ca-cert.pem -subj '/CN=localhost'
openssl req -newkey rsa:2048 -days 3600 -nodes -keyout server-key.pem -out server-req.pem -subj '/CN=localhost' 
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days 3600 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem

systemctl restart rsyslog
cd $PROJECT_ROOT_DIR
