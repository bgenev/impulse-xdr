#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

from main import db 

from sqlalchemy.dialects.postgresql import JSONB, BIGINT


class SuricataAlerts(db.Model):
	__tablename__ = 'suricata_alerts'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column( JSONB )
	created_on = db.Column(db.DateTime, server_default=db.func.now())
	agent_id = db.Column(db.String(50))
	saved = db.Column(db.Boolean)
	assigned_to = db.Column(db.String(1000)) # user id or username 

class DataTransfers(db.Model):
	__tablename__ = 'data_transfers'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column( JSONB )
	created_on = db.Column(db.DateTime, server_default=db.func.now())
	agent_id = db.Column(db.String(50))
	saved = db.Column(db.Boolean)
	assigned_to = db.Column(db.String(1000)) # user id or username 

class SuricataDns(db.Model):
	__tablename__ = 'suricata_dns'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataEveFlow(db.Model):
	__tablename__ = 'suricata_eve_flow'
	id = db.Column(BIGINT, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class SuricataEveFlowDerived(db.Model):
	__tablename__ = 'suricata_eve_flow_derived'
	id = db.Column(BIGINT, primary_key=True)
	ip_addr = db.Column(db.String(50))
	total_received = db.Column(db.Float)
	total_sent = db.Column(db.Float)
	total_inbound = db.Column(db.Float)
	total_outbound = db.Column(db.Float)
	batch_date = db.Column(db.DateTime)
	# start_time = db.Column(db.DateTime) # first record timestamp
	# end_time = db.Column(db.DateTime) # last record timestamp


class SuricataDerivedTable(db.Model):
	__tablename__ = 'suricata_derived_table'
	id = db.Column(BIGINT, primary_key=True)
	#ip_addr = db.Column(db.String(50))
	indicator_name = db.Column(db.String(1000))
	indicator_type = db.Column(db.String(100)) 
	events_count = db.Column(db.Integer)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class OSqueryDerivedTable(db.Model):
	__tablename__ = 'osquery_derived_table'
	id = db.Column(BIGINT, primary_key=True)
	indicator_name = db.Column(db.String(1000))
	indicator_type = db.Column(db.String(100)) 
	events_count = db.Column(db.Integer)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class SuricataSsh(db.Model):
	__tablename__ = 'suricata_ssh'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataHttp(db.Model):
	__tablename__ = 'suricata_http'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataTls(db.Model):
	__tablename__ = 'suricata_tls'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataFtp(db.Model):
	__tablename__ = 'suricata_ftp'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataDhcp(db.Model):
	__tablename__ = 'suricata_dhcp'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataFiles(db.Model):
	__tablename__ = 'suricata_files'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataSmb(db.Model):
	__tablename__ = 'suricata_smb'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

class SuricataSmtp(db.Model):
	__tablename__ = 'suricata_smtp'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class OSquery(db.Model):
	__tablename__ = 'osquery'
	id = db.Column(db.Integer, primary_key=True)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())

# class Detection(db.Model):
# 	__tablename__ = 'detection'
# 	id = db.Column(db.Integer, primary_key=True)
# 	score = db.Column(db.String(20))
# 	score_label = db.Column(db.String(20))
# 	signals = db.Column(db.Integer)
# 	name_tags = db.Column(JSONB)
# 	osquery_events_ids = db.Column(JSONB)
# 	suricata_events_ids = db.Column(JSONB)
# 	message = db.Column(JSONB)
# 	osquery_events = db.Column(JSONB)
# 	created_on = db.Column(db.DateTime, server_default=db.func.now())


class Detection(db.Model):
	__tablename__ = 'detection'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	agent_ip = db.Column(db.String(20))
	score = db.Column(db.String(20))
	score_label = db.Column(db.String(20))
	signals = db.Column(db.Integer)
	name_tags = db.Column(JSONB)
	osquery_events_ids = db.Column(JSONB)
	suricata_events_ids = db.Column(JSONB)
	message = db.Column(JSONB)
	osquery_events = db.Column(JSONB)
	resolved_status = db.Column(db.String(20), default='Not Resolved')
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class UbaSsh(db.Model):
	__tablename__ = 'uba_ssh'
	id = db.Column(db.Integer, primary_key=True)
	host_ip_addr = db.Column(db.String(30))


