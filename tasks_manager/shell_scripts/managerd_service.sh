#!/bin/bash

SYSTD_ACTION=$1

cd /opt/impulse
#IP_MANAGER=$(awk -F "=" '/IP_MANAGER/ {print $2}' impulse.conf | tr -d ' ')


if [[ $SYSTD_ACTION == 'start' ]]; then	
   iptables -I INPUT -p tcp -m multiport --dports 7001,7514 -j ACCEPT || iptables -I INPUT -p tcp -m multiport --dports 7001,7514 -j ACCEPT
   iptables -I OUTPUT -p tcp -m multiport --dports 7001,7514 -j ACCEPT || iptables -I OUTPUT -p tcp -m multiport --dports 7001,7514 -j ACCEPT

   /usr/local/bin/docker-compose --file ./docker-compose-manager.yml --env-file ./impulse.conf up

elif [[ $SYSTD_ACTION == 'stop' ]]; then	
    iptables -D INPUT -p tcp -m multiport --dports 7001,7514 -j ACCEPT
    iptables -D OUTPUT -p tcp -m multiport --dports 7001,7514 -j ACCEPT
    
    /usr/local/bin/docker-compose --file ./docker-compose-manager.yml down

else


    echo "Specify stop or start as argument."
fi 
