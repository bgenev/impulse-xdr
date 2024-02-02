
import subprocess
import json

from main.helpers.shared.osqueryd_helper import osquery_spawn_instance, osquery_exec


# NFS (Network File System) and related services, including nfsd, lockd, mountd, statd, portmapper, etc.
# The so-called r* (for "remote", i.e. Remote SHell) services: rsh, rlogin, rexec, rcp etc. Unnecessary, insecure and potentially dangerous, and better utilities are available if these capabilities are needed. ssh will do everything these command do, and in a much more sane way
# telnet 
# ftp 
# BIND (named), DNS server package
# Mail Transport Agent, aka "MTA" (sendmail, exim, postfix, qmail).


def get_agent_system_posture(syst_posture_queries):
	instance = osquery_spawn_instance()
	syst_posture_results = {}
	for item in syst_posture_queries:
		result = osquery_exec(instance, item['query'])
		syst_posture_results[ item['name'] ] = result
	return syst_posture_results


def get_man_page_data(service_name):
	subprocess.run("man " + service_name + " > /tmp/man_page_details.txt", shell=True)

	with open('/tmp/man_page_details.txt', 'r') as file:
		data = str( file.read() )
	
	resp = { "service_name": service_name, "page_data": data }
	return resp



