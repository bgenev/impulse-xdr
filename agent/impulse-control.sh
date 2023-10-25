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

	systemctl stop impulse-main impulse-containers osqueryd
	systemctl disable impulse-main osqueryd impulse-containers
	
	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl stop impulse-nids
		systemctl disable impulse-nids
	else 
		echo "NIDS capabilities are disabled."
	fi

elif [[ $SYST_STATE == 'start' ]]
then
	echo "Start and enable Impulse..."
	#docker-compose --env-file ./impulse.conf up --detach
	
	systemctl start impulse-containers impulse-main osqueryd
	systemctl enable impulse-main osqueryd impulse-containers

	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl start impulse-nids
		systemctl enable impulse-nids
	else 
		echo "NIDS caps are disabled."
	fi

elif [[ $SYST_STATE == 'restart' ]]
then
	echo "Restarting Impulse, please wait..."
	#docker-compose --env-file ./impulse.conf up --detach
	systemctl stop impulse-main impulse-containers osqueryd
	systemctl disable impulse-main osqueryd impulse-containers
	
	if [[ $NIDS_ENABLED == 'true' && $AGENT_TYPE == 'heavy' ]]; then
		systemctl stop impulse-nids
		systemctl disable impulse-nids
	else 
		echo "NIDS caps are disabled."
	fi

	sleep 1
	
	systemctl start impulse-containers impulse-main osqueryd
	systemctl enable impulse-main osqueryd impulse-containers

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
	printf "impulse-containers: "$(systemctl is-active impulse-containers)
	printf "\n\n "
	printf "impulse-nids: "$(systemctl is-active impulse-nids)
	printf "\n\n "	
	printf "osqueryd: "$(systemctl is-active osqueryd)
	printf "\n\n "
	printf "Docker containers \n\n "
	docker ps -a 

elif [[ $SYST_STATE == 'status' && $ARG2 == 'verbose' ]]
then
	printf "\n\nImpulse XDR status check..."
	printf "\n\n "
	printf "Components "
	printf "\n\n "
	printf "impulse-main: "$(systemctl is-active impulse-main)
	printf "\n\n "
	printf "impulse-containers-main: "$(systemctl is-active impulse-containers-main)
	printf "\n\n "
	printf "impulse-nids: "$(systemctl is-active impulse-nids)
	printf "\n\n "		
	printf "osqueryd: "$(systemctl is-active osqueryd)
	printf "\n\n "
	printf "Docker containers: \n\n "
	
	
	printf "Logs: \n\n" 
	/usr/local/bin/docker-compose logs
	printf "\n\n "
	docker ps -a 
	systemctl status impulse-containers-main impulse-main osqueryd 

else
    printf 'Unknown command. Please enter "start", "stop" or "status" to activate, deactivate or view Impulse system status.'
fi

