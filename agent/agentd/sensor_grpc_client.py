#
# Copyright (c) 2024, Bozhidar Genev,Impulse XDR. All Rights Reserved.    
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import time, json
import grpc
import osquery
import jwt 
import datetime
import time
import subprocess
import schedule
import time 
import threading
import logging
import configparser
import platform

from google.protobuf.json_format import MessageToJson
from manager_grpc_server_pb import manager_grpc_server_pb2, manager_grpc_server_pb2_grpc 

from main.helpers.auth_helper import  verify_access_token
from main.helpers.packs_helper import deploy_pack_to_agent_filesyst
from main.helpers.shared.packs_shared_helper import remove_pack_from_filesyst
from main.helpers.shared.sca_helper import sca_run_method
from main.helpers.shared.active_response_helper import (
	check_can_take_action, 
	take_action, 
	set_blocked_ips_state_manager,
	ensure_impulse_nft_table_exists,
	sync_impulse_fw_with_cs
)
from main.helpers.agent_conf import get_agent_config
from main.helpers.shared.osqueryd_helper import osquery_spawn_instance, osquery_exec, osquery_close_instance
from main.helpers.shared.system_posture_helper import get_agent_system_posture, get_man_page_data
from main.helpers.shared.run_scp_packs_helper import run_scp_packs_helper


LINUX_META_PATH = '/opt/impulse/agentd/main/helpers/meta.json'
WINDWOWS_META_PATH = 'C:\\Program Files\\impulse\\agentd\\main\\helpers\\meta.json'

LINUX_OSQUERY_CONF = '/etc/osquery/osquery.conf'
WINDOWS_OSQUERY_CONF = 'C:\\Program Files\\osquery\\osquery.conf'

LINUX_IMPULSE_CONF = '/opt/impulse/impulse.conf'
WINDOWS_IMPULSE_CONF = 'C:\\Program Files\\impulse\\impulse.conf'

LINUX_GRPC_CERT = '/var/impulse/etc/grpc/tls/ca-cert.pem'
WINDOWS_GRPC_CERT = 'C:\\Program Files\\impulse\\build\\grpc\\tls\\ca-cert.pem'

os_type = platform.system()

if os_type == "Windows":
	IMPULSE_CONF_IN_USE = WINDOWS_IMPULSE_CONF
	META_PATH_IN_USE = WINDWOWS_META_PATH
	OSQUERY_CONF_IN_USE = WINDOWS_OSQUERY_CONF
	GRPC_CERT_IN_USE = WINDOWS_GRPC_CERT
else:
	IMPULSE_CONF_IN_USE = LINUX_IMPULSE_CONF
	META_PATH_IN_USE = LINUX_META_PATH
	OSQUERY_CONF_IN_USE = LINUX_OSQUERY_CONF	
	GRPC_CERT_IN_USE = LINUX_GRPC_CERT	


config = configparser.ConfigParser()
config.read(IMPULSE_CONF_IN_USE)

#config = get_agent_config()
ip_manager = str(config.get('Env','IP_MANAGER') )
#ip_agent = str(config.get('Env','AGENT_IP') )
ip_agent = str(config.get('Env','AGENT_ID') )
agent_type = str(config.get('Env','AGENT_TYPE') )


def load_ca_root_cert():
	with open(GRPC_CERT_IN_USE, 'rb') as f:
		key_file = grpc.ssl_channel_credentials(f.read())
	return key_file

ca_root_cert = load_ca_root_cert()

channel_options = [
	("grpc.keepalive_time_ms", 8000),
	("grpc.keepalive_timeout_ms", 5000),
	("grpc.http2.max_pings_without_data", 0),
	("grpc.keepalive_permit_without_calls", True)
]

def exec_osqueryd(osquery_query):
	instance = osquery.SpawnInstance()
	instance.open()  
	results_obj = instance.client.query(osquery_query)
	results = results_obj.response
	return results 


