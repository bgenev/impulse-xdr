#!/bin/bash

arch=$(uname -m)
kernel=$(uname -r)

# if [ -n "$(command -v lsb_release)" ]; then
# 	distroname=$(lsb_release -s -d)

# if [ -f "/etc/os-release" ]; then
# 	distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')

if [ -f "/etc/os-release" ]; then
	distroname=$(grep "ID=" /etc/os-release | grep -v "_" | cut -d "=" -f2 | tr -d '"')

elif [ -f "/etc/debian_version" ]; then
	distroname="Debian $(cat /etc/debian_version)"
elif [ -f "/etc/redhat-release" ]; then
	distroname=$(cat /etc/redhat-release)
else
	distroname="$(uname -s) $(uname -r)"
fi

echo "${distroname}"
