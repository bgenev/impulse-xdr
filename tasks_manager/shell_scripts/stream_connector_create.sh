#!/bin/bash



# Add table to the sensor db 
# docker exec -i impulse-datastore psql --username=postgres -d 192_168_0_39_db -c "CREATE TABLE public.apache2 (id SERIAL PRIMARY KEY, message TEXT, created_on timestamp without time zone DEFAULT now() );"


# Add rsyslog settings

# # Apache2
# $InputFileName /var/log/impulse/agent-192-168-0-39/apache2-access.log
# $InputFileTag apache2-access-192-168-0-39
# $InputFileStateFile apache2-access-192-168-0-39
# $InputFilePollInterval 10
# $InputRunFileMonitor

# template(name="apache2-template" type="list" option.sql="on") {
#   constant(value="INSERT INTO apache2 (message) values ('")
#   property(name="msg")
#   constant(value="')")
# }
# if $programname == "apache2-access-192-168-0-39" then
# action(
#         type="ompgsql"
#         server="127.0.0.1"
#         port="7543"
#         user="postgres"
#         pass=`echo $POSTGRES_PASSWORD` db="192_168_0_39_db"
#         template="apache2-template"
# )