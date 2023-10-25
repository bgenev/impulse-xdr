#!/bin/bash


if [ -x "$(command -v dpkg)" ]; then
	PACKAGE_MGR="deb"
elif [ -x "$(command -v rpm)" ]; then
	PACKAGE_MGR="rpm"
else
	PACKAGE_MGR="unknown"
fi

echo "${PACKAGE_MGR}"