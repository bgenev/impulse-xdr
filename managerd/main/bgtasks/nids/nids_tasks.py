#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse SIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import psycopg2
import os, json
from collections import defaultdict, Counter
from main.models import * 
from main import db
import datetime 
import requests
import time 
import ipaddress

from main import celery_app
from main.helpers.events_helper import query_database_records, insert_database_record
from main.helpers.shared.agent_conf import get_agent_config

# from main.helpers.active_response_manager_helper import set_ips_blocked_status_db # circular import 

from main.helpers.analytics_helper import (
	instance_flows_analyse,
	get_last_analysed_flow,
	get_dates_to_analyse,
	analyse_net_flows,
	calculate_date_range,
	instance_flows_acct
)

from main.helpers.threat_intel_helper import abuseipdb_check_api, get_geoip_data

from main.grpc_gateway.grpc_client import suricata_custom_ruleset_sync_grpc, firewall_management_state_agent

agent_config = get_agent_config()
IMPULSE_DB_PWD = agent_config.get('Env','IMPULSE_DB_SERVER_PWD')


@celery_app.task
def nids_profile_analysis(agent_db):
	connection = psycopg2.connect(
		host="127.0.0.1",
		database=agent_db,
		port='7543',
		user="postgres",
		password=IMPULSE_DB_PWD
	)
	cursor = connection.cursor()

	cursor.execute(
	""" 
	select 
		id_last_record_analysed_eve_flow 
	from 
		kernelk_meta
	"""
	)

	id_last_record_analysed_eve_flow = cursor.fetchone()[0]

	if id_last_record_analysed_eve_flow == None:
		last_id_analysed = 0
		cursor.execute(
		"""
		update 
			kernelk_meta 
		set 
			id_last_record_analysed_eve_flow = '0' 
		where 
			id = '1'
		""".strip() 
		)
		connection.commit()
	else:
		last_id_analysed = id_last_record_analysed_eve_flow

	NIDS_FLOWS_ANALYSE_QUERY = """
	select 
		* 
	from 
		suricata_eve_flow 
	where 
		id > '{last_id_analysed}';
	""".strip().format(
			last_id_analysed=str(last_id_analysed)
	)

	cursor.execute(NIDS_FLOWS_ANALYSE_QUERY)
	flow_events = cursor.fetchall()

	flow_events_list = []
	flow_ips_list = []
	high_data_transfer_alerts = []
	local_ip_addrs = ['127.0.', '10.0.', '192.168']

	for item in flow_events:
		event_id=item[0]
		flow_event=item[1]
		try:
			dest_ip = flow_event['dest_ip']
			src_ip = flow_event['src_ip']
			dest_port = flow_event['dest_port']
			src_port = flow_event['src_port']
		except:
			pass   
		
		proto = flow_event['proto']
		flow_id = flow_event['flow_id']

		flow_data = flow_event['flow']
		bytes_toserver = flow_data['bytes_toserver']
		bytes_toclient = flow_data['bytes_toclient']

		"""
			Flows have a direction. The IP which starts the conversation is considered the client, 
			and the packets it sends are in the 'to server' direction. The other talker is considered the server and the packets it sends are in the 'to client' direction. 
			So in a flow records the 'flow.pkts_toserver' is a count of the number of packets from client to server. 
			'flow.bytes_toserver' counts the total bytes in the same direction. The 'flow.*_toclient' records are the same, but in the opposing direction.
		"""

		timestamp = datetime.datetime.now()

		size_10_mbs = 10490000
		size_0_1_mbs = 104900

		# if more than 10 MB is transferred in or out, create Critical/High alert, else Medium
		if (bytes_toserver > size_10_mbs) or (bytes_toclient > size_10_mbs):
			severity_level = 1
		else:
			severity_level = 2   

		src_ip_is_local = any(ip_wildcard in src_ip for ip_wildcard in local_ips)
		dest_ip_is_local = any(ip_wildcard in dest_ip for ip_wildcard in local_ips)

		if (bytes_toserver > size_0_1_mbs) or (bytes_toclient > size_0_1_mbs):
			if (src_ip_is_local != True) or (dest_ip_is_local != True):

				alert_data = {
				"timestamp":str(timestamp),
				"flow_id":flow_id, 
				"event_type":"data_transfer_alert",
				"src_ip":src_ip,
				"src_port":src_port,
				"dest_ip":dest_ip,
				"dest_port":dest_port,
				"proto":proto,
				"alert":{
					"action":"allowed",
					"gid":1,
					"signature_id":'1000000001',
					"signature":"bytes_toserver (dest_ip): " + str( round(bytes_toserver/size_0_1_mbs, 2) ) + " MB bytes_toclient (src_ip): " + str( round(bytes_toclient/1049000, 2) ) + " MB.",
					"category":"Data Transfer",
					"severity":severity_level,
				},
				"flow": flow_data			
				}		
				message = json.dumps(alert_data)
				DATA_TRANSFERS_INSERT_QUERY = """
				insert into 
					data_transfers
				(message) 
					values 
				('{message}')
				""".strip()
				nids_insert_statement = DATA_TRANSFERS_INSERT_QUERY.format(
					message=message
				)
				cursor.execute(nids_insert_statement)
				connection.commit()

	new_last_event_id = flow_events[-1][0]

	cursor.execute(
	"""
	update 
		kernelk_meta 
	set 
		id_last_record_analysed_eve_flow = '{new_last_event_id}' 
	where 
		id = '1' 
	""".strip().format(new_last_event_id=str(new_last_event_id) ) 
	)
	connection.commit()


