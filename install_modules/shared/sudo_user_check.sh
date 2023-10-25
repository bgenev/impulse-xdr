#!/bin/bash


user_id=$(id -u)
if [[ $user_id > 0 ]] 
  then echo "Please run as root."
  exit
fi

