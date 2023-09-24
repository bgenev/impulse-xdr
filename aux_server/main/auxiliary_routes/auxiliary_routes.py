#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse SIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

from flask import jsonify, request, Flask
from flask_restful import Resource 
from main import app, api
import uuid, datetime
import json
import osquery
import importlib.util
from os import path
import sys
import subprocess
from concurrent.futures import ThreadPoolExecutor

from main.helpers.shared.run_scp_packs_helper import run_scp_packs_helper
from main.helpers.shared.active_response_helper import check_can_take_action, take_action, set_blocked_ips_state_manager
from main.helpers.shared.sca_helper import sca_run_method
from main.helpers.shared.system_posture_helper import get_man_page_data

from main.helpers.license_helper import get_dmidecode_system_uuid

suricata_community_rules_filepath = '/var/impulse/lib/suricata/rules/suricata.rules'
suricata_custom_rules_filepath = '/var/impulse/lib/suricata/rules/custom.rules'
nftables_impulse_table_filepath = '/var/impulse/etc/nftables/nftables_impulse_table.rules'

def osquery_spawn_instance():
	instance = osquery.SpawnInstance() 	
	instance.open() 
	return instance 

def osquery_exec(instance, osquery_string):
	results_obj = instance.client.query(osquery_string)
	return results_obj 

class RunOsqueryManagerHost(Resource):
	def post(self):
		postedData = request.get_json()
		osquery_string = postedData['osquery_string']

		instance = osquery_spawn_instance()
		results_obj = osquery_exec(instance, osquery_string)
		
		osquery_status_code = results_obj.status.code
		osquery_err_message = results_obj.status.message
		response = results_obj.response

		retJson = {
			"osquery_status_code":osquery_status_code,
			"osquery_err_message": osquery_err_message,
			"response": response
		}
		print(retJson)
		return retJson


class SystPostureManagerHost(Resource):
	def post(self):
		postedData = request.get_json()
		syst_posture_queries = postedData['syst_posture_queries']

		instance = osquery_spawn_instance()
		syst_posture_results = {}
		for item in syst_posture_queries:
			results_obj = osquery_exec(instance, item['query'])
			syst_posture_results[ item['name'] ] = results_obj.response
			
		return syst_posture_results


class RunScaScanManagerHost(Resource):
	def post(self):
		postedData = request.get_json()
		checks_dict = postedData['checks_dict']		
		all_tests = sca_run_method(checks_dict)
		return all_tests


class RestartOsquerydManagerHost(Resource):
	def get(self):
		subprocess.Popen(['systemctl', 'restart', 'osqueryd'])
		return None 


class RunScpPacksManagerHost(Resource):
	def post(self):
		postedData = request.get_json()
		deployed_packs = postedData['deployed_packs']
		data = run_scp_packs_helper(deployed_packs)
		return data


class CheckCanTakeActionManagerHost(Resource):
	def post(self):
		postedData = request.get_json()
		indicator_name = postedData['indicator_name']
		target_param = postedData['target_param']
		target_agent_ip = postedData['target_agent_ip']
		respJson = check_can_take_action(indicator_name, target_param, target_agent_ip)
		return respJson


class TakeActionManagerHost(Resource):
	def post(self):
		postedData = request.get_json()
		indicator_name = postedData['indicator_name']
		target_param = postedData['target_param']
		target_agent_ip = postedData['target_agent_ip']

		action_subprocess_success, action_subprocess_msg, action_success_check = take_action(indicator_name, target_param, target_agent_ip)
		
		respJson = {
			"action_subprocess_success": action_subprocess_success,
			"action_subprocess_msg": action_subprocess_msg,
			"action_success_check": action_success_check
		}
		return respJson


class BlockIPsManager(Resource):
	def post(self):
		postedData = request.get_json()
		ips_list = postedData['ips_list']
		state_action = postedData['state_action']
		
		task_result = set_blocked_ips_state_manager(ips_list, state_action)

		# retJson = {
		# 	"status": 200,
		# 	"message": "Success"
		# }

		return task_result 


class GetManPageManagerHost(Resource):
	def post(self):
		postedData = request.get_json()
		service_name = postedData['service_name']
		#resp = { "service_name": service_name, "page_data": data }
		resp = get_man_page_data(service_name)
		return resp


