#
# Copyright (c) 2024, Bozhidar Genev - All Rights Reserved.Impulse XDR   
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
	analyse_fim_alerts,
	get_new_last_id,
	update_last_analysed
)
from main.helpers.events_helper import query_database_records, insert_database_record, detect_outliers, create_async_task_ref
from main.packs.packs_routes import deploy_pack_task, delete_pack_task

from main.helpers.fleet_management_helper import get_system_posture_agent

from main.helpers.shared.sca_helper import sca_run_method
from main.helpers.sca_checks import get_cis_compliance_checks
from main.helpers.derived_tables_helper import suricata_derived_table_update, osquery_derived_table_update


from main.helpers.general_tasks_helper import (
	send_email_alert_task,
	update_packages_cves_map_task,
	check_agents_status_task,
	block_suspected_offenders_task_helper,
	malware_scanner_task,
	get_last_analysed_meta,
	update_test_result_db,
	sca_update_agent_results
)

from main.helpers.grpc_helper import await_grpc_results, create_task_id, publish_grpc_task

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
	send_email_alert_task(email_body, subject, mail_recipient)

@celery_app.task
def ub_analytics(agent_db):
	ub_analytics_task(agent_db)

@celery_app.task
def block_suspected_offenders_task(ip_addr, agent_type):
	block_suspected_offenders_task_helper(ip_addr, agent_type)

@celery_app.task
def update_packages_cves_map():
	update_packages_cves_map_task()
	
@celery_app.task
def suric_derived_table_update_task(agent_ip):
	suricata_derived_table_update(agent_ip)

@celery_app.task
def osquery_derived_table_update_task(agent_ip):
	osquery_derived_table_update(agent_ip)

@celery_app.task
def check_agents_status(ip_addr, manager_ip_addr, get_system_info):
	check_agents_status_task(ip_addr, manager_ip_addr, get_system_info)


@celery_app.task
def sca_run_fleet_task(agent_ip, manager_ip_addr):
	start_sca_scan_task(agent_ip, manager_ip_addr)


@celery_app.task
def fim_vt_task(agent_ip):
	last_analysed_obj = get_last_analysed_meta(agent_ip)
	fim_last_id_analysed = last_analysed_obj.fim_last_id_analysed		
	analyse_fim_alerts(agent_ip, fim_last_id_analysed)


@celery_app.task
def run_malware_scanner(agent_ip):
	malware_scanner_task(agent_ip)
	

@celery_app.task
def scan_by_os_type(osquery_string, package_type, selected_targets):
	hosts_results, failed_hosts = run_distributed_query(osquery_string, selected_targets)

	print("==> selected_targets: ", selected_targets, "hosts_results:", len(hosts_results))
	for host_result in hosts_results:
		print("host_result:", host_result)

		pkg_name = host_result['name']
		agent_ip = host_result['asset_id']
		
		try:
			version_installed = host_result['version']
		except:
			version_installed = 'n/a'

		package_check = AssetsPackagesInstalled.query.filter_by(package_name=pkg_name).filter_by(asset_id=agent_ip).first()
		
		if package_check == None:
			new_rec = AssetsPackagesInstalled(
				package_name=pkg_name, 
				asset_id=agent_ip, 
				package_type=package_type,
				version_installed=version_installed,
				updated_on=datetime.datetime.utcnow()
			)
			db.session.add(new_rec)
			db.session.commit()
		else:
			# when was the last check done? Update row if older than 7 days
			pass 	


def start_sca_scan_task(agent_ip, manager_ip_addr):
	if agent_ip == manager_ip_addr:
		
		# this should also post to grpc_snapshots for consistency
		data={ "checks_dict": checks_dict }
		r = requests.post("http://127.0.0.1:5021/run-sca-scan-manager-host", json=data, verify=False)
		tests_results = r.json()

		sca_update_agent_results({ "agent_ip": agent_ip, "tests_results": tests_results })
	else:			
		#pass 
		task_id = create_task_id()
		publish_grpc_task(task_id, "sca_report", { "checks_dict": checks_dict }, agent_ip)

		tests_results = await_grpc_results(
			"""
			select sca_report from grpc_snapshots where task_id='{task_id}';
			""".strip().format(task_id=task_id),
			1,
			15
		)
		tests_results = tests_results[0][0]
		sca_update_agent_results({ "agent_ip": agent_ip, "tests_results": tests_results })


@celery_app.task
def get_system_posture_agent_task(agent_ip):
	get_system_posture_agent(agent_ip) 