## Notifications
class NotificationsSettings(db.Model):
	__tablename__ = 'notifications_settings'
	id = db.Column(db.Integer, primary_key=True)
	notifications = db.Column(db.String(200))


class Notification(db.Model):
	__tablename__ = 'notification'
	id = db.Column(db.Integer, primary_key=True)
	notification_message = db.Column(db.String(200))
	task_id =  db.Column(db.Integer)
	timestamp = db.Column(db.DateTime())


## Ticket
class Ticket(db.Model):
	__tablename__ = 'ticket'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ticket_title = db.Column(db.String(500))
	ticket_description = db.Column(db.String(50000))
	assigned_to = db.Column(db.String(1000))
	reporter = db.Column(db.String(1000))
	selected_events = db.Column(JSONB) 
	table_type = db.Column(db.String(100))
	agent_ip = db.Column(db.String(100))
	status = db.Column(db.String(100), default='Open')
	priority = db.Column(db.String(100), default='Info')
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, server_default=db.func.now())
	updated_on = db.Column(db.DateTime, default=db.func.now())


class TicketComment(db.Model):
	__tablename__ = 'ticket_comment'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ticket_id = db.Column(db.String(500))
	comment = db.Column(db.String(50000))
	user_id = db.Column(db.String(1000))
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class InvestigatedEvents(db.Model):
	__tablename__ = 'investigated_event'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ticket_id = db.Column(db.String(50))
	event_id = db.Column(db.String(50))
	table_type = db.Column(db.String(20))
	affected_asset_ip = db.Column(db.String(20))
	created_on = db.Column(db.DateTime, server_default=db.func.now())


## Manager Agent
class RemoteAgent(db.Model):
	__tablename__ = 'remote_agent'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ip_addr = db.Column(db.String(100))
	agent_id = db.Column(db.String(100))
	agent_db = db.Column(db.String(100))
	agent_type = db.Column(db.String(100))
	group_label = db.Column(db.String(100), default='general')
	os_type = db.Column(db.String(100), default='unknown')
	os_type_verbose = db.Column(db.String(100), default='unknown')
	package_manager = db.Column(db.String(100))
	pre_shared_key = db.Column(db.String(100))
	access_token = db.Column(db.String(5000), default=None )
	alias = db.Column(db.String(100))
	country_short = db.Column(db.String(100))
	country_long = db.Column(db.String(100))
	region = db.Column(db.String(100))
	city = db.Column(db.String(100))
	status = db.Column(db.Boolean)
	overall_status = db.Column(db.Boolean)
	modules_status = db.Column(JSONB)
	impulse_main_status = db.Column(db.String(20))
	impulse_bgtasks_status = db.Column(db.String(20))
	impulse_containers_status = db.Column(db.String(20))
	impulse_osqueryd_status = db.Column(db.String(20))
	manager_receiving_data = db.Column(db.Boolean)
	last_check_in = db.Column(db.String(100)) # db.DateTime, server_default=db.func.now()
	build_status_report = db.Column(JSONB)
	ioc_last_state = db.Column(JSONB)
	vuls_scan_profile = db.Column(JSONB)
	updated_at = db.Column(db.DateTime)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class Manager(db.Model):
	__tablename__ = 'manager'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ip_addr = db.Column(db.String(100))
	manager_database = db.Column(db.String(100))
	manager_alias = db.Column(db.String(100))
	active_agent_database = db.Column(db.String(100))
	active_agent_ip = db.Column(db.String(100))
	active_agent_alias = db.Column(db.String(100))
	country_short = db.Column(db.String(100))
	country_long = db.Column(db.String(100))
	region = db.Column(db.String(100))
	city = db.Column(db.String(100))
	status = db.Column(db.Boolean)
	license_key = db.Column(db.String(1000))
	license_type = db.Column(db.String(100))
	access_token_license = db.Column(db.String(5000))
	license_signature = db.Column(db.String(1000))
	license_expiration_date = db.Column(db.DateTime)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class AssetGroups(db.Model):
	__tablename__ = 'asset_groups'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	group_label = db.Column(db.String(100), default='general')

