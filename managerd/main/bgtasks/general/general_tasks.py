#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import psycopg2
import os, json
from collections import defaultdict, Counter
from main.models import * 
from main import db, mail, app 
import datetime 
import time
from itertools import groupby
import numpy 
from flask_mail import Message
import ipaddress
import requests
#from celery import Celery
import numpy as np
from concurrent.futures import ThreadPoolExecutor
import concurrent.futures

from main.helpers.shared.agent_conf import get_agent_config
from main.helpers.osquery_methods import run_distributed_query
from main.helpers.shared.osqueryd_helper import osquery_spawn_instance, osquery_exec
from main.helpers.indicators_details_helper import get_indicator_details, get_indicator_score
from main.helpers.threat_intel_helper import get_cve_data, virus_total_check
from main.helpers.active_response_manager_helper import set_ips_blocked_status_db

from main.helpers.analytics_helper import (
	overview_fleet,
	instance_flows_analyse,
	get_last_analysed_flow,
	get_dates_to_analyse,
	analyse_net_flows,
	calculate_date_range
)
from main.helpers.processed_analytics_helper import (
	analyse_suricata_alerts, 
	indicators_count,
	analyse_suricata_alerts_by_id,
	analyse_notable_indicators_by_id,
	analyse_fim_alerts,
	get_new_last_id,
	update_last_analysed
)
from main.helpers.events_helper import query_database_records, insert_database_record, detect_outliers, create_async_task_ref
from main.packs.packs_routes import deploy_pack_task, delete_pack_task

#from main.helpers.tasks_helper import add_to_failed_tasks_backlog, run_policy_packs_task

from main.helpers.shared.sca_helper import sca_run_method
from main.helpers.sca_checks import get_cis_compliance_checks
from main.helpers.derived_tables_helper import suricata_derived_table_update, osquery_derived_table_update

from main.grpc_gateway.grpc_client import receive_sca_scan_req, check_agent_status
from main.grpc_gateway.grpc_client import run_policy_pack_queries_grpc

from main.globals import IP2LOCATION_PATH
from main import celery_app
import IP2Location

IP2LocObj = IP2Location.IP2Location()
dirname = os.path.dirname(__file__)
filename = IP2LOCATION_PATH
IP2LocObj.open(filename)

agent_config = get_agent_config()
IMPULSE_DB_PWD = agent_config.get('Env','IMPULSE_DB_SERVER_PWD')
local_ips = ['10.0.2.', '192.168.']
executor = ThreadPoolExecutor(5)

checks_dict = get_cis_compliance_checks()


@celery_app.task
def send_email_alert(email_body, subject, mail_recipient):
	sender = 'admin@example.com'
	try:
		msg = Message(
			subject=subject, 
			sender=sender, 
			recipients=[mail_recipient]
		)
		msg.body = email_body

		with app.app_context():
			mail.send(msg)

		resp = {"status": 200, "success": True}

	except Exception as e:
		#print("send_email_alert Exception: ", e)
		resp = {"status": 301, "success": False}
	return resp 

	# msg = email.message.Message()
	# msg['Subject'] = subject
	# msg['From'] = 'localhost'
	# msg['To'] = mail_recipient
	# msg.add_header('Content-Type','text/html')
	# msg.set_payload(email_body)

	# try:
	# 	server = smtplib.SMTP(mail_server, mail_port)
	# 	server.starttls()
	# 	server.login(mail_username, mail_password)
	# 	server.sendmail(msg['From'], [msg['To']], msg.as_string())
	# 	server.quit()
	# except Exception as e:
	# 	print("Error: unable to send email: ", e)
	# return None


