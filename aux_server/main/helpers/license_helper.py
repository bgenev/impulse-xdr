#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse xSIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import os, subprocess
from base64 import b64encode, b64decode 
import jwt
import datetime


def get_dmidecode_system_uuid():
	param1 = "dmidecode -s system-uuid"
	cmd = ['/opt/impulse/tasks_manager/shell_scripts/cmds_helper.sh', param1]
	p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
	
	output = ''
	for line in p.stdout:
		output = output + line.decode()
	p.wait() 
	output = output.strip()

	if p.returncode == 0:
		print(output)
		resp = {"machine_uuid": output, "msg" : True}
	else: 
		resp = {"machine_uuid": None, "msg" : "Could not execute command."} 
	return resp 