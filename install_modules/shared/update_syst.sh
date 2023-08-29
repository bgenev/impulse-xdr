#!/bin/bash

OS_TYPE=$1


if [[ $OS_TYPE = "ubuntu" || $OS_TYPE = "debian" || $OS_TYPE = "linuxmint" ]]; then	
	DEBIAN_FRONTEND=noninteractive apt update -y
	DEBIAN_FRONTEND=noninteractive apt -y install dnsutils net-tools wget curl openssl software-properties-common gcc libc-dev make curl 
	echo 'fs.inotify.max_user_watches=1048576' >> /etc/sysctl.conf # Increase limit for watches. FIM-related
	echo 1048576 > /proc/sys/fs/inotify/max_user_watches
fi

if [[ $OS_TYPE = "centos" ]]; then
	yum update -y
	#yum upgrade -y
	yum install -y net-tools dnsutils
	yum install -y wget curl epel-release openssl
	# software-properties-common ? 
fi

if [[ $OS_TYPE = "fedora" ]]; then
	dnf update -y 
	#dnf upgrade -y
	dnf install -y net-tools dnsutils
	dnf install -y wget curl openssl
fi