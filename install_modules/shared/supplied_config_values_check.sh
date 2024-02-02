#!/bin/bash

AGENT_IP=$1
AGENT_TYPE=$2
HOST_INTERFACE=$3


all_ips=$(hostname -I)
arr=($all_ips)

supplied_and_system_ip_match="false"

for element in "${arr[@]}"
do  
    if [[ $element == $AGENT_IP ]]; then
      supplied_and_system_ip_match="true"
    else 
      echo "cont."
    fi
done

# if [[ $supplied_and_system_ip_match == "true" ]]; then
#     echo "Configuration IP matches system value. Continue.."
# else 
#     #echo "Supplied Agent IP from impulse.conf does not match any public or private IP addresses on the system. Exiting..please check that you have supplied the correct system values."
#     exit 
# fi



if [[ $AGENT_TYPE == 'heavy' ]]; then
    interfaces=$(ip link | awk -F: '$0 !~ "lo|vir|vbox|docker|br|tun|^[^0-9]"{print $2;getline}')
    arr=($interfaces)
    supplied_and_system_interface_match="false"

    for element in "${arr[@]}"
    do  
        if [[ $element == $HOST_INTERFACE ]]; then
          supplied_and_system_interface_match="true"
        else 
          echo "cont."
        fi
    done

    if [[ $supplied_and_system_interface_match == "true" ]]; then
        echo "Configuration interface matches system value. Continue.."
    else 
        echo "Supplied interface value in impulse.conf does not match any interfaces on the system. Exiting..please check that you have supplied the correct system values."
        exit
    fi
else 
	echo "Agent is light, not checking interface value.."
fi

