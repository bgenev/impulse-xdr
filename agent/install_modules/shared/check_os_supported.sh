#!/bin/bash


OS_TYPE=$1


if [[ $OS_TYPE != "ubuntu" && $OS_TYPE != "centos" && $OS_TYPE != "debian" && $OS_TYPE != "fedora" && $OS_TYPE != "linuxmint" ]]; then
	echo $OS_TYPE" is not supported. Supported distributions: Ubuntu, Debian, Mint, CentOS and Fedora."
	exit
fi


if [ $OS_TYPE = "ubuntu" ]; then
	ubuntu_version=$(cat /etc/os-release | grep VERSION_ID | cut -d"=" -f 2 | tr -d '"')
if [[ ! $ubuntu_version > "16" ]]; then 
	echo "Ubuntu version " $ubuntu_version " not supported. Supports 16.04+ LTS. Recommend: 18.04+ LTS"
	exit 
else
	echo $ubuntu_version" version is supported."
fi
fi


if [ $OS_TYPE = "centos" ]; then
centos_major_version=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1 | tr -d '"')
if [[ ! $centos_major_version > "6" ]]; then 
	echo "CentOS version " $centos_major_version " not supported. 
		  Supported CentOS versions: 7,8,9+"
	exit 
else
	echo "CentOS "$centos_major_version" version is supported."
fi
fi


if [ $OS_TYPE = "debian" ]; then
debian_major_version=$(cat /etc/debian_version | tr -d '"')
if [[ ! $debian_major_version > "8" ]]; then 
	echo "Debian version " $debian_major_version " not supported. 
		  Supported Debian versions: 9,10+ "
	exit 
else
	echo "Debian "$debian_major_version" version is supported."
fi
fi


if [ $OS_TYPE = "fedora" ]; then
fedora_major_version=$(cat /etc/fedora-release | tr -dc '0-9.'|cut -d \. -f1 | tr -d '"')
if [[ ! $fedora_major_version > "35" ]]; then 
	echo "Fedora version " $fedora_major_version " not supported. 
		  Supported Fedora versions: 36+"
	exit 
else
	echo "Fedora "$fedora_major_version" version is supported."
fi
fi


if [ $OS_TYPE = "linuxmint" ]; then
mint_major_version=$(cat /etc/os-release | grep VERSION_ID | cut -d"=" -f 2 | tr -d '"')
if [[ ! $mint_major_version > "20" ]]; then 
	echo "Linux Mint version " $mint_major_version " not supported. 
		  Supported Fedora versions: 20+"
	exit 
else
	echo "Linux Mint "$mint_major_version" version is supported."
fi
fi