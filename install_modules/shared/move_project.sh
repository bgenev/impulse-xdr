#!/bin/bash

PROJECT_ROOT_DIR=$1


# Project must be located in /opt
if [[ $PROJECT_ROOT_DIR != '/opt/impulse' ]]; then 
	echo "Project must be located in /opt/impulse" 
	exit 
	# mkdir -p /opt/impulse -v
	# mv ./* /opt/impulse
	# #cp rf . /opt/impulse
	# cd /opt/impulse
fi