
from main.helpers.shared.osqueryd_helper import osquery_spawn_instance, osquery_exec
from main.helpers.shared.agent_conf import get_agent_config


config = get_agent_config()


def gen_query_based_on_type(test_query, query_type):
	test_1_record_success = "SELECT CASE WHEN COUNT(*) = 1 THEN 'Passing' ELSE 'Failing' END AS state "
	test_0_records_success = "SELECT CASE WHEN COUNT(*) = 0 THEN 'Passing' ELSE 'Failing' END AS state "
	if query_type == "positive_success":
		test_query = test_1_record_success + test_query
	elif query_type == "negative_success":
		test_query = test_0_records_success + test_query
	else:
		pass 
	return test_query


def sca_run_method(sca_checks):
	all_tests = []
	ip_agent = config.get('Env','IP_MANAGER')
	
	instance = osquery_spawn_instance()

	for rule in sca_checks:
		try:
			rule_id = rule['id']
			name = rule['name']
			test_query = rule['test_query']
			query_type = rule['query_type']
			test_query = gen_query_based_on_type(test_query, query_type)	

			rule_enabled = rule['enabled']

			if rule_enabled == True:
				test_result = osquery_exec(instance, test_query)
				test_state = test_result[0]['state']
				test_obj = {"id": rule_id, "name": name, "result": test_state}	
				all_tests.append(test_obj)
			else:
				test_obj = {"id": rule_id, "name": name, "result": "Disabled"}	
				all_tests.append(test_obj)
		except:
			exception_obj = {"id": rule_id,"name": name, "result": "Failing"}
			all_tests.append(exception_obj)
			test_state = 'Failing'

	return all_tests










