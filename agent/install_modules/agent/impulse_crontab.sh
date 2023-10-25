#!/bin/bash

PROJECT_ROOT_DIR=$1
AGENT_TYPE=$2


if [[ $AGENT_TYPE == 'light' || $AGENT_TYPE == 'heavy' ]]; then
	kernelk_cron_file="

	"
fi


echo "$kernelk_cron_file" > /etc/cron.d/impulse

if [[ $OS_TYPE == 'ubuntu' || $OS_TYPE == 'debian' || $OS_TYPE = "linuxmint" ]]; then
	service cron reload 
	service cron restart 
fi

if [[ $OS_TYPE == 'centos' || $OS_TYPE = "fedora" ]]; then
	service crond reload 
	service crond restart 
fi
