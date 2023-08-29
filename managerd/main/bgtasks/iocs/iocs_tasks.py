#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse xSIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

import psycopg2
import os, json
from collections import defaultdict, Counter
from main.models import * 
from main import db
import datetime 
import requests

from main import celery_app
from main.helpers.indicators_details_helper import get_indicator_details, get_indicator_score
from main.helpers.events_helper import query_database_records, insert_database_record, detect_outliers
from main.helpers.shared.agent_conf import get_agent_config

agent_config = get_agent_config()
IMPULSE_DB_PWD = agent_config.get('Env','IMPULSE_DB_SERVER_PWD')



## TODO find a way to solve the case when events are spooled and only forwarded to the manager when it is back online. 
## do we want to produce a detection in this case?
def detection_run_parallel_db_conn_task(agent_ip):
	OSQ_QUERY = """
	select 
		* 
	from 
		osquery 
	where 
		message->>'action' = 'added' 
	and 
		created_on >= NOW() - INTERVAL '5 minute';
	""".strip()

	osquery_events = query_database_records(agent_ip, OSQ_QUERY, 'all')

	#print("osquery_events: ", osquery_events)

	osquery_events_list = []
	osquery_events_ids = []

	for item in osquery_events:
		event_id=item[0]
		osquery_event=item[1]
		osquery_events_list.append( osquery_event["name"] )
		osquery_events_ids.append( { "id": str(event_id) } )

	osquery_events_count = Counter(osquery_events_list).most_common()
	osquery_events_sorted = []

	for item in osquery_events_count:
		osquery_events_sorted.append({ "name": item[0], "count": item[1] })

	osquery_detection_score = []
	osquery_signal_names = []

	#print(agent_ip, " osquery_events_sorted: ", osquery_events_sorted)

	for signal in osquery_events_sorted:
		name = signal["name"]
		count = signal["count"]
		try:
			score = get_indicator_score(name)
			signal_result = count * score
			osquery_detection_score.append(signal_result)
			osquery_signal_names.append({"signal_name": str(name) })
		except:
			pass 

	osquery_detection_score = sum(osquery_detection_score)
	total_detection_score = osquery_detection_score

	if total_detection_score > 20:
		score_label = 'high'
	elif total_detection_score > 10 and total_detection_score < 20:
		score_label = 'medium'
	elif total_detection_score < 10:
		score_label = 'low'
	else:
		score_label = 'n/a'

	if total_detection_score > 4:

		score = str(total_detection_score)
		signals_count = str(len(osquery_events_ids))

		message = {
			"score": str(score),
			"score_label": score_label,
			"signals_count": signals_count,
			"name_tags": osquery_signal_names,
			"osquery_events_ids": osquery_events_ids,
			"detected_at": str(datetime.datetime.now())
		}

		message_json = json.dumps(message)
		name_tags = json.dumps(osquery_signal_names)
		osquery_events_ids = json.dumps(osquery_events_ids)		

		DETECTION_INSERT = """
		insert into 
			detection 
		(score, score_label, signals, name_tags, osquery_events_ids, message) 
			values 
		('{score}', '{score_label}', '{signals}', '{name_tags}', '{osquery_events_ids}', '{message_json}')
		""".strip()

		detection_insert_statement = DETECTION_INSERT.format(
			score=score, 
			score_label=score_label,
			signals=signals_count, 
			name_tags=name_tags, 
			osquery_events_ids=osquery_events_ids,
			message_json=message_json 
		)		
		insert_database_record(agent_ip, detection_insert_statement)
	else:
		detection_event = None
		#print("no detections")


@celery_app.task
def detection_run_parallel_db_conn(agent_ip):

	try:
		detection_run_parallel_db_conn_task(agent_ip)
	except Exception as e:
		print("exception: ", e)



