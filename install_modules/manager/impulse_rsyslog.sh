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
module(load="imfile" PollingInterval="10")
module(load="ompgsql") # Load Postgres module 

# module(load="immark")  # provides --MARK-- message capability
# module(load="imklog" permitnonkernelfacility="on") # provides kernel logging support and enable non-kernel klog messages

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
input(type="imfile" File="/var/log/osquery/osqueryd.results.log" Tag="osquery-manager")

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
input(type="imfile" File="/var/log/osquery/osqueryd.results.log" Tag="osquery-manager")

# eve-alerts 
input(type="imfile" File="/var/impulse/log/suricata/eve-alert.json" Tag="eve-alert-manager")

# eve-flow
input(type="imfile" File="/var/impulse/log/suricata/eve-flow.json" Tag="eve-flow-manager")

# eve-dns 
input(type="imfile" File="/var/impulse/log/suricata/eve-dns.json" Tag="eve-dns-manager")

# eve-ssh 
input(type="imfile" File="/var/impulse/log/suricata/eve-ssh.json" Tag="eve-ssh-manager")

# eve-http 
input(type="imfile" File="/var/impulse/log/suricata/eve-http.json" Tag="eve-http-manager")

# eve-tls 
input(type="imfile" File="/var/impulse/log/suricata/eve-tls.json" Tag="eve-tls-manager")

# eve-dhcp 
input(type="imfile" File="/var/impulse/log/suricata/eve-dhcp.json" Tag="eve-dhcp-manager")

# eve-ftp 
input(type="imfile" File="/var/impulse/log/suricata/eve-ftp.json" Tag="eve-ftp-manager")

# eve-files 
input(type="imfile" File="/var/impulse/log/suricata/eve-files.json" Tag="eve-files-manager")

# eve-smb 
input(type="imfile" File="/var/impulse/log/suricata/eve-smb.json" Tag="eve-smb-manager")

# eve-smtp 
input(type="imfile" File="/var/impulse/log/suricata/eve-smtp.json" Tag="eve-smtp-manager")


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
