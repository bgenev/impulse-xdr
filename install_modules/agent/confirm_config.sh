#!/bin/bash


AGENT_IP=$1
AGENT_TYPE=$2
AGENT_ID=$3
HOST_INTERFACE=$4

read -p "Agent IP Address: $AGENT_IP (y/n)? " CONT
if [ "$CONT" = "y" ]; then
  echo $AGENT_IP" confirmed. Continue.";

elif [ "$CONT" = "n" ]; then
  echo "No. Please check your environment and modify impulse.conf";
  exit 
else 
  echo "Invalid option."
  exit 
fi

read -p "Agent type: $AGENT_TYPE (y/n)? " CONT
if [ "$CONT" = "y" ]; then
  echo $AGENT_TYPE" confirmed. Continue.";

elif [ "$CONT" = "n" ]; then
  echo "No. Please check your environment and modify impulse.conf";
  exit
else
  echo "Invalid option."
  exit
fi

read -p "Agent ID: $AGENT_ID (y/n)? " CONT
if [ "$CONT" = "y" ]; then
  echo $AGENT_ID" confirmed. Continue.";

elif [ "$CONT" = "n" ]; then
  echo "No. Please check your environment and modify impulse.conf";
  exit
else
  echo "Invalid option."
  exit
fi


if [[ $AGENT_TYPE == 'heavy' ]]; then
	read -p "Network interface: $HOST_INTERFACE (y/n)? " CONT
	if [ "$CONT" = "y" ]; then
		echo $HOST_INTERFACE" confirmed. Continue.";
	elif [ "$CONT" = "n" ]; then
		echo "No. Please check your environment and modify impulse.conf";
		exit
	else
		echo "Invalid option."
		exit
	fi
fi


echo -e "Applying configurations and starting the build process. 
It should take 2-4 mins to install."

sleep 1