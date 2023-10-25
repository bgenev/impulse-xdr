#!/bin/bash

PYTH_USE_SYST_VER=$1


rm -rf ./venv 
rm -rf __pycache__

if [ "$PYTH_USE_SYST_VER" == "true" ]; then
	python3 -m venv venv 
else
	python3.9 -m venv venv
fi
source venv/bin/activate
pip3 install --no-cache-dir wheel
pip3 install --no-cache-dir -r requirements.txt