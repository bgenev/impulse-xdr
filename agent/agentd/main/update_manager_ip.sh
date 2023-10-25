#!/bin/sh


NEW_MANAGER_IP="192.168.1.154"
FIREWALL_BACKEND="UFW"

sed -i '/:7514/c\*.* @@'$NEW_MANAGER_IP':7514' /var/impulse/etc/rsyslog/rsyslog.conf

systemctl restart impulse-containers impulse-main

if [ "$FIREWALL_BACKEND" == "UFW" ]; then
    #ufw allow from $NEW_MANAGER_IP proto tcp to any port 50051
    ufw allow from $NEW_MANAGER_IP
    ufw allow from 192.168.0.0/16
    ufw --force enable

elif [ "$FIREWALL_BACKEND" == "Firewalld" ]; then
    firewall-cmd --permanent --zone=impulse_siem --add-source=$IP_MANAGER
    firewall-cmd --reload

else
	echo "Unaccounted case. Use UFW"
fi