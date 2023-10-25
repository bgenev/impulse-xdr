#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import os, yaml
from main.helpers.shared.agent_conf import get_agent_config


class Development():
	ENV = 'development'
	agent_config = get_agent_config()
	manager_ip_addr = agent_config.get('Env','IP_MANAGER')

	db_pass = agent_config.get('Env','IMPULSE_DB_SERVER_PWD')

	ip_dashes = manager_ip_addr.replace('.', '_')
	db_name = ip_dashes + '_db'

	SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:' + db_pass + '@127.0.0.1:7543/' + db_name 

	SQLALCHEMY_BINDS = {
		'impulse_manager': 'postgresql://postgres:' + db_pass + '@127.0.0.1:7543/impulse_manager'
	}

	SECRET_KEY = 'thisissecret'
	SQLALCHEMY_TRACK_MODIFICATIONS = False 
	DEBUG = True

	APP_EXT_PORT = ':7001'