@celery_app.task
def ub_analytics(agent_db):
	connection = psycopg2.connect(
		host="127.0.0.1",
		database=agent_db,
		port='7543',
		user="postgres",
		password=IMPULSE_DB_PWD
	)
	cursor = connection.cursor()

	OSQ_QUERY = """
	select 
		* 
	from 
		osquery 
	where 
		message->>'name' = 'last'
	and 
		created_on >= NOW() - INTERVAL '1000 minute';
	""".strip()

	cursor.execute(OSQ_QUERY)
	osquery_events = cursor.fetchall()

	if osquery_events != None:
		for item in osquery_events:
			event_id=item[0]
			osquery_event=item[1]


def add_cve_to_db(cve_id,package_name, cve_data):
	try:
		cve_rec = PackagesCvesMap.query.filter_by(package_name=package_name, cve_id=cve_id).first()
		
		if cve_rec == None:
			all_data = {
				"full_cve_data": cve_data,
				"package_name": package_name,
				"cve_id": cve_id,
				"cve_severity": cve_data['base_severity'],
				"date_published": cve_data['published_date']
			}

			new_cve_rec = PackagesCvesMap(
				package_name=package_name, 
				cve_id=cve_id, 
				cve_severity=cve_data['base_severity'],
				cve_data=cve_data, 
				created_on=cve_data['published_date'],
				message=all_data, 
			)
			db.session.add(new_cve_rec)
			db.session.commit()

	except Exception as e:
		print(e)		


@celery_app.task
def update_packages_cves_map():
	debian_security_tracker = '/opt/impulse/build/deb_sec_tracker/deb_sec_tracker.json'

	installed_packages_fleet = AssetsPackagesInstalled.query.all()
	installed_packages_fleet = [i.package_name for i in installed_packages_fleet]

	with open(debian_security_tracker, 'r') as json_file:
		debian_security_tracker_pkgs = json.load(json_file)

	unique_pkgs = set()
	for package in installed_packages_fleet:
		unique_pkgs.add(package)

	unique_pkgs = list(unique_pkgs)
	#print("unique_pkgs: ", unique_pkgs)

	all_packages_cves = []
	for package_name in unique_pkgs:
		if package_name in debian_security_tracker_pkgs:
			cves = debian_security_tracker_pkgs[package_name]
			package_cves = [i for i in list( cves.keys() )]

			all_packages_cves.append({"package_name": package_name, "cves": package_cves })
		else:
			pass 

	for item in all_packages_cves:
		package_name = item['package_name']
		cves = item['cves']

		for cve_id in cves:
			cve_data = get_cve_data(cve_id)
			add_cve_to_db(cve_id, package_name, cve_data)
	

@celery_app.task
def scan_by_os_type(osquery_string, selected_targets):

	hosts_results, failed_hosts = run_distributed_query(osquery_string, selected_targets)

	for host_result in hosts_results:
		pkg_name = host_result['name']
		agent_ip = host_result['agent_ip']
		package_check = AssetsPackagesInstalled.query.filter_by(package_name=pkg_name, asset_id=agent_ip).first()
		
		if package_check == None:
			new_rec = AssetsPackagesInstalled(package_name=pkg_name, asset_id=agent_ip)
			db.session.add(new_rec)
			db.session.commit()
		else:
			pass 


def get_last_analysed_meta(ip_addr):
	last_analysed_obj = AnalyticsBatchesMeta.query.filter_by(agent_ip=ip_addr).first()
	if last_analysed_obj == None:
		new_rec = AnalyticsBatchesMeta(agent_ip=ip_addr)
		db.session.add(new_rec)
		db.session.commit()

		last_analysed_obj = AnalyticsBatchesMeta.query.filter_by(agent_ip=ip_addr).first()
	else:
		pass 
	return last_analysed_obj


@celery_app.task
def process_fleet_analytics_daily_task_by_id(agent_ip, agent_type):
	last_analysed_obj = get_last_analysed_meta(agent_ip)
	osquery_last_id_analysed = last_analysed_obj.osquery_last_id_analysed
	suricata_alerts_last_id_analysed = last_analysed_obj.suricata_alerts_last_id_analysed

	if agent_type == "heavy":		
		analyse_suricata_alerts_by_id(suricata_alerts_last_id_analysed, agent_ip)
	else:
		pass 
	analyse_notable_indicators_by_id(osquery_last_id_analysed, agent_ip)


