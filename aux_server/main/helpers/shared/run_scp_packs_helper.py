
from main.helpers.shared.osqueryd_helper import osquery_spawn_instance, osquery_exec


negative_success_query_prefix = "SELECT CASE WHEN COUNT(*) = 0 THEN 'Passing' ELSE 'Failing' END AS state";
positive_success_query_prefix = "SELECT CASE WHEN COUNT(*) > 0 THEN 'Passing' ELSE 'Failing' END AS state";


def run_scp_packs_helper(deployed_packs):
    all_tests = []
    instance = osquery_spawn_instance()

    for item in deployed_packs:
        pack_name = item['pack_name']
        queries_list = item['queries_list']

        pack_results = []

        for rule in queries_list:
            query_id = rule['query_id']
            name = rule['name']
            query_string = rule['query_string']
            query_type = rule['query_type']

            try:
                test_query = gen_test_query(query_string, query_type)
                test_result = osquery_exec(instance, test_query)

                test_state = test_result[0]['state']
                test_obj = {"query_id": query_id, "name": name, "result": test_state }	
                pack_results.append(test_obj)
            except Exception as e:
                print(e)
                exception_obj = {"query_id": query_id, "name": name, "result": "Failing" }
                pack_results.append(exception_obj)

        all_tests.append({
            "pack_name": pack_name, 
            "pack_results": pack_results 
        })

    return all_tests


def gen_test_query(query_string, query_type):
	query_string_suffix = query_string.split(" from ")
	query_string_suffix = query_string_suffix[1]
	if query_type == 'negative_success':
		test_query = negative_success_query_prefix + " from " + query_string_suffix
	else:
		test_query = positive_success_query_prefix + " from " + query_string_suffix 
	return test_query