# define a fuction for key
def key_func(k):
	return k['ip_addr']

@celery_app.task
def flows_volume_over_time(agent_db, time_interval):
	connection = psycopg2.connect(
		host="127.0.0.1",
		database=agent_db,
		port='7543',
		user="postgres",
		password=IMPULSE_DB_PWD
	)
	cursor = connection.cursor()

	FLOWS_VOLUME_QUERY = """
	select 
		* 
	from 
		suricata_eve_flow 
	where 
		(message->>'timestamp')::DATE >= NOW() - INTERVAL '{time_interval} DAY';
	""".strip().format(time_interval=time_interval)

	cursor.execute(FLOWS_VOLUME_QUERY)
	flow_events = cursor.fetchall()
	flow_events_list = []

	for item in flow_events:
		event_id=item[0]
		flow_event=item[1]

		src_ip = flow_event['src_ip']
		dest_ip = flow_event['dest_ip']

		flow_data = flow_event['flow']
		bytes_toserver = flow_data['bytes_toserver']
		bytes_toclient = flow_data['bytes_toclient']

		src_acct = { 
			"ip_addr": src_ip, 
			"received": bytes_toclient,
			"sent": bytes_toserver,
		}

		dest_acct = { 
			"ip_addr": dest_ip, 
			"received": bytes_toserver,
			"sent": bytes_toclient
		}

		flow_events_list.append(src_acct)
		flow_events_list.append(dest_acct)


	INFO = sorted(flow_events_list, key=key_func)

	if time_interval == '1':
		alert_timeframe_desc = '24h'
	elif time_interval == '7':
		alert_timeframe_desc = '1 week'
	elif time_interval == '30':
		alert_timeframe_desc = '1 month'
	else:
		pass 


	for key, value in groupby(INFO, key_func):
		ip_sorted_list = list(value)

		received_bytes = []
		sent_bytes = []
		for item in ip_sorted_list:
			received_bytes.append(item['received'])
			sent_bytes.append(item['sent'])

		received_bytes_sum = sum(received_bytes)
		sent_bytes_sum = sum(sent_bytes)

		if (received_bytes_sum > 10490000) or (sent_bytes_sum > 10490000):
			severity_level = '1'
		else:
			severity_level = '2'  

		ip_addr = str(key) 
		res = "ip_addr: " + str(key) + " sent: " + str(sent_bytes_sum) + " received: " + str(received_bytes_sum)
		ip_addr_is_local = any(ip_wildcard in ip_addr for ip_wildcard in local_ips)
		
		if (sent_bytes_sum > 2049000) or (received_bytes_sum > 2049000):
			if ip_addr_is_local != True:
				alert_data = {
				"timestamp":str(datetime.datetime.now()),
				"flow_id": None, 
				"event_type":"data_transfer_alert",
				"src_ip":ip_addr,
				"src_port":None,
				"dest_ip":None,
				"dest_port":None,
				"proto":None,
				"alert":{
					"action":"allowed",
					"gid":1,
					"signature_id":'1000000002',
					"signature":"High volume data transfer over the last " + alert_timeframe_desc + " with " + ip_addr + ". sent_bytes_sum: " + str( round(sent_bytes_sum/1049000, 2) ) + " MB received_bytes_sum: " + str( round(received_bytes_sum/1049000, 2) ) + " MB.",
					"category":"Data Transfer",
					"severity":severity_level,
				},
				"flow": None			
				}		
				message = json.dumps(alert_data)
				DATA_TRANSFERS_INSERT_QUERY = """
				insert into 
					data_transfers
				(message) 
					values 
				('{message}')
				""".strip()
				nids_insert_statement = DATA_TRANSFERS_INSERT_QUERY.format(
					message=message
				)
				cursor.execute(nids_insert_statement)
				connection.commit()


