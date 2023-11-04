#!/bin/bash

SYSTD_ACTION=$1

cd /opt/impulse
IP_MANAGER=$(awk -F "=" '/IP_MANAGER/ {print $2}' impulse.conf | tr -d ' ')



if [[ $SYSTD_ACTION == 'start' ]]; then	
    iptables -I INPUT -p tcp -s $IP_MANAGER --dport 50051 -j ACCEPT || iptables -I INPUT -p tcp -s $IP_MANAGER --dport 50051 -j ACCEPT
    
    /opt/impulse/venv/bin/python3 /opt/impulse/agentd/grpc_server.py

elif [[ $SYSTD_ACTION == 'stop' ]]; then	
    iptables -D INPUT -p tcp -s $IP_MANAGER --dport 50051 -j ACCEPT
else
    echo "Specify stop or start as argument."
fi 