################
### Update derived tables
################

@celery_app.task
def suric_derived_table_update_task(agent_ip):
	suricata_derived_table_update(agent_ip)

@celery_app.task
def osquery_derived_table_update_task(agent_ip):
	osquery_derived_table_update(agent_ip)


def sync_timestamps(last_analysed_obj, agent_ip, agent_type):
	timestamp_sync_last_id_suricata = last_analysed_obj.timestamp_sync_last_id_suricata 
	timestamp_sync_last_id_osquery = last_analysed_obj.timestamp_sync_last_id_osquery 

	new_last_analysed = AnalyticsBatchesMeta.query.filter_by(agent_ip=agent_ip).first()

	if agent_type == 'heavy':
		update_statement = """
			update 
				suricata_alerts 
			SET 
				created_on = (message->>'timestamp')::timestamp 
			where 
				id > '{last_synced_id}'
		""".strip().format(
			last_synced_id=timestamp_sync_last_id_suricata, 
		)		
		insert_database_record(agent_ip, update_statement)	

		new_last_id_suric = query_database_records(
			agent_ip, 
			""" select id from suricata_alerts order by id desc limit 1 """.strip(),
			'one'
		)
		new_last_id_suric = new_last_id_suric[0]
		new_last_analysed.timestamp_sync_last_id_suricata = new_last_id_suric

	else:
		pass 

	update_statement = """
		update 
			osquery 
		SET 
			created_on = (message->>'calendarTime')::timestamp 
		where 
			id > '{last_synced_id}'
	""".strip().format(
		last_synced_id=timestamp_sync_last_id_osquery, 
	)		
	insert_database_record(agent_ip, update_statement)	


	new_last_id_osquery = query_database_records(
		agent_ip, 
		""" select id from osquery order by id desc limit 1 """.strip(),
		'one'
	)	
	new_last_id_osquery = new_last_id_osquery[0]

	new_last_analysed.timestamp_sync_last_id_osquery = new_last_id_osquery
	db.session.commit()
	

def update_agent_status(ip_addr, overall_status, system_info_obj):
	
	agent = RemoteAgent.query.filter_by(ip_addr=ip_addr).first()
	agent.overall_status = overall_status
	#agent.modules_status = modules_status
	agent.updated_at = datetime.datetime.utcnow()

	if system_info_obj != False:
		system_info_obj = json.loads(system_info_obj)
		
		agent.os_type = system_info_obj['os_type']
		agent.os_type_verbose = system_info_obj['os_type_verbose']
	else:
		pass 
	
	db.session.commit() 


@celery_app.task
def check_agents_status(ip_addr, manager_ip_addr, get_system_info):
	if ip_addr != manager_ip_addr:
		agent_resp = check_agent_status(ip_addr, get_system_info)

		if agent_resp['error'] != False: 
			update_agent_status(ip_addr, False, False) # agent_resp['modules_status'] 

		else:
			if get_system_info == True:
				update_agent_status(ip_addr, True, agent_resp['result']['system_info'])
			else: 
				update_agent_status(ip_addr, True, False)

	else:
		update_agent_status(ip_addr, True, False)


def update_failed_task_status(new_status, task_id):
	failed_task = FailedTasksBacklog.query.filter_by(task_id=task_id).first()
	failed_task.completion_state = new_status
	db.session.commit()


def sca_update_agent_results(results_obj):
	agent_ip = results_obj['agent_ip'] 
	tests_results = results_obj['tests_results'] 
	for item in tests_results:
		rule_id = item['id']
		test_state = item['result']
		try:
			update_test_result_db(agent_ip, rule_id, test_state)
		except Exception as e:
			print(e)


