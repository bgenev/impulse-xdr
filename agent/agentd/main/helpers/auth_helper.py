#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import os, json, time
import os 
import jwt
import osquery
import subprocess
import configparser
from functools import wraps

from main.helpers.agent_conf import get_agent_config


def verify_access_token( access_token ):
	config = get_agent_config()
	agent_pre_shared_key_config = str(config.get('Env','AGENT_SECRET_KEY') )

	if access_token == None:
		key_verified = False
	else:
		pass 

	try:
		## leeway=datetime.timedelta(seconds=10)
		## Expiration time will be compared to the current UTC time 
		## (as given by timegm(datetime.now(tz=timezone.utc).utctimetuple())), so be sure to use a UTC timestamp or datetime in en-coding
		
		decoded_payload = jwt.decode(access_token, agent_pre_shared_key_config, algorithms=["HS256"])
		key_verified = True
	except:
		key_verified = False
	return key_verified

