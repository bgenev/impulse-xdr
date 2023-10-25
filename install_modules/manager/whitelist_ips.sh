#!/bin/bash


last_ips=$(last | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort | uniq)
while IFS= read -r line; do
    docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) SELECT ('"$line"') where not exists (SELECT ip_addr FROM whitelisted_ips WHERE ip_addr = '"$line"');"
done <<< "$last_ips"


# sed -i '$a\' /opt/impulse/whitelisted.txt
# while read -u 9 LINE; 
# do
#   docker exec -i impulse-datastore psql --username=postgres -d impulse_manager -c "INSERT INTO whitelisted_ips (ip_addr) SELECT ('"$LINE"') where not exists (SELECT ip_addr FROM whitelisted_ips WHERE ip_addr = '"$LINE"');"
# done 9< /opt/impulse/whitelisted.txt