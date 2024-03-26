#!/bin/bash

AGENT_TYPE=$1

physical_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
if [[ $physical_mem < "1.5" && $AGENT_TYPE == "heavy" ]]; then 
	echo "Insufficient physical memory. Min required: 1.5 GB RAM"
	exit 
else
	echo "Enough memory. Continue..."
fi