def flows_processed_analytics(agent_ip, date_to_analyse):
	FLOWS_ANALYSE_QUERY = """
	select 
		message
	from 
		suricata_eve_flow 
	where 
		date(created_on) = '{date_to_analyse}';
	""".strip().format( date_to_analyse=date_to_analyse)

	flow_events = query_database_records(agent_ip, FLOWS_ANALYSE_QUERY, 'all')
	flows_analysed = instance_flows_analyse(agent_ip, flow_events)

	for item in flows_analysed:
		insert_flows_processed_query = """
		INSERT INTO 
			flows_processed_analytics (ip_addr, total_received, total_sent, affected_asset, batch_date)
		values
			('{ip_addr}', '{total_received}', '{total_sent}', '{affected_asset}', '{batch_date}');
		""".strip().format(
			ip_addr=item['ip_addr'], 
			total_received=item['total_received'], 
			total_sent=item['total_sent'],
			affected_asset=item['agent_ip'],
			batch_date = date_to_analyse
		)
		insert_database_record('impulse_manager', insert_flows_processed_query)
	pass 



@celery_app.task
def network_flows_rollup_task(agent_ip, agent_type):
	if agent_type == 'heavy':
		last_analysed_flow_id, last_analysed_flow_created_at = get_last_analysed_flow(agent_ip)
		today_date = datetime.datetime.utcnow().date()
		dates_to_analyse, delta = get_dates_to_analyse(last_analysed_flow_created_at, today_date)

		if delta > 1:
			for date_item in dates_to_analyse: # analyse old period + today
				if date_item == today_date:
					analyse_net_flows(today_date, last_analysed_flow_id, 'today', agent_ip)
				else:
					analyse_net_flows(date_item, last_analysed_flow_id, 'old_date', agent_ip)				
		else:
			analyse_net_flows(today_date, last_analysed_flow_id, 'today', agent_ip) # only analyse today
	else:
		pass 


