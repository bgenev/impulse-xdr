#
# Copyright (c) 2021-2023, Bozhidar Genev. All Rights Reserved. 
#Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

from concurrent import futures 
import time 
import osquery
import json 
import subprocess
import grpc
from functools import wraps
from main.grpc_pb import grpc_gateway_pb2, grpc_gateway_pb2_grpc
from google.protobuf.struct_pb2 import Struct
from main.helpers.auth_helper import  verify_access_token
from main.helpers.packs_helper import deploy_pack_to_agent_filesyst
from main.helpers.shared.packs_shared_helper import remove_pack_from_filesyst
from main.helpers.shared.sca_helper import sca_run_method
from main.helpers.shared.active_response_helper import (
	check_can_take_action, 
	take_action, 
	set_blocked_ips_state_manager,
	ensure_impulse_nft_table_exists
)
from main.helpers.agent_conf import get_agent_config
from main.helpers.shared.osqueryd_helper import osquery_spawn_instance, osquery_exec, osquery_close_instance
from main.helpers.shared.system_posture_helper import get_agent_system_posture, get_man_page_data
from main.helpers.shared.run_scp_packs_helper import run_scp_packs_helper


config = get_agent_config()
ip_manager = str(config.get('Env','IP_MANAGER') )
ip_agent = str(config.get('Env','IP_AGENT') )

available_packs_dir = '/opt/impulse/build/osquery/mitre/'
active_packs_dir = '/etc/osquery/packs/'
core_packs_dir = '/etc/osquery/packs/core/' 
premium_packs_dir = '/etc/osquery/packs/prpemium/'
custom_packs_dir = '/etc/osquery/packs/custom/'
osquery_conf = '/etc/osquery/osquery.conf'
suricata_community_rules_filepath = '/var/impulse/lib/suricata/rules/suricata.rules'
suricata_custom_rules_filepath = '/var/impulse/lib/suricata/rules/custom.rules'

executor = futures.ThreadPoolExecutor(2)

def load_grpc_server_keys():
    with open('/opt/impulse/build/agent/grpc/tls/server-key.pem', 'rb') as f:
        private_key = f.read()
        
    with open('/opt/impulse/build/agent/grpc/tls/server-cert.pem', 'rb') as f:
        certificate_chain = f.read()
    return private_key, certificate_chain

def exec_osqueryd(osquery_query):
	instance = osquery.SpawnInstance()
	instance.open()  
	results_obj = instance.client.query(osquery_query)
	results = results_obj.response
	return results 

def json_to_string(data):
	return json.dumps(data)

def string_to_json(data):
	return json.loads(data)


def run_osquery_on_agent(request, context):
	osquery_query = request.osquery_query 
	results = exec_osqueryd(osquery_query)
	osquery_results = json_to_string(results)
	osquery_response = grpc_gateway_pb2.RunOSqueryOnAgentResponse(osquery_results=osquery_results)
	return osquery_response        


def firewall_management_task(ips_list, state_action):
	set_blocked_ips_state_manager(ips_list, state_action)


def firewall_management_state_agent(request, context):
	try:
		ips_list = request.ips_list
		state_action = request.state_action

		executor.submit( firewall_management_task, ips_list, state_action )
	except Exception as e:
		print("firewall_management_state_agent error: ", e)
		pass 
	resp = grpc_gateway_pb2.FirewallManagementStateResponse(task_results='done')
	return resp 


def check_agent_status(request, context):
	get_system_info = request.get_system_info
	if get_system_info == True:

		osq_instance = osquery.SpawnInstance()
		osq_instance.open() 
		results_obj = osq_instance.client.query("select * from os_version;")
		results = results_obj.response[0]
		os_type = results['name']
		os_type_verbose = results['version']

		system_info_obj = {"os_type": os_type, "os_type_verbose": os_type_verbose}
		system_info=json_to_string(system_info_obj)
	else:
		system_info = 'None' 

	print("check system_info for agent: ", system_info)

	resp = grpc_gateway_pb2.CheckAgentStatusResponse(agent_status='success', system_info=system_info )

	return resp  


def deploy_pack_on_agent(request, context):
	pack_data = string_to_json(request.pack_data)
	filename = request.filename

	pack_file_path = custom_packs_dir + filename + '.conf'
	pack_deployed_success, pack_deployed_msg = deploy_pack_to_agent_filesyst(pack_file_path, pack_data)
	
	resp = grpc_gateway_pb2.DeployPackOnAgentResponse(
		pack_deployed_success=pack_deployed_success,
		pack_deployed_msg=pack_deployed_msg
	)
	return resp   


