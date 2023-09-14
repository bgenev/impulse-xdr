#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse X SIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import time, json
import grpc
import jwt 
import datetime
from google.protobuf.json_format import MessageToJson
from main.grpc_gateway.grpc_pb import grpc_gateway_pb2, grpc_gateway_pb2_grpc
from main.helpers.manager_helper import get_agent_auth_data


def handle_access_token(agent_ip):
	secret_key, access_token = get_agent_auth_data(agent_ip)
	jwt_payload = { "exp": datetime.datetime.now(tz=datetime.timezone.utc) + datetime.timedelta(minutes=30)}
	access_token = jwt.encode( jwt_payload, secret_key, algorithm="HS256").decode('utf-8')
	return ('access_token', access_token)

def load_ca_root_cert():
	with open('/var/impulse/etc/grpc/tls/ca-cert.pem', 'rb') as f:
		key_file = grpc.ssl_channel_credentials(f.read())
	return key_file

def loag_agent_grpc_port():
	return '50051'

def convert_protobuf_message_to_json(proto_message):
	json_obj = MessageToJson(proto_message, preserving_proto_field_name=True)
	response_json = json.loads(json_obj)
	return response_json

def open_secure_channel(grpc_agent_ip):
	ca_root_cert = load_ca_root_cert()
	host_ip_port =  grpc_agent_ip + ':' + loag_agent_grpc_port()
	channel = grpc.secure_channel(host_ip_port, ca_root_cert)
	channel = grpc.intercept_channel(channel)
	stub = grpc_gateway_pb2_grpc.GrpcGatewayStub(channel)
	return stub


def json_to_string(data):
	return json.dumps(data)


def string_to_json(data):
	return json.loads(data)


def errorReturnObj(e):
	return {'result': None, 'error': {"error_message": str(e.details()), "status_code": str(e.code())} }


def run_osquery_on_agent(grpc_agent_ip, osquery_cmd_string):
	stub = open_secure_channel(grpc_agent_ip)
	
	request = grpc_gateway_pb2.RunOSqueryOnAgentRequest(osquery_query=osquery_cmd_string)
	try:
		resp = stub.RunOSqueryOnAgent(
			request, 
			metadata=[handle_access_token(grpc_agent_ip)],
			timeout=1
		)
		resp = convert_protobuf_message_to_json(resp)
		data = string_to_json(resp['osquery_results'])
		return {'result': data, 'error': False}	

	except grpc.RpcError as e:
		#print(grpc_agent_ip, " err: ", e)
		return errorReturnObj(e)


def firewall_management_state_agent(grpc_agent_ip, nft_ruleset_content, state_action):
	stub = open_secure_channel(grpc_agent_ip)

	request = grpc_gateway_pb2.FirewallManagementStateRequest(ips_list=nft_ruleset_content, state_action=state_action)
	
	resp = convert_protobuf_message_to_json(
		stub.FirewallManagementState(
			request, 
			metadata=[handle_access_token(grpc_agent_ip)],
			timeout=2
		) 
	) 
	return resp


def check_agent_status(grpc_agent_ip, get_system_info):
	stub = open_secure_channel(grpc_agent_ip)
	request = grpc_gateway_pb2.CheckAgentStatusRequest(get_system_info=get_system_info)
	try:
		data = convert_protobuf_message_to_json(
			stub.CheckAgentStatus(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)]
			) 
		) 
		return {'result': data, 'error': False}

	except grpc.RpcError as e:
		return errorReturnObj(e)


def deploy_pack_on_agent(grpc_agent_ip, pack_data, filename):
	pack_data = json_to_string(pack_data)
	stub = open_secure_channel(grpc_agent_ip)
	request = grpc_gateway_pb2.DeployPackOnAgentRequest(pack_data=pack_data, filename=filename)
	try:
		data = convert_protobuf_message_to_json(
			stub.DeployPackOnAgent(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)]
			) 
		) 
		return {'result': data, 'error': False}
	except grpc.RpcError as e:
		return errorReturnObj(e)


def core_osq_pack_update(grpc_agent_ip, pack_data):
	stub = open_secure_channel(grpc_agent_ip)
	pack_data = json_to_string(pack_data)
	request = grpc_gateway_pb2.CoreOsqPackUpdateRequest(pack_data=pack_data)
	try:
		data = convert_protobuf_message_to_json(
			stub.CoreOsqPackUpdate(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)]
			) 
		) 
		return {'result': data, 'error': False}
	except grpc.RpcError as e:
		return errorReturnObj(e)
	

