#!/bin/bash

SETUP_TYPE=$1
IP_MANAGER=$2
PACKAGE_MGR=$3
OS_TYPE=$4
FIREWALL_BACKEND=$5


if [[ $PACKAGE_MGR = "deb" ]]; then
	apt -y install nftables
	systemctl enable nftables
	systemctl start nftables
fi

if [[ $PACKAGE_MGR = "rpm" ]]; then
	dnf -y install nftables
	systemctl enable nftables
	systemctl start nftables
fi

nft add table inet impulse_table
nft add chain inet impulse_table impulse_input_chain '{ type filter hook input priority 0 ; policy accept ; }'
nft add chain inet impulse_table impulse_output_chain '{ type filter hook input priority 0 ; policy accept ; }'
nft flush table inet impulse_table


if [ "$FIREWALL_BACKEND" == "ufw" ]; then
	echo "UFW selected, disable Firewalld"
	
	systemctl stop firewalld
	systemctl disable firewalld 

    if [[ $PACKAGE_MGR  = "deb" ]]; then
		apt-get install -y ufw
    fi

    if [[ $PACKAGE_MGR = "rpm" ]]; then
		yum install -y epel-release
		yum install -y ufw	
    fi 

	systemctl enable ufw
	systemctl start ufw 

	ufw default deny incoming
	ufw default allow outgoing

	ufw allow ssh

	if [[ $SETUP_TYPE == 'manager' ]]; then 		
		ufw allow 7514
		ufw allow 7001
	else 
		ufw allow from $IP_MANAGER proto tcp to any port 50051
	fi

	ufw --force enable

elif [ "$FIREWALL_BACKEND" == "firewalld" ]; then
	echo "Firewalld selected, disable UFW"

	systemctl stop ufw
	systemctl disable ufw 

    if [[ $PACKAGE_MGR = "deb" ]]; then
		apt-get install -y firewalld
    fi
	
    if [[ $PACKAGE_MGR = "rpm" ]]; then
		yum install -y firewalld
    fi 

	systemctl enable firewalld
	systemctl start firewalld 

	firewall-cmd --add-service=ssh --permanent

	if [[ $SETUP_TYPE == 'manager' ]]; then 
		firewall-cmd --permanent --new-zone=impulse_siem
		firewall-cmd --reload
		firewall-cmd --permanent --zone=impulse_siem --add-port=7514/tcp
		firewall-cmd --permanent --zone=impulse_siem --add-port=7001/tcp		
	else 
		firewall-cmd --permanent --new-zone=impulse_siem
		firewall-cmd --reload
		firewall-cmd --permanent --zone=impulse_siem --add-port=50051/tcp
		firewall-cmd --permanent --zone=impulse_siem --add-source=$IP_MANAGER
	fi

	firewall-cmd --reload
else
	echo "Unaccounted case. Continue"
fi