def update_agent_suricata_deployment_version(agent_ip):
	# rulesets_data = SuricataCustomRulesets.query.filter_by(ruleset_name="suricata_custom_rules").first()
	# ruleset_latest_version = rulesets_data.ruleset_latest_version

	select_statement = """
	SELECT 
		ruleset_latest_version
	FROM
		suricata_custom_rulesets
	WHERE
		ruleset_name='suricata_custom_rules';
	""".strip()

	ruleset_latest_version = query_database_records('impulse_manager', select_statement, 'one')[0]


	insert_statement = """
	UPDATE 
		suricata_custom_ruleset_deployments
	SET
		ruleset_version={ruleset_version}
	WHERE
		asset_ip='{asset_ip}';
	""".strip().format(
		asset_ip=agent_ip,
		ruleset_version=ruleset_latest_version,
	)
	insert_database_record('impulse_manager', insert_statement)

	# agent_suricata_conf_deploy_data = SuricataCustomRulesetDeployments.query.filter_by(asset_ip=agent_ip).first()

	# if agent_suricata_conf_deploy_data == None:
	# 	new_rec = SuricataCustomRulesetDeployments(
	# 		asset_ip=agent_ip, 
	# 		ruleset_version=ruleset_latest_version
	# 	)
	# 	db.session.add(new_rec)
	# 	db.session.commit()
	# else:
	# 	agent_suricata_conf_deploy_data.ruleset_version = ruleset_latest_version
	# 	db.session.commit()

	# print("update_agent_suricata_deployment_version should be done.")


@celery_app.task
def update_suricata_conf_on_agents(manager_ip_addr, heavy_agents, file_string_concat):

	for agent_ip in heavy_agents:
		try:
			if agent_ip == manager_ip_addr:
				data={ "ruleset_data": file_string_concat }
				r = requests.post("http://127.0.0.1:5021/update-custom-suricata-ruleset-manager-host", json=data, verify=False)
				data = r.json()
				#syst_posture_results = {'result': data, 'error': False}	
			else:
				resp = suricata_custom_ruleset_sync_grpc(agent_ip, file_string_concat)

				if resp['error']:
					pass 
				else:
					deploy_status = resp['result']['status']
					update_agent_suricata_deployment_version(agent_ip) 

				#print("result: ", resp)
		except Exception as e:
			print("update_suricata_conf_on_agents: ", e)
			pass 



	# try:
	# 	resp = suricata_custom_ruleset_sync_grpc(agent_ip, file_string_concat)
	# 	deploy_status = resp['result']['status']
		
	# 	print("*** update_suricata_conf_on_agent result: ", deploy_status)
		
	# 	update_agent_suricata_deployment_version(agent_ip) 

	# 	# if deploy_status == True:
	# 	# 	update_agent_suricata_deployment_version(agent_ip) 
	# 	# else:
	# 	# 	pass 
	# except Exception as e:
	# 	print("exception update_suricata_conf_on_agent: ", e)

	# 	pass 


# @celery_app.task
# def block_ip_remote_host_task(agent_ip, manager_ip_addr, formatted_list, state_action):

# 	pass 


@celery_app.task
def check_flow_anomalies_task(agent_ip, time_filter):
	past_date, recent_date = calculate_date_range(time_filter)
	ips_to_block = []
	
	flows_acct = instance_flows_acct(past_date, recent_date, agent_ip)

	for item in flows_acct:
		
		#if item['outbound_inbound_ratio'] > 0.001 and item['total_received'] > 0.001: # test 
		if item['outbound_inbound_ratio'] > 0.5 and item['total_received'] > 0.5:
			ip_addr = item['ip_addr']
			ip_data = IPsSafetyStatus.query.filter_by(ip_remote_host=ip_addr).first()
			
			ips_to_block.append(item['ip_addr'])
		else:
			pass 

	if len(ips_to_block) > 0:
		#set_ips_blocked_status_db(ips_to_block, 'block')
		pass 
	else:
		pass 
	
	

