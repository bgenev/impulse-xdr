#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import os, json
import subprocess


def deploy_pack_to_agent_filesyst(pack_file_path, pack_data):

	check_for_old_file = os.path.isfile(pack_file_path)
	
	if check_for_old_file == True:
		os.remove(pack_file_path) 
	else:
		pass

	with open(pack_file_path, "w") as json_file:
		json_file.write(json.dumps(pack_data, indent=4))
		json_file.close()

	check_file = os.path.isfile(pack_file_path)

	if check_file == True:
		pack_deployed_success = True
		pack_deployed_msg = 'Pack deployed successfully.'	
	else:
		pack_deployed_success = False
		pack_deployed_msg = 'Could not create pack file.'

	subprocess.Popen(['systemctl', 'restart', 'osqueryd'])

	return pack_deployed_success, pack_deployed_msg