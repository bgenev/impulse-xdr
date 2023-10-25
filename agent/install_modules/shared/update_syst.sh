#!/bin/bash

OS_TYPE=$1

# if OS type not detected properly, this won't run!

if [[ $OS_TYPE = "ubuntu" || $OS_TYPE = "debian" || $OS_TYPE = "linuxmint" ]]; then	
	apt update -y
	apt -y install net-tools wget curl openssl software-properties-common gcc libc-dev make curl 
	echo 'fs.inotify.max_user_watches=1048576' >> /etc/sysctl.conf # Increase limit for watches. FIM-related
	echo 1048576 > /proc/sys/fs/inotify/max_user_watches
fi

if [[ $OS_TYPE = "centos" ]]; then
	yum update -y
	#yum upgrade -y
	yum install -y net-tools
	yum install -y wget curl epel-release openssl
	# software-properties-common ? 
fi

if [[ $OS_TYPE = "fedora" ]]; then
	dnf update -y 
	#dnf upgrade -y
	dnf install -y net-tools
	dnf install -y wget curl openssl
fi