def core_osq_pack_update(request, context):
	pack_data = string_to_json(request.pack_data)
	try:
		with open(osquery_conf, "w") as jsonFile:
			json.dump(pack_data, jsonFile, indent=4)

		subprocess.Popen(['systemctl', 'restart', 'osqueryd'])
		status = 200
		result = "Pack was updated."
	except Exception as e:
		print(e)
		status = 301
		result = "Could not update core pack."	

	resp = grpc_gateway_pb2.CoreOsqPackUpdateResponse(
		status=status,
		result=result
	)	
	return resp


def delete_pack_on_agent(request, context):
	pack_name = request.name
	pack_file_path = custom_packs_dir + pack_name + '.conf'
	filesyst_pack_removal_status, filesyst_pack_removal_msg = remove_pack_from_filesyst(pack_file_path)

	resp = grpc_gateway_pb2.DeletePackOnAgentResponse(
		filesyst_pack_removal_status=filesyst_pack_removal_status,
		filesyst_pack_removal_msg=filesyst_pack_removal_msg
	)	
	return resp


def take_action_agent(request, context):
	indicator_name = request.indicator_name
	target_param = request.target_param
	target_agent_ip = request.target_agent_ip

	action_subprocess_success, action_subprocess_msg, action_success_check = take_action(indicator_name, target_param, target_agent_ip)
	
	resp = grpc_gateway_pb2.TakeActionAgentResponse(
		action_subprocess_success=action_subprocess_success,
		action_subprocess_msg=action_subprocess_msg,
		action_success_check=action_success_check
	)	
	return resp


def check_can_take_action_agent(request, context):
	indicator_name = request.indicator_name
	target_param = request.target_param
	target_agent_ip = request.target_agent_ip
	
	respJson = check_can_take_action(indicator_name, target_param, target_agent_ip) #respJson = { "state": False, "msg": msg }

	resp = grpc_gateway_pb2.CheckCanTakeActionAgentResponse(
		state=respJson['state'],
		msg=respJson['msg'],
	)	
	return resp


def receive_sca_scan_req(request, context):
	checks_dict = string_to_json(request.checks_dict)
	sca_results = sca_run_method(checks_dict)

	resp = grpc_gateway_pb2.ReceiveScaScanReqResponse(
		tests_results=json_to_string(sca_results)
	)	
	return resp


def agent_system_posture(request, context):
	syst_posture_queries = string_to_json(request.syst_posture_queries)
	result = get_agent_system_posture(syst_posture_queries)
	
	resp = grpc_gateway_pb2.AgentSystemPostureResponse(
		osquery_results=json_to_string(result)
	)	
	return resp


def run_policy_pack_queries(request, context):
	deployed_packs = string_to_json(request.deployed_packs)	
	all_tests = run_scp_packs_helper(deployed_packs)
	
	resp = grpc_gateway_pb2.RunPolicyPackQueriesResponse(
		report_results=json_to_string(all_tests)
	)	
	return resp


def get_service_data(request, context):
	service_name = request.service_name	
	service_data = get_man_page_data(service_name)
	
	resp = grpc_gateway_pb2.GetServiceDataResponse(
		service_data=json_to_string(service_data)
	)	
	return resp


def suricata_custom_ruleset_sync(request, context):
	ruleset_data = request.ruleset_data	
	
	with open(suricata_custom_rules_filepath, "w") as f:
		for line in ruleset_data:
			f.write(line)
	
	subprocess.run("docker exec -it  impulse-suricata suricatasc -c ruleset-reload-nonblocking", shell=True)
	subprocess.run("systemctl restart impulse-nids", shell=True)

	resp = grpc_gateway_pb2.SuricataCustomRulesetSyncResponse(
		status=True
	)	

	print(resp)
	return resp



