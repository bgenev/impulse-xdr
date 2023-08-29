#!/bin/bash


pythCurrentVer="$(python3 -V | cut -d " " -f 2 | cut -d "." -f 2)"

if [[ $pythCurrentVer -ge 7 ]]; then
	PYTH_USE_SYST_VER="true"
else 
	PYTH_USE_SYST_VER="false"
fi

echo "${PYTH_USE_SYST_VER}"