def exec_sca_scan_on_agent(agent_ip):
	try:			
		retJson = receive_sca_scan_req(agent_ip, checks_dict) # grpc
		tests_results = retJson['result']

		# retJson = retJson['result']
		# agent_ip = retJson['agent_ip']
		# tests_results = retJson['tests_results']
		# return {"agent_ip": agent_ip, "tests_results": tests_results}

		return tests_results
	except Exception as e:
		print("err: ", e) 
		return None 


def start_sca_scan_task(agent_ip, manager_ip_addr):
	if agent_ip == manager_ip_addr:

		data={ "checks_dict": checks_dict }
		r = requests.post("http://127.0.0.1:5021/run-sca-scan-manager-host", json=data, verify=False)
		tests_results = r.json()

		sca_update_agent_results({ "agent_ip": agent_ip, "tests_results": tests_results })
	else:		
		tests_results = exec_sca_scan_on_agent(agent_ip)	
		if tests_results != None:
			sca_update_agent_results({ "agent_ip": agent_ip, "tests_results": tests_results })
		else:
			pass 


@celery_app.task
def sca_run_fleet_task(agent_ip, manager_ip_addr):
	if agent_ip == manager_ip_addr:
		executor.submit(sca_run_method, checks_dict)
	else:		
		results_obj = exec_sca_scan_on_agent(agent_ip)
		sca_update_agent_results( { "agent_ip": agent_ip, "tests_results": results_obj} )


def update_test_result_db(agent_ip, rule_id, new_test_state):
	query_definition = """
		select 
			*
		from  
			sca_results
		where
			agent_ip = '{agent_ip}'
		and 
			rule_id = '{rule_id}';
	""".strip().format(		 
		agent_ip=agent_ip, 
		rule_id=rule_id				
	)
	test_result = query_database_records('impulse_manager', query_definition, 'one')

	if test_result == None:
		insert_statement = """
		INSERT INTO 
			sca_results (agent_ip, rule_id, test_state, updated_on)
		values
			('{agent_ip}', '{rule_id}', '{test_state}', '{updated_on}');
		""".strip().format(
			agent_ip=agent_ip,
			rule_id=rule_id,
			test_state=new_test_state,
			updated_on=datetime.datetime.now()
		)
		insert_database_record('impulse_manager', insert_statement)

	else:
		# update the old one 
		insert_statement = """
		UPDATE 
			sca_results
		SET
			test_state='{test_state}',
			updated_on='{updated_on}'
		WHERE
			agent_ip='{agent_ip}'
		AND 
			rule_id='{rule_id}';
		""".strip().format(
			agent_ip=agent_ip,
			rule_id=rule_id,
			test_state=new_test_state,
			updated_on=datetime.datetime.now()
		)
		insert_database_record('impulse_manager', insert_statement)


@celery_app.task
def fim_vt_task(agent_ip):
	last_analysed_obj = get_last_analysed_meta(agent_ip)
	fim_last_id_analysed = last_analysed_obj.fim_last_id_analysed		
	analyse_fim_alerts(agent_ip, fim_last_id_analysed)


