#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse xSIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import json 

pack_file_path = '/opt/impulse/managerd/main/helpers/data/sca_checks.json'

def get_cis_compliance_checks():
	with open(pack_file_path, 'r') as json_file:
		checks_data = json.load(json_file)
		json_file.close()
	return checks_data





# def mod_sca_checks():
# 	sca_checks = get_cis_compliance_checks()

# 	new_checks_dict = []
# 	for item in sca_checks:
# 		item['enabled'] = True
# 		new_checks_dict.append(item)

# 	with open('./data/mod_sca_checks.json', 'w') as json_file:
# 		json_file.write(json.dumps(new_checks_dict, indent=4))
# 		json_file.close()	


# mod_sca_checks()