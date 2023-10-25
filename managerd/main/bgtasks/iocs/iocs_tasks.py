#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import psycopg2
import os, json
from collections import defaultdict, Counter
import collections
from main.models import * 
from main import db
import datetime 
import requests
import traceback
from main import celery_app
from main.helpers.indicators_details_helper import get_indicator_details, get_indicator_score
from main.helpers.events_helper import query_database_records, insert_database_record, detect_outliers
from main.helpers.shared.agent_conf import get_agent_config

from main.helpers.iocs_tasks_helper import (
	detection_run_parallel_db_conn_task, 
	syst_profile_anomaly_detection_task, 
	syst_profile_analysis_task
)

agent_config = get_agent_config()
IMPULSE_DB_PWD = agent_config.get('Env','IMPULSE_DB_SERVER_PWD')


@celery_app.task
def detection_run_parallel_db_conn(agent_ip):
	remote_agent = RemoteAgent.query.filter_by(ip_addr=agent_ip).first()
	agent_alias = remote_agent.alias
	try:
		detection_run_parallel_db_conn_task(agent_ip, agent_alias)
	except Exception as e:
		print(traceback.format_exc())
		pass 

@celery_app.task
def syst_profile_analysis(agent_db):
	syst_profile_analysis_task(agent_db)

@celery_app.task
def syst_profile_anomaly_detection(agent_ip):
	syst_profile_anomaly_detection_task(agent_ip)

