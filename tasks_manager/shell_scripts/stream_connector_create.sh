#!/bin/bash


AGENT_IP=$1
TABLE_NAME=$2 
MESSAGE_FORMAT=$3
STREAM_NAME=$4

AGENT_IP_HYPHENS=$(echo "$AGENT_IP" | tr . -)
dot_replaced=$(echo "$AGENT_IP" | tr . _)
AGENT_DB=$dot_replaced"_db"

docker exec -i impulse-datastore psql --username=postgres -d $AGENT_DB -c "CREATE TABLE public."$TABLE_NAME" (id SERIAL PRIMARY KEY, message "$MESSAGE_FORMAT", created_on timestamp without time zone DEFAULT now() );"

input(type="imfile" File="/var/log/impulse/agent-"$AGENT_IP_HYPHENS"/"$STREAM_NAME".log" Tag=$STREAM_NAME)

template(name="apache2-template" type="list" option.sql="on") {
  constant(value="INSERT INTO apache2 (message) values ('")
  property(name="msg")
  constant(value="')")
}
if $programname == "apache2-access-192-168-0-39" then
action(
        type="ompgsql"
        server="127.0.0.1"
        port="7543"
        user="postgres"
        pass=`echo $POSTGRES_PASSWORD` db="192_168_0_39_db"
        template="apache2-template"
)