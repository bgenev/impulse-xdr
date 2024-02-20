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
module(load="imfile" PollingInterval="10")

# # Where to place auxiliary files
global(workDirectory="/var/lib/rsyslog")
# # Use default timestamp format
# module(load="builtin:omfile" Template="RSYSLOG_TraditionalFileFormat")

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

############################## TLS Setup ####################################
$DefaultNetstreamDriverCAFile /etc/ssl/impulse/ca-cert.pem
$DefaultNetstreamDriver gtls
$ActionSendStreamDriverMode 1
$ActionSendStreamDriverAuthMode anon
#############################################################################

include(file="/etc/rsyslog.d/impulse/*.conf")

## Set up buffering 
$ActionQueueType LinkedList # use asynchronous processing
$ActionQueueFileName dbq # set file name, also enables disk mode
$ActionResumeRetryCount -1 # infinite retries on insert failure

## TCP send to Manager
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







# ### This file is managed by Impulse. 
# ## Remote Agent Unique ID
# $LocalHostName '$AGENT_TAG_ID'
# $PreserveFQDN on
# #### GLOBAL DIRECTIVES ####
# global(workDirectory="/var/lib/rsyslog") # Where to place auxiliary files
# module(load="builtin:omfile" Template="RSYSLOG_TraditionalFileFormat") # Use default timestamp format

# # make gtls driver the default and set certificate files
# global(
# DefaultNetstreamDriver="gtls"
# DefaultNetstreamDriverCAFile="/etc/ssl/impulse/ca-cert.pem"
# )

# #### MODULES ####
# module(load="imfile")
# include(file="/etc/rsyslog.d/impulse/*.conf" mode="optional") # Include all config files in /etc/rsyslog.d/
# #### FORWARDING SETUP ####
# action(type="omfwd"  
# # # An on-disk queue is created for this action. If the remote host is
# # # down, messages are spooled to disk and sent when it is up again.
# #queue.filename="fwdRule1"       # unique name prefix for spool files
# #queue.maxdiskspace="1g"         # 1gb space limit (use as much as possible)
# queue.saveonshutdown="on"       # save messages to disk on shutdown
# queue.type="LinkedList"         # run asynchronously
# action.resumeRetryCount="-1"    # infinite retries if host is down
# StreamDriver="gtls"
# StreamDriverMode="1" # run driver in TLS-only mode
# Target="192.168.0.37" Port="7514" Protocol="tcp")
