#!/bin/bash

OS_TYPE=$1

if [ -x "$(command -v sestatus)" ]; then

    if [[ $OS_TYPE = "centos" ]]; then
		semodule -i /opt/impulse/build/shared/selinux_policy/impulse_centos_policy.pp
    fi   

    if [[ $OS_TYPE = "fedora" ]]; then
        semodule -i /opt/impulse/build/shared/selinux_policy/impulse_fedora_policy.pp
    fi   
	semodule --reload
else
	echo "No selinux detected."
fi


