#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
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

from main.helpers.nids_tasks_helper import (
	nids_profile_analysis_task,
	flows_volume_over_time_task,
	sync_fleet_firewall_task,
	refresh_ip_threat_intel_data_task,
	check_flow_anomalies_task,
	update_suricata_conf_on_agents_task
)
agent_config = get_agent_config()
IMPULSE_DB_PWD = agent_config.get('Env','IMPULSE_DB_SERVER_PWD')


@celery_app.task
def nids_profile_analysis(agent_db):
	nids_profile_analysis_task(agent_db)


@celery_app.task
def flows_volume_over_time(agent_db, time_interval):
	flows_volume_over_time_task(agent_db, time_interval)

@celery_app.task
def update_suricata_conf_on_agents(manager_ip_addr, heavy_agents, file_string_concat):
	update_suricata_conf_on_agents_task(manager_ip_addr, heavy_agents, file_string_concat)

@celery_app.task
def check_flow_anomalies(agent_ip, time_filter):
	check_flow_anomalies_task(agent_ip, time_filter)

@celery_app.task
def refresh_ip_threat_intel_data():
	refresh_ip_threat_intel_data_task()

@celery_app.task
def sync_fleet_firewall():
	sync_fleet_firewall_task()