class GrpcGatewayServicer(grpc_gateway_pb2_grpc.GrpcGatewayServicer):

	def RunOSqueryOnAgent(self, request, context):	
		return run_osquery_on_agent(request, context)

	def FirewallManagementState(self, request, context):
		return firewall_management_state_agent(request, context)
   
	def CheckAgentStatus(self, request, context):  
		return check_agent_status(request, context)

	def DeployPackOnAgent(self, request, context):
		return deploy_pack_on_agent(request, context)
  
	def CoreOsqPackUpdate(self, request, context):
		return core_osq_pack_update(request, context)

	def DeletePackOnAgent(self, request, context):
		return delete_pack_on_agent(request, context)

	def TakeActionAgent(self, request, context):
		return take_action_agent(request, context)
	
	def CheckCanTakeActionAgent(self, request, context):
		return check_can_take_action_agent(request, context)	
	
	def ReceiveScaScanReq(self, request, context):
		return receive_sca_scan_req(request, context)	

	def AgentSystemPosture(self, request, context):
		return agent_system_posture(request, context)	

	def RunPolicyPackQueries(self, request, context):
		return run_policy_pack_queries(request, context)

	def GetServiceData(self, request, context):
		return get_service_data(request, context)
	
	def SuricataCustomRulesetSync(self, request, context):
		return suricata_custom_ruleset_sync(request, context)


class AuthInterceptor(grpc.ServerInterceptor):
	def __init__(self, key):

		def deny(_, context):
			context.abort(grpc.StatusCode.UNAUTHENTICATED, 'Invalid access token.')

		self._deny = grpc.unary_unary_rpc_method_handler(deny)

	def intercept_service(self, continuation, handler_call_details):
		try:
			meta = handler_call_details.invocation_metadata
			metadict = dict(meta)
			access_token = metadict['access_token']
			key_verified = verify_access_token(access_token)
		except:
			key_verified = False
		
		if key_verified == True:
			return continuation(handler_call_details)
		else:
			return self._deny


def check_service_active(service_name, osq_instance):
	results_obj = osq_instance.client.query(
		"SELECT CASE WHEN COUNT(*) > 0 THEN 'Passing' ELSE 'Failing' END AS state from startup_items where name = '" + service_name + "' and status = 'active';"
	)
	osq_check_result = results_obj.response[0]['state']
	return osq_check_result


def check_impulse_agent_port_open(osq_instance):
	results_obj = osq_instance.client.query(
		"SELECT CASE WHEN COUNT(*) > 0 THEN 'Passing' ELSE 'Failing' END AS state from iptables where src_ip = '" + ip_manager + "' and dst_port LIKE '%50051%' and target LIKE '%ACCEPT%'"
	)
	osq_check_result = results_obj.response[0]['state']
	return osq_check_result	

	
def serve():
	print("Agent grpc server started..")
	server = grpc.server(
		futures.ThreadPoolExecutor(max_workers=10), 
		interceptors=(AuthInterceptor('access_token'),) 
	)
	private_key, certificate_chain = load_grpc_server_keys()
	server_credentials = grpc.ssl_server_credentials( ( (private_key, certificate_chain), ) )
	grpc_gateway_pb2_grpc.add_GrpcGatewayServicer_to_server(GrpcGatewayServicer(), server)
	server.add_secure_port('0.0.0.0:50051', server_credentials)
	server.start()
	server.wait_for_termination()


if __name__ == "__main__":
	ensure_impulse_nft_table_exists()
	serve()
	










# def verify_fw_open_for_manager():
# 	osq_instance = osquery.SpawnInstance()
# 	osq_instance.open() 

# 	ufw_active = check_service_active("ufw.service", osq_instance)
# 	firewalld_active = check_service_active("ufw.service", osq_instance)
# 	impulse_agent_port_open = check_impulse_agent_port_open(osq_instance)

# 	if ufw_active == 'Passing':
# 		if impulse_agent_port_open == 'Failing':
# 			subprocess.run("ufw allow from " + ip_manager + " proto tcp to any port 50051", shell=True)
# 			subprocess.run("systemctl restart ufw", shell=True)
# 		else:
# 			pass

# 	elif firewalld_active == 'Passing':
# 		if impulse_agent_port_open == 'Failing':
# 			subprocess.run("firewall-cmd --permanent --new-zone=impulse_siem", shell=True)
# 			subprocess.run("firewall-cmd --zone=impulse_siem --add-source=" + ip_manager + " --permanent", shell=True)
# 			subprocess.run("firewall-cmd --reload", shell=True)
# 		else:
# 			pass 
# 	else:
# 		pass

# 	if impulse_agent_port_open == 'Failing':
# 		subprocess.run("iptables -I INPUT -p tcp -s " + ip_manager + " --dport 50051 -j ACCEPT", shell=True)
# 	else:
# 		pass 
	
# 	pass 