@celery_app.task
def malware_scanner_task(agent_ip):
	last_analysed_obj = get_last_analysed_meta(agent_ip)
	fim_last_id_analysed = last_analysed_obj.fim_last_id_analysed		

	file_events = query_database_records(
		agent_ip,
		"""
		SELECT DISTINCT 
			id,
			osquery.message->'columns'->>'sha1', 
			osquery.message->'columns'->>'target_path'
		FROM 
			osquery 
		WHERE 
			osquery.message->>'name' = 'file_events' 
		AND 
			osquery.message->'columns'->>'sha1' != ''
		AND
			id > '{last_analysed_id}';
		""".strip().format(last_analysed_id=fim_last_id_analysed), 
		"all"
	)

	for item in file_events:
		event_id = item[0]
		file_hash = item[1]
		target_path = item[2]
		vt_obj, vt_error = virus_total_check(file_hash)
		#print(file_hash, target_path, vt_obj)

		if vt_obj != None and vt_obj['last_analysis_stats']['malicious'] > 0:
			malware_record_query = """
			select 
				*
			from 
				malware_scanner 
			where 
				host_detected_on = '{host_detected_on}'
			and
				file_hash = '{file_hash}'
			and
				target_path = '{target_path}'
			;
			""".strip().format(
				host_detected_on=agent_ip,
				file_hash=file_hash,
				target_path=target_path
			)
			malware_record = query_database_records('impulse_manager', malware_record_query, 'one')
			
			if malware_record == None:
				update_statement = """
				insert into 
					malware_scanner 
				(host_detected_on, file_hash, target_path) 
					values 
				('{host_detected_on}', '{file_hash}', '{target_path}')
				""".strip().format( 
					host_detected_on=agent_ip,
					file_hash=file_hash,
					target_path=target_path
				)
				#print("insert detected malware: ", file_hash, agent_ip, target_path )

				insert_database_record('impulse_manager', update_statement)
			else:
				pass 	

		else:
			pass

	new_last_id = get_new_last_id(file_events, fim_last_id_analysed)
	update_last_analysed('fim', new_last_id, agent_ip)





def update_impulse_tasks_tracker(ip_addr, last_analysed_name, last_analysed_value):

	tasks_tracker_record = ImpulseTasksTracker.query.filter_by(ip_addr=ip_addr).first()

	insert_statement = """
		update 
			impulse_tasks_tracker
		set
			{last_analysed_name} = '{last_analysed_value}'
		where
			ip_addr = '{ip_addr}';
	""".strip().format(
		last_analysed_name=last_analysed_name,
		last_analysed_value=last_analysed_value,
		ip_addr=ip_addr
	)
	insert_database_record('impulse_manager', insert_statement)

	# if tasks_tracker_record == None:
	# 	insert_statement = """
	# 		insert into 
	# 			impulse_tasks_tracker 
	# 		(ip_addr) 
	# 			values 
	# 		('{ip_addr}')
	# 	""".strip().format(
	# 		ip_addr=ip_addr
	# 	)
	# 	insert_database_record('impulse_manager', insert_statement)	
	# else:
	# 	insert_statement = """
	# 		update 
	# 			impulse_tasks_tracker
	# 		set
	# 			{last_analysed_name} = '{last_analysed_value}'
	# 		where
	# 			ip_addr = '{ip_addr}';
	# 	""".strip().format(
	# 		last_analysed_name=last_analysed_name,
	# 		last_analysed_value=last_analysed_value,
	# 		ip_addr=ip_addr
	# 	)
	# 	insert_database_record('impulse_manager', insert_statement)


def check_whitelisted(ip_addr):
	is_whitelisted = False

	ip_addr_whitelisted = WhitelistedIps.query.filter_by(ip_addr=ip_addr).first()
	if ip_addr_whitelisted != None:
		is_whitelisted = True
	elif ipaddress.ip_address(ip_addr).is_private == True:
		is_whitelisted = True
	elif '192.168.' in ip_addr:
		is_whitelisted = True
	else:
		pass 
	return is_whitelisted


def remove_whitelisted(ips_list):
	cleared_list = []
	for ip_addr in ips_list:
		is_whitelisted = check_whitelisted(ip_addr)
		if is_whitelisted == False:
			cleared_list.append(ip_addr)
		else:
			pass
	return cleared_list 


def block_suspected_offenders(events_list):
	events_block_list = []
	for i in events_list:
		ip_addr = i[1]
		if ip_addr not in events_block_list:
			events_block_list.append(ip_addr)
		else:
			pass 

	events_block_list = remove_whitelisted(events_block_list)
	
	set_ips_blocked_status_db(events_block_list, 'block')