def delete_pack_on_agent(grpc_agent_ip, name):
	stub = open_secure_channel(grpc_agent_ip)
	request = grpc_gateway_pb2.DeletePackOnAgentRequest(name=name)
	try:
		data = convert_protobuf_message_to_json(
			stub.DeletePackOnAgent(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)]
			) 
		) 
		return {'result': data, 'error': False}
	except grpc.RpcError as e:
		return errorReturnObj(e)


def take_action_agent(grpc_agent_ip, indicator_name, target_param, target_agent_ip):
	stub = open_secure_channel(grpc_agent_ip)
	request = grpc_gateway_pb2.TakeActionAgentRequest(indicator_name=indicator_name, target_param=target_param, target_agent_ip=target_agent_ip)
	try:
		data = convert_protobuf_message_to_json(
			stub.TakeActionAgent(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)]
			) 
		) 
		return {'result': data, 'error': False}
	except grpc.RpcError as e:
		return errorReturnObj(e)	
	

def check_can_take_action_agent(grpc_agent_ip, indicator_name, target_param, target_agent_ip):
	stub = open_secure_channel(grpc_agent_ip)
	request = grpc_gateway_pb2.CheckCanTakeActionAgentRequest(indicator_name=indicator_name, target_param=target_param, target_agent_ip=target_agent_ip)
	try:
		data = convert_protobuf_message_to_json(
			stub.CheckCanTakeActionAgent(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)]
			) 
		) 
		return {'result': data, 'error': False}
	except grpc.RpcError as e:
		return errorReturnObj(e)	
	

def receive_sca_scan_req(grpc_agent_ip, checks_dict):
	stub = open_secure_channel(grpc_agent_ip)
	checks_dict = json_to_string(checks_dict)

	request = grpc_gateway_pb2.ReceiveScaScanReqRequest(checks_dict=checks_dict)
	
	try:
		resp = convert_protobuf_message_to_json(
			stub.ReceiveScaScanReq(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)],
				timeout=500
			) 
		)
		data = string_to_json(resp['tests_results'])
		return {'result': data, 'error': False}
	except grpc.RpcError as e:
		return errorReturnObj(e)


def get_agent_system_posture_grpc(grpc_agent_ip, syst_posture_queries):
	stub = open_secure_channel(grpc_agent_ip)

	syst_posture_queries = json_to_string(syst_posture_queries)
	request = grpc_gateway_pb2.AgentSystemPostureRequest(syst_posture_queries=syst_posture_queries)
	try:
		resp = stub.AgentSystemPosture(
			request, 
			metadata=[handle_access_token(grpc_agent_ip)],
			timeout=10
		)
		resp = convert_protobuf_message_to_json(resp)
		data = string_to_json(resp['osquery_results'])
		return {'result': data, 'error': False}	
	except grpc.RpcError as e:
		return errorReturnObj(e)


def run_policy_pack_queries_grpc(grpc_agent_ip, deployed_packs):
	stub = open_secure_channel(grpc_agent_ip)
	deployed_packs = json_to_string(deployed_packs)
	request = grpc_gateway_pb2.RunPolicyPackQueriesRequest(deployed_packs=deployed_packs)
	try:
		resp = stub.RunPolicyPackQueries(
			request, 
			metadata=[handle_access_token(grpc_agent_ip)],
			timeout=120
		)
		resp = convert_protobuf_message_to_json(resp)
		data = string_to_json(resp['report_results'])
		return {'result': data, 'error': False}	

	except grpc.RpcError as e:
		return errorReturnObj(e)


def get_service_data_grpc(grpc_agent_ip, service_name):
	stub = open_secure_channel(grpc_agent_ip)
	request = grpc_gateway_pb2.GetServiceDataRequest(service_name=service_name)
	try:
		resp = stub.GetServiceData(
			request, 
			metadata=[handle_access_token(grpc_agent_ip)],
			timeout=10
		)
		resp = convert_protobuf_message_to_json(resp)
		data = resp['service_data']
		return {'result': data, 'error': False}	
	except grpc.RpcError as e:
		#print("get_service_data_grpc e: ", e)
		return errorReturnObj(e)



def suricata_custom_ruleset_sync_grpc(grpc_agent_ip, ruleset_data):
	stub = open_secure_channel(grpc_agent_ip)

	request = grpc_gateway_pb2.SuricataCustomRulesetSyncRequest(ruleset_data=ruleset_data)

	try:
		data = convert_protobuf_message_to_json(
			stub.SuricataCustomRulesetSync(
				request, 
				metadata=[handle_access_token(grpc_agent_ip)]
			) 
		) 
		#print("suricata_custom_ruleset_sync_grpc: ", data)
		return {'result': data, 'error': False}
	except grpc.RpcError as e:
		return errorReturnObj(e)



