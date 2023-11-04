#!/bin/bash

OS_TYPE=$1


if [ -x "$(command -v docker)" ]; then
    echo "Docker installed..Continue.."
else
    echo "Docker not installed.."

	if [[ $OS_TYPE = "ubuntu" || $OS_TYPE = "debian" || $OS_TYPE = "centos" || $OS_TYPE = "linuxmint" || $OS_TYPE = "fedora" ]]; then
		echo "Continue.. " # will auto-install Docker
	else
		echo "We don't support Docker auto-install for your OS. Please check Docker documentation and set it up for your specific environment."
		echo "Exiting.."
		exit
	fi

	# read -p "Should Impulse install Docker on your system (y/n)? " CONT

	# if [ "$CONT" = "y" ]; then
	# 	echo "Ok.."

	# 	if [[ $OS_TYPE = "ubuntu" || $OS_TYPE = "debian" || $OS_TYPE = "centos" || $OS_TYPE = "linuxmint" || $OS_TYPE = "fedora" ]]; then
	# 		echo "Continue.."
	# 	else
	# 		echo "We don't support Docker auto-install for your OS. Please check Docker documentation and set it up for your specific environment."
	# 		echo "Exiting.."
	# 		exit
	# 	fi

	# elif [ "$CONT" = "n" ]; then
	# 	echo "No. Please install Docker and docker-compose, then try again. Exiting..";
	# 	exit 
	# else 
	# 	echo "Invalid option."
	# 	exit 
	# fi

fi 