class SiteUser(db.Model):
	__tablename__ = 'site_user'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	public_id = db.Column(db.String(50), unique=True)
	name = db.Column(db.String(200))
	username = db.Column(db.String(200))
	password = db.Column(db.String(200))
	user_type = db.Column(db.String(200))
	email = db.Column(db.String(200))
	smtp_server = db.Column(db.String(200))
	smtp_username = db.Column(db.String(200))
	smtp_password = db.Column(db.String(200))
	smtp_port = db.Column(db.String(200))
	#admin = db.Column(db.Boolean)
	email_alerts = db.Column(db.Boolean, default=False)
	general_status_report = db.Column(db.Boolean, default=False)
	general_status_report_interval = db.Column(db.String(200), default="7")
	last_login = db.Column(db.DateTime)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class OSqueryRulesetExceptions(db.Model):
	__tablename__ = 'osquery_ruleset_exceptions'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	indicator_name = db.Column(db.String(100))
	exception_param = db.Column(db.String(500))
	exception_value = db.Column(db.String(1000))
	rule_string = db.Column(db.String(1000))


class IPsSafetyStatus(db.Model):
	__tablename__ = 'ips_safety_status'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ip_remote_host = db.Column(db.String(100))
	safety_score = db.Column(db.String(100))
	safety_label = db.Column(db.String(100))

	isp = db.Column(db.String(1000))
	domain = db.Column(db.String(1000))
	hostnames = db.Column(db.String(10000))
	
	country_code = db.Column(db.String(100))
	country_name = db.Column(db.String(100))
	abuse_confidence_score = db.Column(db.String(100))

	local_geoip_obj = db.Column(JSONB)

	pkg_mgmt_related = db.Column(db.Boolean, default=False)

	blocked_status = db.Column(db.Boolean, default=False)
	whitelisted = db.Column(db.Boolean, default=False)
	date_blocked = db.Column(db.DateTime )

	message = db.Column(JSONB)

	last_synced_with_db = db.Column(db.DateTime())

	created_on = db.Column(db.DateTime, server_default=db.func.now())



class WhitelistedIps(db.Model):
	__tablename__ = 'whitelisted_ips'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ip_addr = db.Column(db.String(100))
	whitelisted_status = db.Column(db.Boolean, default=True)
	created_on = db.Column( db.DateTime(), server_default=db.func.now())


class VirusTotalChecks(db.Model):
	__tablename__ = 'virus_total_checks'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	file_hash = db.Column(db.String(1000))
	vt_obj = db.Column(JSONB)
	last_synced_with_db = db.Column( db.DateTime() )


class MalwareScanner(db.Model):
	__tablename__ = 'malware_scanner'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	file_hash = db.Column(db.String(1000))
	target_path = db.Column(db.String(1000))
	host_detected_on = db.Column(db.String(100)) # or perhaps use agent id? 
	date_found = db.Column( db.DateTime(), server_default=db.func.now())


class SystemProfileHistorical(db.Model):
	__tablename__ = 'system_profile_historical'
	id = db.Column(db.Integer, primary_key=True)
	indicator_name = db.Column(db.String(1000))
	indicator_count = db.Column( db.Integer )
	batch_date =  db.Column( db.DateTime() )


## This should be part of impulse_manager
class SystemProfileAverages(db.Model):
	__tablename__ = 'system_profile_averages'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	category_name = db.Column(db.String(1000))
	threshold_val = db.Column( db.Integer )
	no_outliers_avg = db.Column( db.Integer )
	history_arr = db.Column(JSONB)
	affected_asset = db.Column(db.String(100))


