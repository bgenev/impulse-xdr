#!/bin/bash


IP_MANAGER=$1
AGENT_TYPE=$2
HOST_INTERFACE=$3


read -p "Host IP Address: $IP_MANAGER (y/n)? " CONT
if [ "$CONT" = "y" ]; then
  echo $IP_MANAGER" confirmed. Continue.";

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

echo -e "Applying configurations and starting the build process. 
It should take 7-12 mins to build depending on your internet speed and hardware."

sleep 1