def block_ssh_offenders(ip_addr, offenders_osquery_last_analysed_id):
	osquery_ssh_offenders = """
		select 
			id,
			message->'columns'->>'remote_address' 
		from 
			osquery 
		where 
			message->>'name' = 'socket_events' 
		and 
			message::text LIKE '%%ssh%%' 
		and id > '{id}'; 
	""".strip().format(id=offenders_osquery_last_analysed_id)
	socket_events_ssh = query_database_records(ip_addr, osquery_ssh_offenders, "all")
	
	if socket_events_ssh != None and len(socket_events_ssh) > 0:
		try:
			new_offenders_osquery_last_analysed_id = socket_events_ssh[-1][0]
			task_result = block_suspected_offenders(socket_events_ssh)


			update_impulse_tasks_tracker(
				ip_addr, 
				"offenders_osquery_last_analysed_id", 
				new_offenders_osquery_last_analysed_id
			)
		except:
			pass 
	else:
		pass 
	pass 


def block_suspected_nids(ip_addr, offenders_eve_alerts_last_analysed_id):
	suricata_alerts_query = """
		select 
			id,
			message->'src_ip' 
		from 
			suricata_alerts 
		where 
			id > '{id}'; 
	""".strip().format(id=offenders_eve_alerts_last_analysed_id)
	suricata_alerts = query_database_records(ip_addr, suricata_alerts_query, "all")

	if suricata_alerts != None and len(suricata_alerts) > 0:
		try:
			new_offenders_eve_alerts_last_analysed_id = suricata_alerts[-1][0]
			block_suspected_offenders(suricata_alerts)

			update_impulse_tasks_tracker(
				ip_addr, 
				"offenders_eve_alerts_last_analysed_id", 
				new_offenders_eve_alerts_last_analysed_id
			)
		except:
			pass 
	else:
		pass 
	pass 


def block_port_scanners(ip_addr, offenders_eve_flow_last_analysed_id):
	eve_flow_query = """
		select 
			id, message->'src_ip' 
		from 
			suricata_eve_flow 
		where 
			message->'dest_port' NOT IN ('80', '443', '7001', '7514', '50051') 
		and 
			id > '{id}';
	""".strip().format(id=offenders_eve_flow_last_analysed_id)
	eve_flows = query_database_records(ip_addr, eve_flow_query, "all")

	#print(ip_addr, len(eve_flows), eve_flows)

	if eve_flows != None and len(eve_flows) > 0:
		try:
			new_offenders_eve_flow_last_analysed_id = eve_flows[-1][0]

			update_impulse_tasks_tracker(
				ip_addr, 
				"offenders_eve_flow_last_analysed_id", 
				new_offenders_eve_flow_last_analysed_id
			)

			block_suspected_offenders(eve_flows)

		except:
			pass 
	else:
		pass 
	pass 



@celery_app.task
def block_suspected_offenders_task(ip_addr, agent_type):
	tasks_tracker = ImpulseTasksTracker.query.filter_by(ip_addr=ip_addr).first()

	if tasks_tracker == None:
		new_rec = ImpulseTasksTracker(ip_addr=ip_addr)
		db.session.add(new_rec)
		db.session.commit()

		tasks_tracker = ImpulseTasksTracker.query.filter_by(ip_addr=ip_addr).first()

		offenders_osquery_last_analysed_id = tasks_tracker.offenders_osquery_last_analysed_id
		offenders_eve_alerts_last_analysed_id = tasks_tracker.offenders_eve_alerts_last_analysed_id
		offenders_eve_flow_last_analysed_id = tasks_tracker.offenders_eve_flow_last_analysed_id

	else:
		offenders_osquery_last_analysed_id = tasks_tracker.offenders_osquery_last_analysed_id
		offenders_eve_alerts_last_analysed_id = tasks_tracker.offenders_eve_alerts_last_analysed_id
		offenders_eve_flow_last_analysed_id = tasks_tracker.offenders_eve_flow_last_analysed_id
	
	block_ssh_offenders(ip_addr, offenders_osquery_last_analysed_id)

	if agent_type == 'heavy':
		block_suspected_nids(ip_addr, offenders_eve_alerts_last_analysed_id)
		#block_port_scanners(ip_addr, offenders_eve_flow_last_analysed_id)
	else:
		pass 