def determine_if_pkg_mgmt_rel(domain, hostnames):

	pkg_mgmt_keywords = [
		'github', 
		'canonical', 
		'ubuntu', 
		'debian', 
		'centos',
		'kernel.org',
		'snap'
	]

	pkg_mgmt_related = False 

	for i in pkg_mgmt_keywords:
		if i in domain:
			pkg_mgmt_related = True 
		elif i in hostnames:
			pkg_mgmt_related = True
		else:
			pass 
		
	return pkg_mgmt_related
	




# {"errors": 
# [
# 	{
# 		"detail": "Daily rate limit of 1000 requests exceeded for this endpoint. See headers for additional details.",
# 		"status": 429
# 	}
# ]
# }	

# derived_flows_query = """
# select 
# 	distinct ip_addr
# from 
# 	suricata_eve_flow_derived;
# """.strip()
# items = query_database_records(agent_ip, derived_flows_query, 'all')
# ips_list = [i[0] for i in items]


@celery_app.task
def refresh_ip_threat_intel_data():
	derived_flows_query = """
	select 
		ip_remote_host
	from 
		ips_safety_status
	where 
		domain IS NULL
	or 
		safety_score IS NULL
	or 
		hostnames IS NULL
	;
	""".strip()
	
	items = query_database_records('impulse_manager', derived_flows_query, 'all')

	if items == None:
		pass
	else:
		ips_list = [i[0] for i in items]

		for ip_addr in ips_list:
			try:
				abuseipdb_obj = abuseipdb_check_api(ip_addr) # full object from remote API
				ret_obj_keys = list(abuseipdb_obj.keys())
				
				if ret_obj_keys[0] == 'errors':
					print("Daily limit exceeded.", abuseipdb_obj, " Use local geoloc database.")
					pass 
				else:
					abuseConfidenceScore = abuseipdb_obj['data']['abuseConfidenceScore']
					isp = abuseipdb_obj['data']['isp']
					
					domain = abuseipdb_obj['data']['domain']
					hostnames = abuseipdb_obj['data']['hostnames']

					if abuseConfidenceScore > 40:
						safety_label = 'Malicious'
					else:
						safety_label = 'Safe'

					pkg_mgmt_related = determine_if_pkg_mgmt_rel(domain, hostnames)

					last_synced_with_db = datetime.datetime.now()

					update_statement = """
					update 
						ips_safety_status 
					set 
						safety_score = '{abuseConfidenceScore}',
						safety_label = '{safety_label}',
						isp = '{isp}',
						domain = '{domain}',
						hostnames = '{safety_label}',
						abuse_confidence_score = '{abuseConfidenceScore}',
						pkg_mgmt_related = '{pkg_mgmt_related}',
						last_synced_with_db = '{last_synced_with_db}'
					where 
						ip_remote_host = '{ip_addr}'
					""".strip().format( 
						ip_addr=ip_addr, 
						domain=domain,
						isp=isp,
						hostnames=hostnames,
						abuseConfidenceScore=abuseConfidenceScore,
						safety_label=safety_label,
						pkg_mgmt_related=pkg_mgmt_related,
						last_synced_with_db=last_synced_with_db
					)
					
					insert_database_record('impulse_manager', update_statement)
			except Exception as e: 
				print("exception: ", e) 
				pass 


# @celery_app.task
# def refresh_ip_threat_intel_data():
# 	derived_flows_query = """
# 	select 
# 		ip_remote_host
# 	from 
# 		ips_status_safety
# 	where 
# 		domain IS NULL;
# 	""".strip()

# 	items = query_database_records('impulse_manager', derived_flows_query, 'all')

# 	if items != None:
# 		ips_list = [i[0] for i in items]

# 		for ip_addr in ips_list:
# 			try:
# 				abuseipdb_obj = abuseipdb_check_api(ip_addr) # full object from remote API
# 				ret_obj_keys = list(abuseipdb_obj.keys())
# 				if ret_obj_keys[0] == 'errors':
# 					print("Daily limit exceeded.", abuseipdb_obj, " Use local geoloc database.")

# 					geoip_data=get_geoip_data(ip_addr)