#@celery_app.task
def syst_profile_analysis(agent_db):
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
		message->>'action' = 'added' 
	and 
		created_on >= NOW() - INTERVAL '1 DAY';
	""".strip()

	cursor.execute(OSQ_QUERY)
	osquery_events = cursor.fetchall()

	osquery_events_list = []
	for item in osquery_events:
		event_id=item[0]
		osquery_event=item[1]
		osquery_events_list.append( osquery_event['name'] )

	osquery_events_count = Counter(osquery_events_list).most_common()

	for item in osquery_events_count:
		indicator_name = item[0]
		count = item[1]

		cursor.execute(
			"""
			select indicator_name from system_profile_historical where indicator_name = '{indicator_name}' and date = '{date}';
			""".strip().format(
					indicator_name=str(indicator_name), 
					date=datetime.datetime.now().date()
				)
		)
		osquery_events = cursor.fetchone()

		if osquery_events == None:
			cursor.execute( 
				"""
				INSERT INTO 
					system_profile_historical (indicator_name, count, date) 
				values 
					( '{indicator_name}', '{count}', '{date}' )
				""".strip().format(
						indicator_name=str(indicator_name), 
						count=count, 
						date=datetime.datetime.now().date() 
					)
			)
			connection.commit()
		else:
			cursor.execute( 
				"""
				UPDATE 
					system_profile_historical
				SET 
					count = '{count}' 
				where
					indicator_name = '{indicator_name}' AND date = '{date}'
				""".strip().format(
						count=count, 
						indicator_name=str(indicator_name), 
						date=datetime.datetime.now().date() 
					)
			)
			connection.commit()

		cursor.execute(
			"""
			select * from system_profile_historical where indicator_name = '{indicator_name}';
			""".strip().format(
					indicator_name=str(indicator_name), 
					date=datetime.datetime.now().date()
				)
		)
		daily_counts = cursor.fetchall()

		daily_counts_arr = []
		for daily_count in daily_counts:
			daily_count = daily_count[2]
			daily_counts_arr.append(daily_count)

		np_arr = np.array(daily_counts_arr)
		no_outliers, outliers_arr = detect_outliers(np_arr)

		try:
			no_outliers_avg = int(sum(no_outliers)/len(no_outliers))
			threshold_avg = int(no_outliers_avg * 1.3)

			cursor.execute(
				"""
				select * from system_profile_averages where indicator_name = '{indicator_name}';
				""".strip().format(
						indicator_name=str(indicator_name), 
					)
			)
			indicator_averages = cursor.fetchone()

			if indicator_averages == None:
				pass 
				cursor.execute( 
					"""
					INSERT INTO 
						system_profile_averages (indicator_name, threshold_val, no_outliers_avg) 
					values 
						( '{indicator_name}', '{threshold_val}', '{no_outliers_avg}' )
					""".strip().format(
							indicator_name=str(indicator_name), 
							threshold_val=threshold_avg,
							no_outliers_avg=no_outliers_avg
						)
				)
				connection.commit()
			else:
				cursor.execute( 
					"""
					UPDATE 
						system_profile_averages
					SET 
						threshold_val = '{threshold_val}', no_outliers_avg = '{no_outliers_avg}' 
					where
						indicator_name = '{indicator_name}'
					""".strip().format(
							indicator_name=str(indicator_name), 
							threshold_val=threshold_avg,
							no_outliers_avg=no_outliers_avg 
						)
				)
				connection.commit()

		except:
			pass 



@celery_app.task
def syst_profile_anomaly_detection(agent_ip):
	OSQ_QUERY = """
	select 
		* 
	from 
		osquery 
	where 
		message->>'action' = 'added' 
	and 
		created_on >= NOW() - INTERVAL '1 DAY';
	""".strip()

	osquery_events = query_database_records(agent_ip, OSQ_QUERY, 'all')

	osquery_events_list = []
	for item in osquery_events:
		event_id=item[0]
		osquery_event=item[1]
		osquery_events_list.append( osquery_event['name'] )

	osquery_events_count = Counter(osquery_events_list).most_common()

	for item in osquery_events_count:
		indicator_name = item[0]
		daily_count = item[1]

		try:
			SYST_PROFILE_AVERAGES_QUERY = """
			select * from system_profile_averages where indicator_name = '{indicator_name}';
			""".strip().format(
					indicator_name=str(indicator_name), 
			)
			indicator_profile_averages = query_database_records(agent_ip, SYST_PROFILE_AVERAGES_QUERY, 'all')

			for item in indicator_profile_averages:
				indicator_threshold = item[2]
				no_outliers_avg = item[3]

				if daily_count > indicator_threshold:
					osquery_events_ids = []
					for item in osquery_events:
						event_id=item[0]
						osquery_event=item[1]
						indicator_name_target = osquery_event['name']

						if indicator_name_target == indicator_name:
							osquery_events_ids.append({"id": str(event_id)})

					osquery_events_ids = json.dumps(osquery_events_ids)

					DETECTION_INSERT_QUERY = """
					insert into 
						detection 
					(score, signals, name_tags, osquery_events_ids) 
						values 
					('{score}', '{signals}', '{name_tags}', '{osquery_events_ids}')
					""".strip()

					description_anomalous_event = str(indicator_name) + ': statistically higher than normal volume of ' + str(indicator_name) + ' events detected. Typical events count for this system is: ' + str(no_outliers_avg) + '.Events count today: ' + str(daily_count)
					name_tags = json.dumps([{"signal_name": description_anomalous_event }])

					detection_insert_statement = DETECTION_INSERT_QUERY.format(
						score='12', 
						signals=daily_count, 
						name_tags=name_tags,
						osquery_events_ids=osquery_events_ids
					)
					insert_database_record(agent_ip, detection_insert_statement)
				else:
					pass 
		except:
			pass 

		else:
			pass 