class ProcessedAnalytics(db.Model):
	__tablename__ = 'processed_analytics'
	#__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	indicator_name = db.Column(db.String(10000))
	indicator_count = db.Column(db.Integer)
	indicator_table = db.Column(db.String(100))
	category = db.Column(db.String(100))
	affected_asset = db.Column(db.String(100))
	batch_date = db.Column(db.Date())


class PackagesCvesMap(db.Model):
	__tablename__ = 'packages_cves_map'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	package_name = db.Column(db.String(100))
	cve_severity = db.Column(db.String(100))
	cve_id = db.Column(db.String(100))
	cve_data = db.Column(JSONB)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime())
	

class AssetsPackagesInstalled(db.Model):
	__tablename__ = 'assets_packages_installed'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	asset_id = db.Column(db.String(1000))
	package_name = db.Column(db.String(1000))


class AnalyticsBatchesMeta(db.Model):
	__tablename__ = 'analytics_batches_meta'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	agent_ip = db.Column(db.String(100))
	osquery_last_id_analysed = db.Column(db.Integer, default=0)

	suricata_alerts_last_id_analysed = db.Column(db.Integer, default=0)
	suricata_ssh_last_id_analysed = db.Column(db.Integer, default=0)
	suricata_http_last_id_analysed = db.Column(db.Integer, default=0)
	suricata_dns_last_id_analysed = db.Column(db.Integer, default=0)
	suricata_tls_last_id_analysed = db.Column(db.Integer, default=0)
	suricata_files_last_id_analysed = db.Column(db.Integer, default=0)
	suricata_dhcp_last_id_analysed = db.Column(db.Integer, default=0)
	suricata_eve_flow_last_id_analysed = db.Column(db.Integer, default=0)

	fim_last_id_analysed = db.Column(db.Integer, default=0)
	timestamp_sync_last_id_suricata = db.Column(db.Integer, default=0)
	timestamp_sync_last_id_osquery = db.Column(db.Integer, default=0)


class OSqueryPacks(db.Model):
	__tablename__ = 'osquery_packs'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	pack_name = db.Column(db.String(100))
	pack_type = db.Column(db.String(100))
	description = db.Column(db.String(1000))
	pack_id = db.Column(db.String(100))
	pack_version = db.Column(db.Integer, default=1)
	updated_on = db.Column(db.DateTime, server_default=db.func.now())
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class PackDeployments(db.Model):
	__tablename__ = 'pack_deployments'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	asset_ip = db.Column(db.String(1000))
	pack_id = db.Column(db.String(1000))
	pack_version = db.Column(db.Integer)
	pack_status_on_agent = db.Column(db.Boolean, default=True)
	deployment_status = db.Column(db.Boolean, default=False)
	updated_on = db.Column(db.DateTime, server_default=db.func.now())
	created_on = db.Column(db.DateTime, server_default=db.func.now())


# class PolicyPacksQueries(db.Model):
# 	__tablename__ = 'policy_packs_queries'
# 	__bind_key__ = 'impulse_manager'
# 	id = db.Column(db.Integer, primary_key=True)
# 	pack_id = db.Column(db.String(100))
# 	query_string  = db.Column(db.String(1000))


class PackQueries(db.Model):
	__tablename__ = 'pack_queries'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	pack_id = db.Column(db.String(100))
	query_string  = db.Column(db.String(1000))
	query_type  = db.Column(db.String(100))
	description  = db.Column(db.String(1000), default="tbd")
	name  = db.Column(db.String(100), default="tbd")
	

class ScpPacksAlerts(db.Model):
	__tablename__ = 'scp_packs_alerts'
	id = db.Column(db.Integer, primary_key=True)
	agent_ip = db.Column(db.String(50))
	pack_name = db.Column(db.String(1000))
	query_id = db.Column(db.Integer)
	test_state = db.Column(db.String(100))
	resolved = db.Column(db.Boolean, default=False)
	message = db.Column(JSONB)
	created_on = db.Column(db.DateTime, default=db.func.now() )


