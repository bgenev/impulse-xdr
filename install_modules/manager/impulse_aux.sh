#!/bin/bash


PROJECT_ROOT_DIR=$1


cd $PROJECT_ROOT_DIR/aux_server

rm -rf aux-venv
python3 -m venv aux-venv
source aux-venv/bin/activate
pip3 install --no-cache-dir wheel
pip3 install --no-cache-dir -r requirements.txt