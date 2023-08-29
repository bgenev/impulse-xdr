#!/bin/bash


physical_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
if [[ $physical_mem < "1.5" ]]; then 
	echo "Insufficient physical memory. Min required for the Manager instance: 1.5 GB RAM"
	exit 
else
	echo "Enough memory. Continue..."
fi

