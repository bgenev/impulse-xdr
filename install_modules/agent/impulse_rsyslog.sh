#!/bin/bash


PROJECT_ROOT_DIR=$1
AGENT_TYPE=$2
IP_MANAGER=$3
AGENT_TAG_ID=$4
PACKAGE_MGR=$5


## rsyslog dependencies 
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
input(type="imfile" File="/var/log/osquery/osqueryd.results.log" Tag="osquery-agent")
'

HEAVY_AGENT_CONFD_RSYSLOG_TEMPLATE='
# OSquery  
input(type="imfile" File="/var/log/osquery/osqueryd.results.log" Tag="osquery-agent")

# eve-alerts 
input(type="imfile" File="/var/impulse/log/suricata/eve-alert.json" Tag="eve-alert-agent")

# eve-flow
input(type="imfile" File="/var/impulse/log/suricata/eve-flow.json" Tag="eve-flow-agent")

# eve-dns 
input(type="imfile" File="/var/impulse/log/suricata/eve-dns.json" Tag="eve-dns-agent")

# eve-ssh 
input(type="imfile" File="/var/impulse/log/suricata/eve-ssh.json" Tag="eve-ssh-agent")

# eve-http 
input(type="imfile" File="/var/impulse/log/suricata/eve-http.json" Tag="eve-http-agent")

# eve-tls 
input(type="imfile" File="/var/impulse/log/suricata/eve-tls.json" Tag="eve-tls-agent")

# eve-dhcp 
input(type="imfile" File="/var/impulse/log/suricata/eve-dhcp.json" Tag="eve-dhcp-agent")

# eve-ftp 
input(type="imfile" File="/var/impulse/log/suricata/eve-ftp.json" Tag="eve-ftp-agent")

# eve-files 
input(type="imfile" File="/var/impulse/log/suricata/eve-files.json" Tag="eve-files-agent")

# eve-smb 
input(type="imfile" File="/var/impulse/log/suricata/eve-smb.json" Tag="eve-smb-agent")

# eve-smtp 
input(type="imfile" File="/var/impulse/log/suricata/eve-smtp.json" Tag="eve-smtp-agent")
'

AGENT_GENERAL_CONF_TEMPLATE='
### This file is managed by Impulse. 

## Remote Agent Unique ID
$LocalHostName '$AGENT_TAG_ID'
$PreserveFQDN on

module(load="imuxsock") # provides support for local system logging
module(load="imklog" permitnonkernelfacility="on") # provides kernel logging support and enable non-kernel klog messages
module(load="imfile" PollingInterval="10")

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

$WorkDirectory /var/spool/rsyslog 

############################## TLS Setup ####################################
$DefaultNetstreamDriverCAFile /etc/ssl/impulse/ca-cert.pem
$DefaultNetstreamDriver gtls
$ActionSendStreamDriverMode 1
$ActionSendStreamDriverAuthMode anon
#############################################################################

#$IncludeConfig /etc/rsyslog.d/impulse/*.conf
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
















###
### OLD WAY WITH CONTAINARIZED RSYSLOG
###


# #### Rsyslog Agent
# LIGHT_AGENT_CONFD_RSYSLOG_TEMPLATE='
# # OSquery  
# $InputFileName /var/log/osquery/osqueryd.results.log
# $InputFileTag osquery-agent
# $InputFileStateFile osquery-agent
# $InputFilePollInterval 10
# $InputRunFileMonitor
# '

# HEAVY_AGENT_CONFD_RSYSLOG_TEMPLATE='
# # OSquery  
# $InputFileName /var/log/osquery/osqueryd.results.log
# $InputFileTag osquery-agent
# $InputFileStateFile osquery-agent
# $InputFilePollInterval 10
# $InputRunFileMonitor

# # eve-alerts.json 
# $InputFileName /var/impulse/log/suricata/eve-alert.json
# $InputFileTag eve-alert-agent
# $InputFileStateFile eve-alert-agent
# $InputFilePollInterval 10
# $InputRunFileMonitor

# # eve-flow.json 
# $InputFileName /var/impulse/log/suricata/eve-flow.json
# $InputFileTag eve-flow-agent
# $InputFileStateFile eve-flow-agent
# $InputFilePollInterval 10
# $InputRunFileMonitor

# # eve-dns.json 
# $InputFileName /var/impulse/log/suricata/eve-dns.json
# $InputFileTag eve-dns-agent
# $InputFileStateFile eve-dns-agent
# $InputFilePollInterval 10
# $InputRunFileMonitor
# '




# AGENT_GENERAL_CONF_TEMPLATE='
# ### This file is managed by Impulse. 

# ## Remote Agent Unique ID
# $LocalHostName '$AGENT_TAG_ID'
# $PreserveFQDN on

# $ModLoad imuxsock # provides support for local system logging
# $ModLoad imklog   # provides kernel logging support (previously done by rklogd)
# #$ModLoad immark  # provides --MARK-- message capability
# $ModLoad imfile 

# $template logsFormat,"%msg%\n"
# $ActionFileDefaultTemplate logsFormat

# $MaxMessageSize 512k

# # Filter duplicated messages
# $RepeatedMsgReduction on

# # Set the default permissions for all log files.
# $FileOwner root
# $FileGroup root
# $FileCreateMode 0640
# $DirCreateMode 0755
# $Umask 0022
# $PrivDropToUser root
# $PrivDropToGroup root

# $WorkDirectory /var/spool/rsyslog  #Where to place spool files

# ############################## TLS Setup ####################################
# $DefaultNetstreamDriverCAFile /etc/ssl/impulse/ca-cert.pem
# $DefaultNetstreamDriver gtls
# $ActionSendStreamDriverMode 1
# $ActionSendStreamDriverAuthMode anon
# #############################################################################

# $IncludeConfig /etc/rsyslog.d/*.conf # Include all config files in /etc/rsyslog.d/

# ## Set up buffering 
# $ActionQueueType LinkedList # use asynchronous processing
# $ActionQueueFileName dbq # set file name, also enables disk mode
# $ActionResumeRetryCount -1 # infinite retries on insert failure

# # # TCP send to Manager
# *.* @@'$IP_MANAGER':7514  # Manager IP_ADDR is dynamically generated from the config file. 
# & ~
# '

# if [[ $AGENT_TYPE == 'heavy' ]]; 
# then
# 	echo "$HEAVY_AGENT_CONFD_RSYSLOG_TEMPLATE" > "/var/impulse/etc/rsyslog/rsyslog.d/agent.conf"
# else 
# 	echo "$LIGHT_AGENT_CONFD_RSYSLOG_TEMPLATE" > "/var/impulse/etc/rsyslog/rsyslog.d/agent.conf"
# fi

# echo "$AGENT_GENERAL_CONF_TEMPLATE" > "/var/impulse/etc/rsyslog/rsyslog.conf"

