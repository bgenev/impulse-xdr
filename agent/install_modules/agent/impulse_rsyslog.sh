#!/bin/bash


PROJECT_ROOT_DIR=$1
AGENT_TYPE=$2
IP_MANAGER=$3
AGENT_TAG_ID=$4
PACKAGE_MGR=$5


#AGENT_ID_TAG="ixcAgent12"

## Install dependencies 

if [[ $PACKAGE_MGR = "deb" ]]; then
	DEBIAN_FRONTEND=noninteractive apt install -y rsyslog rsyslog-gnutls
fi

if [[ $PACKAGE_MGR = "rpm" ]]; then
	dnf -y install rsyslog rsyslog-gnutls
	#yum -y install rsyslog rsyslog-gnutls
fi

## Backup of the existing system rsyslog file 
mv /etc/rsyslog.conf /etc/rsyslog.conf.bak


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

#$IncludeConfig /etc/rsyslog.d/impulse/*.conf # Include all config files in /etc/rsyslog.d/
include(file="/etc/rsyslog.d/impulse/*.conf")

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
	echo "$HEAVY_AGENT_CONFD_RSYSLOG_TEMPLATE" > "/etc/rsyslog.d/impulse/agent.conf"
else 
	echo "$LIGHT_AGENT_CONFD_RSYSLOG_TEMPLATE" > "/etc/rsyslog.d/impulse/agent.conf"
fi

echo "$AGENT_GENERAL_CONF_TEMPLATE" > "/etc/rsyslog.conf"


systemctl enable rsyslog
systemctl restart rsyslog













# # rsyslog configuration file

# # For more information see /usr/share/doc/rsyslog-*/rsyslog_conf.html
# # If you experience problems, see http://www.rsyslog.com/doc/troubleshoot.html

# #### MODULES ####

# # The imjournal module bellow is now used as a message source instead of imuxsock.
# $ModLoad imuxsock # provides support for local system logging (e.g. via logger command)
# # Tachtler
# # default: $ModLoad imjournal # provides access to the systemd journal
# # $ModLoad imjournal # provides access to the systemd journal
# #$ModLoad imklog # reads kernel messages (the same are read from journald)
# # Tachtler
# # default: #$ModLoad immark  # provides --MARK-- message capability
# $ModLoad immark  # provides --MARK-- message capability

# # Provides UDP syslog reception
# #$ModLoad imudp
# #$UDPServerRun 514

# # Provides TCP syslog reception
# #$ModLoad imtcp
# #$InputTCPServerRun 514


# #### GLOBAL DIRECTIVES ####

# # Where to place auxiliary files
# $WorkDirectory /var/lib/rsyslog

# # Use default timestamp format
# $ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# # File syncing capability is disabled by default. This feature is usually not required,
# # not useful and an extreme performance hit
# #$ActionFileEnableSync on

# # Include all config files in /etc/rsyslog.d/
# $IncludeConfig /etc/rsyslog.d/*.conf

# # Turn off message reception via local log socket;
# # local messages are retrieved through imjournal now.
# # Tachtler
# # default: $OmitLocalLogging on
# $OmitLocalLogging off

# # File to store the position in the journal
# # Tachtler
# # default: $IMJournalStateFile imjournal.state
# # $IMJournalStateFile imjournal.state


# #### RULES ####
 
# # Tachtler - new -
# # Write all Log-Information to graylog
# #$template GRAYLOGRFC5424,"<%PRI%>%PROTOCOL-VERSION% %TIMESTAMP:::date-rfc3339% %HOSTNAME% %APP-NAME% %PROCID% %MSGID% %STRUCTURED-DATA% %msg%\n"
# #*.*                                                     @10.7.0.110:514;GRAYLOGRFC5424
# *.*                                                     @10.7.0.110:514;RSYSLOG_SyslogProtocol23Format
