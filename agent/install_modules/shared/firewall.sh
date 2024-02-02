#!/bin/bash

PACKAGE_MGR=$1


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
