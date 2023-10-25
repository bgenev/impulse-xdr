#!/bin/bash

SYSTD_ACTION=$1

cd /opt/impulse
NIDS_MODE=$(awk -F "=" '/NIDS_MODE/ {print $2}' impulse.conf | tr -d ' ')
IPS_SETUP=$(awk -F "=" '/IPS_SETUP/ {print $2}' impulse.conf | tr -d ' ')
IPS_MODE_PORTS=$(awk -F "=" '/IPS_MODE_PORTS/ {print $2}' impulse.conf | tr -d ' ')


if [[ $SYSTD_ACTION == 'start' ]]; then	

    if [[ $NIDS_MODE == 'IPS' ]]; then	

        if [[ $IPS_SETUP == 'auto' ]]; then
            iptables -N IMPULSE_IPS
            iptables -I IMPULSE_IPS -j NFQUEUE --queue-balance 0:1 --queue-bypass
            iptables -A INPUT -p tcp -m multiport --dports $IPS_MODE_PORTS -j IMPULSE_IPS
            iptables -A OUTPUT -p tcp -m multiport --dports $IPS_MODE_PORTS -j IMPULSE_IPS
        else
            echo "You have selected manual IPS_SETUP, please use iptables to specify what traffic should be forwarded to the IPS. Refer to the documentation."
        fi 

        sed -i 's/-i ${HOST_INTERFACE}/-q 0 -q 1/g' ./docker-compose-nids.yml
    else 
        sed -i 's/-q 0 -q 1/-i ${HOST_INTERFACE}/g' ./docker-compose-nids.yml
    fi

    /usr/local/bin/docker-compose --file ./docker-compose-nids.yml --env-file ./impulse.conf up

elif [[ $SYSTD_ACTION == 'stop' ]]; then	

    if [[ $NIDS_MODE == 'IPS' ]]; then	

        if [[ $IPS_SETUP == 'auto' ]]; then
            iptables -D INPUT -p tcp -m multiport --dports $IPS_MODE_PORTS -j IMPULSE_IPS
            iptables -D OUTPUT -p tcp -m multiport --dports $IPS_MODE_PORTS -j IMPULSE_IPS
            iptables -F IMPULSE_IPS
            iptables -X IMPULSE_IPS
        else
            echo "IPS_SETUP, continue."
        fi 

        echo "IPS mode"
    else 
        echo "IDS mode, no chains to delete. Continue.."
    fi

    docker stop impulse-suricata 
    docker rm impulse-suricata

    /usr/local/bin/docker-compose --file ./docker-compose-nids.yml --env-file ./impulse.conf down

else
    echo "Specify stop or start argument."
fi 



# start
# iptables -N IMPULSE_IPS_INPUT
# iptables -N IMPULSE_IPS_OUTPUT
# iptables -I IMPULSE_IPS_INPUT -j NFQUEUE --queue-num 0 --queue-bypass
# iptables -I IMPULSE_IPS_OUTPUT -j NFQUEUE --queue-num 1 --queue-bypass

# # for i in $(echo $IPS_MODE_PORTS | sed "s/,/ /g")
# # do
# #     iptables -I INPUT -p tcp --dport "$i" -j IMPULSE_IPS_INPUT
# #     iptables -I OUTPUT -p tcp --dport "$i" -j IMPULSE_IPS_OUTPUT
    
# # done

# # iptables -A INPUT -j IMPULSE_IPS_INPUT
# # iptables -A OUTPUT -j IMPULSE_IPS_OUTPUT   



# stop 
# for i in $(echo $IPS_MODE_PORTS | sed "s/,/ /g")
# do
#     iptables -D INPUT -p tcp --dport "$i" -j IMPULSE_IPS_INPUT
#     iptables -D OUTPUT -p tcp --dport "$i" -j IMPULSE_IPS_OUTPUT
    
# done

# # iptables -D INPUT -j IMPULSE_IPS_INPUT
# # iptables -D OUTPUT -j IMPULSE_IPS_OUTPUT

# iptables -F IMPULSE_IPS_INPUT
# iptables -F IMPULSE_IPS_OUTPUT

# iptables -X IMPULSE_IPS_INPUT
# iptables -X IMPULSE_IPS_OUTPUT