#!/bin/bash

PROJECT_ROOT_DIR=$1


# Project must be located in /opt
if [[ $PROJECT_ROOT_DIR != '/opt/impulse' ]]; then 
	echo "Project root must be /opt/impulse. Please untar the installation package in /opt" 

	exit 
	# mkdir -p /opt/impulse -v
	# mv $(pwd)/* /opt/impulse
	# #cp rf . /opt/impulse
	# cd /opt/impulse
fi