# @celery_app.task
# def run_policy_packs_cron():
# 	all_reports = []
# 	with concurrent.futures.ThreadPoolExecutor() as executor:
# 		results = [executor.submit(run_policy_packs_task, item['agent_ip'], manager_ip, item['deployed_packs']) for item in target_assets_deployed_packs]
# 		for f in concurrent.futures.as_completed(results):
# 			agent_results = f.result()
# 			all_reports.append(agent_results)	

# 	policy_packs_update_results(all_reports) 


# def run_policy_packs_dispatcher(target_assets_deployed_packs):
# 	if len(target_assets_deployed_packs) > 1:
# 		run_policy_packs_cron.delay(target_assets_deployed_packs)
# 	else:
# 		all_reports = []
# 		agent_results = run_policy_packs_task(target_assets_deployed_packs[0]['agent_ip'], manager_ip, target_assets_deployed_packs[0]['deployed_packs'])
# 		all_reports.append(agent_results)
# 		policy_packs_update_results(all_reports)

# 	pass 


# def policy_packs_update_results(all_reports):
# 	new_alerts_list = []
# 	for agent_reports in all_reports:
# 		agent_ip = agent_reports['agent_ip']
# 		reports = agent_reports['resp']['result']
# 		for item in reports:
# 			pack_name = item['pack_name']
# 			pack_results = item['pack_results']
# 			for query_result in pack_results:
# 				scp_packs_results_update_db(agent_ip, pack_name, query_result)
				
# 				if query_result['result'] == 'Failing':
# 					new_alerts_list.append({ "query_result": query_result, "pack_name": pack_name, "agent_ip": agent_ip })
# 				else:
# 					pass 


# def scp_packs_results_update_db(agent_ip, pack_name, query_result):
# 	query_id = query_result['query_id']
# 	result = query_result['result']
# 	updated_on = str(datetime.datetime.now())

# 	rec_exists_query = """
# 	select 
# 		*
# 	from 
# 		scp_results 
# 	where 
# 		pack_name = '{pack_name}'
# 	and 
# 		query_id = '{query_id}';
# 	""".strip().format( pack_name=pack_name, query_id=query_id )	

# 	scp_rec = query_database_records(agent_ip, rec_exists_query, 'one')

# 	if scp_rec == None:
# 		insert_statement = """
# 		insert into 
# 			scp_results 
# 		(pack_name, query_id, test_state, updated_on) 
# 			values 
# 		('{pack_name}', '{query_id}', '{test_state}' ,'{updated_on}')
# 		""".strip().format(
# 			pack_name=pack_name,
# 			query_id=query_id, 
# 			test_state=result,
# 			updated_on=updated_on
# 		)		
# 	else:
# 		insert_statement = """
# 		update 
# 			scp_results 
# 		set
# 			test_state = '{test_state}',
# 			updated_on = '{updated_on}'
# 		where 
# 			pack_name = '{pack_name}'
# 		and 
# 			query_id = '{query_id}'
# 		""".strip().format(
# 			pack_name=pack_name,
# 			query_id=query_id, 
# 			test_state=result,
# 			updated_on=updated_on
# 		)	
# 	insert_database_record(agent_ip, insert_statement)


# def run_policy_packs_task(agent_ip, manager_ip, deployed_packs):
# 	if agent_ip != manager_ip:
# 		resp = run_policy_pack_queries_grpc(agent_ip, deployed_packs)
# 	else:
# 		data = requests.post(
# 			"http://127.0.0.1:5021/run-scp-packs-manager-host", 
# 			json={ "deployed_packs": deployed_packs }, 
# 			verify=False
# 		).json()
# 		resp = {'result': data, 'error': False}	

# 	return {"agent_ip": agent_ip, "resp": resp}