#
# Copyright (c) 2024, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import configparser

LINUX_IMPULSE_CONF = '/opt/impulse/impulse.conf'
WINDOWS_IMPULSE_CONF = 'C:\\Program Files\\impulse\\impulse.conf'


def get_agent_config():
	config = configparser.ConfigParser()
	config.read(LINUX_IMPULSE_CONF)
	return config