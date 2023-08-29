#!/bin/bash


PACKAGE_MGR=$1

if [[ $PACKAGE_MGR = "deb" ]]; then 
    FIREWALL_BACKEND="ufw"
else 
    FIREWALL_BACKEND="firewalld"
fi


echo "${FIREWALL_BACKEND}"