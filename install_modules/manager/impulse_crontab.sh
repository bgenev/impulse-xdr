#!/bin/bash

PROJECT_ROOT_DIR=$1
AGENT_TYPE=$2


kernelk_cron_file="

# Detections 
# multiproc
*/5 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/detections.sh 

# Daily Rollup  
# multiproc
0 */2 * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/daily_rollup_task.sh

# SCA Tests 
# multiproc
0 11 * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/sca_tests.sh

# SCP Custom Policies 
# multiproc
0 10 * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/scp_custom_tasks.sh

# Fleet Status 
# multiproc
*/5 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/status_fleet.sh

# Threat Intel Data Refresh 
# multiproc
*/30 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/threat_intel_data_refresh.sh

# CVEs Run Scan and Update
# multiproc
0 23 */2 * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/cves_scan.sh

# FIM file_hash scan
# multiproc
*/2 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/fim_mal_scan.sh

# Email notifications 
*/5 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/email_notifications.sh


#### BLOCK SUSPECTS WITH FLEET FIREWALL ####
# Block suspected offenders
*/5 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/block_suspected_offenders.sh

# Sync Impulse fleet firewall 
*/7 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/sync_impulse_fleet_firewall.sh


# Update Suricata Core Ruleset 
0 11 * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/update_suricata_core_ruleset.sh
############################################




#########
# TRAFFIC ACCOUNTING: Net Flows Analysis 
# multiproc
# */5 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/nids_flows_analysis.sh

# Block suspect ips daily volume 
# multiproc
# */59 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/block_suspect_ips_daily_volume.sh

# Block suspect ips weekly volume 
# multiproc
# * 12 * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/block_suspect_ips_weekly_volume.sh
##########

# Anomaly Detection Task 
# 0 */6 * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/anomaly_detection_task.sh

# Analytics BgJob
# */5 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/analytics_run.sh

# Send agents instructions 
# * * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/send_agents_instructions.sh

# Reporting
# 0 10 * * 1 root /opt/impulse/tasks_manager/cron_tasks/reporting.sh

# Traffic Accounting 
# */5 * * * * root $PROJECT_ROOT_DIR/tasks_manager/cron_tasks/traffic_accounting_cron.sh
"

echo "$kernelk_cron_file" > /etc/cron.d/impulse

systemctl restart cron

# if [[ $OS_TYPE = "ubuntu" || $OS_TYPE = "debian" || $OS_TYPE = "linuxmint" ]]; then
# 	# service cron reload 
# 	# service cron restart 
# 	systemctl restart cron
# fi

# if [[ $OS_TYPE = "centos" || $OS_TYPE = "fedora" ]]; then
# 	systemctl restart crond 
# fi