# 					if geoip_data != None:					
# 						country_short = geoip_data['country_short']
# 						country_long = geoip_data['country_long']
# 						update_statement = """
# 						update 
# 							ips_safety_status 
# 						set 
# 							country_short = '{country_short}',
# 							country_long = '{country_long}',
# 						where 
# 							ip_remote_host = '{ip_addr}'
# 						""".strip().format( 
# 							ip_addr=ip_addr, 
# 							country_short=country_short,
# 							country_long=country_long
# 						)
						
# 						insert_database_record('impulse_manager', update_statement)
# 					else:
# 						pass 

# 					pass 
# 				else:
# 					abuseConfidenceScore = abuseipdb_obj['data']['abuseConfidenceScore']
# 					isp = abuseipdb_obj['data']['isp']
					
# 					domain = abuseipdb_obj['data']['domain']
# 					hostnames = abuseipdb_obj['data']['hostnames']

# 					countryCode = abuseipdb_obj['data']['countryCode']
# 					countryName = abuseipdb_obj['data']['countryName']

# 					if abuseConfidenceScore > 40:
# 						safety_label = 'Malicious'
# 					else:
# 						safety_label = 'Safe'

# 					pkg_mgmt_related = determine_if_pkg_mgmt_rel(domain, hostnames)

# 					last_synced_with_db = datetime.datetime.now()

# 					update_statement = """
# 					update 
# 						ips_safety_status 
# 					set 
# 						safety_score = '{abuseConfidenceScore}',
# 						safety_label = '{safety_label}',
# 						isp = '{isp}',
# 						domain = '{domain}',
# 						hostnames = '{safety_label}',
# 						country_code = '{countryCode}',
# 						country_name = '{countryName}',
# 						abuse_confidence_score = '{abuseConfidenceScore}',
# 						pkg_mgmt_related = '{pkg_mgmt_related}',
# 						last_synced_with_db = '{last_synced_with_db}',
# 					where 
# 						ip_remote_host = '{ip_addr}'
# 					""".strip().format( 
# 						ip_addr=ip_addr, 
# 						domain=domain,
# 						isp=isp,
# 						hostnames=hostnames,
# 						abuseConfidenceScore=abuseConfidenceScore,
# 						safety_label=safety_label,
# 						countryCode=countryCode,
# 						countryName=countryName,
# 						pkg_mgmt_related=pkg_mgmt_related,
# 						last_synced_with_db=last_synced_with_db
# 					)
					
# 					insert_database_record('impulse_manager', update_statement)

# 					# new_rec = IPsSafetyStatus(
# 					# 	ip_remote_host=ip_addr, 
# 					# 	safety_score=abuseConfidenceScore, 
# 					# 	safety_label=safety_label,

# 					# 	isp=isp,
# 					# 	domain=domain,
# 					# 	hostnames=hostnames,
						
# 					# 	country_code=countryCode,
# 					# 	country_name=countryName,
# 					# 	abuse_confidence_score = abuseConfidenceScore,

# 					# 	pkg_mgmt_related=pkg_mgmt_related,

# 					# 	last_synced_with_db=datetime.datetime.now()
# 					# )
# 					# db.session.add(new_rec)
# 					# db.session.commit()

# 			except Exception as e: 
# 				print("exception: ", e) 
# 				pass 


# 				# last_synced = abuseipdb_data.last_synced_with_db

# 				# if last_synced == None:
# 				# 	refresh_data = True
# 				# else:
# 				# 	time_since_insertion = datetime.datetime.now() - last_synced
# 				# 	if time_since_insertion.days > 7:
# 				# 		refresh_data = True
# 				# 	else:
# 				# 		refresh_data = False

