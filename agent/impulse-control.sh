#!/bin/bash

#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

SYST_STATE=$1
ARG2=$2

cd /opt/impulse

NIDS_ENABLED=$(awk -F "=" '/NIDS_ENABLED/ {print $2}' impulse.conf | tr -d ' ')
AGENT_TYPE=$(awk -F "=" '/AGENT_TYPE/ {print $2}' impulse.conf | tr -d ' ')


if [[ $SYST_STATE == 'stop' ]]
then
	echo "Stop and deactivate Impulse..."

	systemctl stop impulse-main osqueryd rsyslog syslog.socket
	#systemctl stop impulse-containers

	systemctl disable impulse-main osqueryd rsyslog
	#systemctl disable  impulse-containers
	
	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl stop impulse-nids
		systemctl disable impulse-nids
	else 
		echo "NIDS capabilities are disabled."
	fi

elif [[ $SYST_STATE == 'start' ]]
then
	echo "Start and enable Impulse..."

	systemctl enable impulse-main osqueryd rsyslog # impulse-containers
	systemctl start impulse-main osqueryd rsyslog syslog.socket # impulse-containers
	

	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl start impulse-nids
		systemctl enable impulse-nids
	else 
		echo "NIDS caps are disabled."
	fi

elif [[ $SYST_STATE == 'status' && -z "$2" ]]
then
	printf "\n\nImpulse XDR status check..."
	printf "\n\n "
	printf "Components "
	printf "\n\n "
	printf "impulse-main: "$(systemctl is-active impulse-main)
	printf "\n\n "
	# printf "impulse-containers: "$(systemctl is-active impulse-containers)
	# printf "\n\n "
	printf "impulse-nids: "$(systemctl is-active impulse-nids)
	printf "\n\n "	
	printf "osqueryd: "$(systemctl is-active osqueryd)
	printf "\n\n "
	printf "rsyslog: "$(systemctl is-active rsyslog)
	printf "\n\n "	
	#printf "Docker containers \n\n "
	#docker ps -a | grep "impulse-suricata"
else
    printf 'Unknown command. Please enter "start", "stop" or "status" to activate, deactivate or view Impulse system status.'
fi

