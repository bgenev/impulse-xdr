#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse xSIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import os, json 

from sca_checks import checks_dict


new_checks_dict = []

for item in checks_dict:

    test_query = item['test_query']

    if 'positive_success' in test_query:
        item['query_type'] = "positive_success"
        item['test_query'] = test_query.replace("positive_success", "")

    elif 'negative_success' in test_query:
        item['query_type'] = "negative_success"
        item['test_query'] = test_query.replace("negative_success", "")
    else:
        pass 

    new_checks_dict.append(item)



with open('./data/sca_checks.json', 'w') as json_file:
    json_file.write(json.dumps(new_checks_dict, indent=4))
    json_file.close()	