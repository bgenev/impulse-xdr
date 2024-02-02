import osquery


def osquery_spawn_instance():
	instance = osquery.SpawnInstance() 	
	instance.open() 
	return instance 

def osquery_close_instance(instance):
	instance.close() 
	pass 

def osquery_exec(instance, osquery_string):
	results_obj = instance.client.query(osquery_string)
	result = results_obj.response	
	return result 