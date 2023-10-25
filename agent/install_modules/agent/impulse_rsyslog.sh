#!/bin/bash


PROJECT_ROOT_DIR=$1
AGENT_TYPE=$2
IP_MANAGER=$3
AGENT_TAG_ID=$4


#AGENT_ID_TAG="ixcAgent12"

#### Rsyslog Agent
LIGHT_AGENT_CONFD_RSYSLOG_TEMPLATE='
# OSquery  
$InputFileName /var/log/osquery/osqueryd.results.log
$InputFileTag osquery-agent
$InputFileStateFile osquery-agent
$InputFilePollInterval 10
$InputRunFileMonitor
'

HEAVY_AGENT_CONFD_RSYSLOG_TEMPLATE='
# OSquery  
$InputFileName /var/log/osquery/osqueryd.results.log
$InputFileTag osquery-agent
$InputFileStateFile osquery-agent
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-alerts.json 
$InputFileName /var/impulse/log/suricata/eve-alert.json
$InputFileTag eve-alert-agent
$InputFileStateFile eve-alert-agent
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-flow.json 
$InputFileName /var/impulse/log/suricata/eve-flow.json
$InputFileTag eve-flow-agent
$InputFileStateFile eve-flow-agent
$InputFilePollInterval 10
$InputRunFileMonitor

# eve-dns.json 
$InputFileName /var/impulse/log/suricata/eve-dns.json
$InputFileTag eve-dns-agent
$InputFileStateFile eve-dns-agent
$InputFilePollInterval 10
$InputRunFileMonitor
'

AGENT_GENERAL_CONF_TEMPLATE='
### This file is managed by Impulse. 

## Remote Agent Unique ID
$LocalHostName '$AGENT_TAG_ID'
$PreserveFQDN on

$ModLoad imuxsock # provides support for local system logging
$ModLoad imklog   # provides kernel logging support (previously done by rklogd)
#$ModLoad immark  # provides --MARK-- message capability
$ModLoad imfile 

$template logsFormat,"%msg%\n"
$ActionFileDefaultTemplate logsFormat

$MaxMessageSize 512k

# Filter duplicated messages
$RepeatedMsgReduction on

# Set the default permissions for all log files.
$FileOwner root
$FileGroup root
$FileCreateMode 0640
$DirCreateMode 0755
$Umask 0022
$PrivDropToUser root
$PrivDropToGroup root

$WorkDirectory /var/spool/rsyslog  #Where to place spool files

############################## TLS Setup ####################################
$DefaultNetstreamDriverCAFile /etc/ssl/impulse/ca-cert.pem
$DefaultNetstreamDriver gtls
$ActionSendStreamDriverMode 1
$ActionSendStreamDriverAuthMode anon
#############################################################################

$IncludeConfig /etc/rsyslog.d/*.conf # Include all config files in /etc/rsyslog.d/

## Set up buffering 
$ActionQueueType LinkedList # use asynchronous processing
$ActionQueueFileName dbq # set file name, also enables disk mode
$ActionResumeRetryCount -1 # infinite retries on insert failure

# # TCP send to Manager
*.* @@'$IP_MANAGER':7514  # Manager IP_ADDR is dynamically generated from the config file. 
& ~
'


if [[ $AGENT_TYPE == 'heavy' ]]; 
then
	echo "$HEAVY_AGENT_CONFD_RSYSLOG_TEMPLATE" > "/var/impulse/etc/rsyslog/rsyslog.d/agent.conf"
else 
	echo "$LIGHT_AGENT_CONFD_RSYSLOG_TEMPLATE" > "/var/impulse/etc/rsyslog/rsyslog.d/agent.conf"
fi


echo "$AGENT_GENERAL_CONF_TEMPLATE" > "/var/impulse/etc/rsyslog/rsyslog.conf"

