#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import configparser


def get_agent_config():
	config = configparser.ConfigParser()
	config.read('/opt/impulse/impulse.conf')
	return config