class GetSystemDmidecode(Resource):
	def get(self):		
		machine_uuid_resp = get_dmidecode_system_uuid()
		return machine_uuid_resp


class CreateAgent(Resource):
	def post(self):
		postedData = request.get_json()
		ip_addr = postedData['ip_addr']
		agent_type = postedData['agent_type']
		manager_ip = postedData['manager_ip']
		interfaces = postedData['interfaces']
		agent_id = postedData['agent_id']
		pre_shared_key = postedData['pre_shared_key']
		package_manager = postedData['package_manager']

		#print("ip_addr: ",ip_addr,"agent_type: ", agent_type," manager_ip: ", manager_ip," interfaces: ", interfaces," agent_id: ", agent_id," pre_shared_key: ", pre_shared_key)

		subprocess_errors = []

		cmd = '/opt/impulse/tasks_manager/shell_scripts/create_manager_agent_connector.sh ' + ip_addr + ' ' + agent_type
		p = subprocess.run(cmd, shell=True)
		
		# try:
		# 	subprocess.check_output(cmd)
		# except subprocess.CalledProcessError as e:
		# 	print(e.output)

		# IP_AGENT=$1
		# IP_MANAGER=$2
		# HOST_INTERFACE=$3 
		# AGENT_TYPE=$4
		# AGENT_ID=$5
		# AGENT_SECRET_KEY=$6

		cmd = '/opt/impulse/tasks_manager/shell_scripts/create_agent_installation_pkg.sh ' + ip_addr + ' ' + manager_ip + ' ' + interfaces + ' ' + agent_type + ' ' + agent_id + ' ' + pre_shared_key + ' ' + package_manager
		p = subprocess.run(cmd, shell=True)

		pass 


class SetActiveCapHost(Resource):
	def post(self):
		postedData = request.get_json()
		option = postedData['option']
		new_state = postedData['new_state']
		try:
			if new_state == False:
				cmd = 'stop' 
			else:
				cmd = 'start'

			if option == 'nids_status':
				subprocess.call(['systemctl', cmd, 'impulse-nids'])
			else:
				pass 	
			ret_status = 200
			ret_msg = 'Command set.'
		except:
			ret_status = 301
			ret_msg = 'Problem executing command.'	

		resp = {
			"ret_status": ret_status,
			"ret_msg": ret_msg
		}

		return resp



class UpdateCustomSuricataRuleset(Resource):
	def post(self):
		postedData = request.get_json()
		ruleset_data = postedData['ruleset_data']
		try:
			# with open(suricata_custom_rules_filepath, "w") as f:
			# 	for line in ruleset_data:
			# 		f.write(line)

			subprocess.run("docker exec -it  impulse-suricata suricatasc -c ruleset-reload-nonblocking")
			subprocess.run("systemctl restart impulse-nids")

			status = True
		except:
			status = False
		
		return status


class NftManagerReload(Resource):
	def get(self):		
		subprocess.run("nft flush table inet impulse_table", shell=True)
		subprocess.run("nft -f " + nftables_impulse_table_filepath, shell=True)	
		pass 



api.add_resource(RunOsqueryManagerHost, '/run-osquery-manager-host')
api.add_resource(SystPostureManagerHost, '/syst-posture-manager-host')
api.add_resource(RunScpPacksManagerHost, '/run-scp-packs-manager-host')
api.add_resource(RunScaScanManagerHost, '/run-sca-scan-manager-host')
api.add_resource(RestartOsquerydManagerHost, '/restart-osqueryd-manager-host')
api.add_resource(CheckCanTakeActionManagerHost, '/check-can-take-action-manager-host')
api.add_resource(TakeActionManagerHost, '/take-action-manager-host')
api.add_resource(BlockIPsManager, '/block-ips-manager-host')
api.add_resource(GetManPageManagerHost, '/get-man-page-manager-host')
api.add_resource(GetSystemDmidecode, '/get-system-dmidecode-uuid')
api.add_resource(CreateAgent, '/create-agent')
api.add_resource(SetActiveCapHost, '/set-active-host-cap')
api.add_resource(UpdateCustomSuricataRuleset, '/update-custom-suricata-ruleset-manager-host')

api.add_resource(NftManagerReload, '/nft-reload-manager')