def start_main_thread(streaming_stub):
	print("[MAIN THREAD STARTED] ...")
	subscribe_sent = False
	while True:
		if subscribe_sent == False:
			request_iterator = iter([ 
				manager_grpc_server_pb2.TasksInterfaceRequest(req_type="subscribe", agent_id=ip_agent),
				manager_grpc_server_pb2.TasksInterfaceRequest(req_type="tasks_check", agent_id=ip_agent)
			])
			subscribe_sent = True
		else:
			request_iterator = iter([ 
				manager_grpc_server_pb2.TasksInterfaceRequest(req_type="tasks_check", agent_id=ip_agent)
			])				

		response_iterator = streaming_stub.TasksInterface(request_iterator)

		for response in response_iterator:
			task_code = response.task_code	
			task_target_agent_id = response.task_target_agent_id
			args = json.loads( response.args )
			task_id = response.task_id	
			try:
				if task_code == "fleet_query":
					osquery_query = args['query']
					result_dict = exec_osqueryd(osquery_query)
					result = json.dumps(result_dict)

				elif task_code == "system_posture":
					syst_posture_queries = args['syst_posture_queries']
					result = get_agent_system_posture(syst_posture_queries)	
					result = json.dumps(result)	

				elif task_code == "gather_installed_packages":
					args = json.loads( response.args )
					all_packages = {'python_packages': exec_osqueryd("select * from python_packages")}
					#result = json.dumps(result)
					pass 	

				elif task_code == "man_page":
					service_name = args['service_name']
					service_data = get_man_page_data(service_name)
					result = json.dumps(service_data)	

				elif task_code == "sca_report":
					checks_dict = args['checks_dict']
					sca_results = sca_run_method(checks_dict)		
					result = json.dumps(sca_results)			

				elif task_code == "inventory_item":
					pass 

				elif task_code == "check_can_take_action":
					indicator_name = args['indicator_name']
					target_param = args['target_param']
					target_agent_ip = args['target_agent_ip']

					respJson = check_can_take_action(
						indicator_name, 
						target_param, 
						target_agent_ip
					)				
					result = json.dumps(respJson) 


				elif task_code == "take_action":
					indicator_name = args['indicator_name']
					target_param = args['target_param']
					target_agent_ip = args['target_agent_ip']

					action_subprocess_success, action_subprocess_msg, action_success_check = take_action(
						indicator_name, 
						target_param, 
						target_agent_ip
					)
					respJson = {
						"action_subprocess_success": action_subprocess_success,
						"action_subprocess_msg": action_subprocess_msg,
						"action_success_check": action_success_check
					}
					result = json.dumps(respJson) 

				elif task_code == "sensor_status_check":
					respJson = {
						"status": True
					}
					result = json.dumps(respJson) 

				elif task_code == "firewall_sync":
					nft_ruleset_content = args['nft_ruleset_content']
					state_action = args['state_action']
					sync_impulse_fw_with_cs(nft_ruleset_content, state_action)
					respJson = {
						"status": 200
					}
					result = json.dumps(respJson) 

				elif task_code == "osquery_core_ruleset_sync":
					core_pack_data = args['pack_data']
					pack_version = args['pack_version']

					with open(OSQUERY_CONF_IN_USE, "w") as jsonFile:
						json.dump(core_pack_data, jsonFile, indent=4)
					subprocess.Popen(['systemctl', 'restart', 'osqueryd'])

					respJson = {
						"status": 200,
						"pack_version": pack_version
					}
					result = json.dumps(respJson) 

				else:
					pass 
				
				print("Task return result: ", result)

			except Exception as e:
				print("exception doing task: ", e)
				pass 

		request_iterator = iter([ manager_grpc_server_pb2.TasksInterfaceRequest(
			req_type="returns_results", 
			result=result,
			agent_id=ip_agent,
			task_id=task_id,
			task_code=task_code
		)])		

		response_iterator = streaming_stub.TasksInterface(request_iterator)
		time.sleep(1)


def run():
	with grpc.secure_channel(
		target=ip_manager + ':50052', 
		options=channel_options,
		credentials=ca_root_cert
	) as channel:
		streaming_stub = manager_grpc_server_pb2_grpc.GrpcServerStub(channel)
		#unary_stub = manager_grpc_server_pb2_grpc.GrpcServerStub(channel)
		start_main_thread(streaming_stub)

if __name__ == '__main__':
	try:
		print("[START SENSOR CLIENT]..")
		run()
	except Exception as e:
		print("__main__: ", e)
		logging.debug('[SERVICE EXITING] logs:', e)

