#!/bin/bash

AGENT_IP_ADDR=$1
#AGENT_IP_ADDR='192.168.33.25'

AGENT_IP_HYPHENS=$(echo "$AGENT_IP_ADDR" | tr . -)
TEMPLATE_FILE="/var/impulse/etc/rsyslog/rsyslog.d/agent-"$AGENT_IP_HYPHENS".conf"
AGENT_IP_ADDR_UNDERSCORE=$( echo ${AGENT_IP_ADDR} | tr '.' '_' ) 
AGENT_DB=$AGENT_IP_ADDR_UNDERSCORE"_db"

rm $TEMPLATE_FILE
rm -rf /var/log/impulse/agent-$AGENT_IP_HYPHENS
rm -rf '/opt/impulse/build/agent_build/agent-'$AGENT_IP_HYPHENS'.tar.gz'

#docker restart impulse-datastore

/usr/bin/docker exec -i impulse-datastore psql --username=postgres -c 'DROP DATABASE "'$AGENT_DB'" WITH (FORCE);'

/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from analytics_batches_meta where agent_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from agent_data_snapshot where ip_addr = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from assets_packages_installed where asset_id = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from async_tasks where agent_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from failed_tasks_backlog where agent_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from impulse_tasks_tracker where agent_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from investigated_event where affected_asset_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from pack_deployments where asset_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from remote_agent where ip_addr = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from sca_results where agent_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from ticket where agent_ip = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from suricata_custom_ruleset_deployments where asset_ip = '"$AGENT_IP_ADDR"'"

/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from ips_safety_status where ip_remote_host = '"$AGENT_IP_ADDR"'"
/usr/bin/docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "delete from whitelisted_ips where ip_addr = '"$AGENT_IP_ADDR"'"


docker restart impulse-indexer