class ScpResults(db.Model):
	__tablename__ = 'scp_results'
	id = db.Column(db.Integer, primary_key=True)
	agent_ip = db.Column(db.String(50))
	pack_name = db.Column(db.String(1000))
	query_id = db.Column(db.Integer)
	test_state = db.Column(db.String(100))
	updated_on = db.Column(db.DateTime, default=db.func.now() )


class ScaResults(db.Model):
	__tablename__ = 'sca_results'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	agent_ip = db.Column(db.String(50))
	rule_id = db.Column(db.Integer)
	test_state = db.Column(db.String(100))
	updated_on = db.Column(db.DateTime, server_default=db.func.now())


class ScaAlerts(db.Model):
	__tablename__ = 'sca_alerts'
	id = db.Column(db.Integer, primary_key=True)
	agent_ip = db.Column(db.String(50))
	rule_id = db.Column(db.Integer)
	test_state = db.Column(db.String(100))
	created_on = db.Column(db.DateTime)


class AsyncTasks(db.Model):
	__tablename__ = 'async_tasks'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	task_id = db.Column(db.String(1000))
	task_type = db.Column(db.String(1000))
	agent_ip = db.Column(db.String(50))
	completion_state = db.Column(db.Boolean, default=False)
	completed_on = db.Column(db.DateTime)
	created_on = db.Column(db.DateTime, server_default=db.func.now())


class ImpulseTasksTracker(db.Model):
	__tablename__ = 'impulse_tasks_tracker'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ip_addr = db.Column(db.String(20))

	offenders_osquery_last_analysed_id = db.Column(db.Integer, default=0)
	offenders_eve_alerts_last_analysed_id = db.Column(db.Integer, default=0)
	offenders_eve_flow_last_analysed_id = db.Column(db.Integer, default=0)

	last_analysed_flow_id = db.Column(db.Integer, default=0)
	last_analysed_flow_created_at = db.Column(db.DateTime)


class FailedTasksBacklog(db.Model):
	__tablename__ = 'failed_tasks_backlog'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	agent_ip = db.Column(db.String(20))
	task_name = db.Column(db.String(50))
	task_id = db.Column(db.String(50))
	completion_state = db.Column(db.Boolean, default=False)
	task_args = db.Column(JSONB)


class AgentDataSnapshots(db.Model):
	__tablename__ = 'agent_data_snapshot'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ip_addr = db.Column(db.String(100))
	system_posture = db.Column(JSONB)
	updated_on = db.Column(db.DateTime, server_default=db.func.now())


class ManPages(db.Model):
	__tablename__ = 'man_pages'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	service_name = db.Column(db.String(100))
	page_data = db.Column(db.String(10000))
	updated_on = db.Column(db.DateTime, server_default=db.func.now())


class SuricataCustomRulesets(db.Model):
	__tablename__ = 'suricata_custom_rulesets'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	ruleset_name = db.Column(db.String(1000))
	ruleset_latest_version = db.Column(db.Integer, default=1)


class SuricataCustomRulesetDeployments(db.Model):
	__tablename__ = 'suricata_custom_ruleset_deployments'
	__bind_key__ = 'impulse_manager'
	id = db.Column(db.Integer, primary_key=True)
	asset_ip = db.Column(db.String(1000))
	ruleset_version = db.Column(db.Integer)
	updated_on = db.Column(db.DateTime, server_default=db.func.now())
	created_on = db.Column(db.DateTime, server_default=db.func.now())



# class ScaTests(db.Model):
# 	__tablename__ = 'sca_results'
# 	__bind_key__ = 'impulse_manager'
# 	id = db.Column(db.Integer, primary_key=True)
# 	rule_id = db.Column(db.Integer)
# 	name = db.Column(db.String(10000))
# 	description = db.Column(db.String(10000))
# 	remediation = db.Column(db.String(10000))
# 	test_query = db.Column(db.String(1000))
# 	compliance = db.Column(db.String(1000))
# 	updated_on = db.Column(db.DateTime)