# 				# if refresh_data == True:
# 				# 	try:
# 				# 		abuseipdb_obj_new = abuseipdb_check_api(ip_addr)
# 				# 		ret_obj_keys = list(abuseipdb_obj_new.keys())
# 				# 		if ret_obj_keys[0] == 'errors':
# 				# 			print("Error. Daily limit exceeded.", abuseipdb_obj_new)
# 				# 			pass 
# 				# 		else:
# 				# 			abuseipdb_data.abuseipdb_obj = abuseipdb_obj_new
# 				# 			abuseipdb_data.abuseConfidenceScore = abuseipdb_obj_new['data']['abuseConfidenceScore']

# 				# 			if abuseipdb_obj_new['data']['abuseConfidenceScore'] > 40:
# 				# 				safety_label = 'Malicious'
# 				# 			else:
# 				# 				safety_label = 'Safe'
# 				# 			abuseipdb_data.safety_label = safety_label
							
# 				# 			db.session.commit()
# 				# 	except Exception as e:
# 				# 		print("exception: ", e)
# 				# 		pass 
# 				# else:
# 				# 	pass
# 	else:
# 		pass 

def get_address_family(ip_addr):
	address_family = None 
	try:
		ipaddress.IPv4Address(ip_addr)
		address_family = 'ip'
	except:
		pass 
	try:
		ipaddress.IPv6Address(ip_addr)
		address_family = 'ip6'
	except:
		pass 
	return address_family


def regenerate_nft_impulse_table():
	blocked_ips = [i.ip_remote_host for i in IPsSafetyStatus.query.filter_by(blocked_status=True, whitelisted=False).all()]	
	try:
		with open("/var/impulse/etc/nftables/nftables_impulse_table.rules", "w") as f:
			f.write("table inet impulse_table { \n")
			f.write("	chain impulse_input_chain { \n")
			f.write("	type filter hook input priority filter; policy accept; \n")
			
			for ip_addr in blocked_ips:
				address_family = get_address_family(ip_addr)

				f.write("		" + address_family + " saddr " + ip_addr + " drop \n")

			f.write("	} \n")
			f.write("} \n")
	except Exception as e: 
		print("regenerate_nft_impulse_table e: ", e)
		pass 


@celery_app.task
def sync_fleet_firewall_task():
	remote_agents = RemoteAgent.query.all()
	manager_data = Manager.query.first()
	manager_ip_addr = manager_data.ip_addr
	
	start_time = time.time()

	regenerate_nft_impulse_table()

	end_time = time.time()

	#print("regenerate_nft_impulse_table: ", end_time - start_time)

	nft_ruleset_filepath = '/var/impulse/etc/nftables/nftables_impulse_table.rules'
	with open(nft_ruleset_filepath, "r") as infile:
		nft_ruleset_content = infile.read()	

		for agent in remote_agents:
			agent_ip = agent.ip_addr
			try:
				if agent_ip == manager_ip_addr:
					requests.get("http://127.0.0.1:5021/nft-reload-manager", verify=False).json()
					pass 
				else:
					agent_res = firewall_management_state_agent(agent_ip, nft_ruleset_content, "sync") # grpc 
			except Exception as e:
				print("Exception: ", e)
				pass






# @celery_app.task
# def update_suricata_core_ruleset_task(manager_ip_addr, heavy_agents, file_string_concat):

# 	for agent_ip in heavy_agents:
# 		try:
# 			if agent_ip == manager_ip_addr:
# 				data={ "ruleset_data": file_string_concat }
# 				r = requests.post("http://127.0.0.1:5021/update-suricata-core-ruleset-manager-host", json=data, verify=False)
# 				data = r.json()
# 			else:
# 				resp = suricata_custom_ruleset_sync_grpc(agent_ip, file_string_concat)
# 				if resp['error']:
# 					pass 
# 				else:
# 					deploy_status = resp['result']['status']
# 					update_agent_suricata_core_ruleset(agent_ip) 
# 		except Exception as e:
# 			print("update_suricata_core_ruleset_task: ", e)
# 			pass 