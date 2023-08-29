import os 
import subprocess
import signal
import json
import ipaddress

from main.helpers.shared.osqueryd_helper import osquery_spawn_instance, osquery_exec




def run_osquery_check(osquery_string, agent_ip):
	hosts_results = []

	instance = osquery_spawn_instance()
	result = osquery_exec(instance, osquery_string)

	manager_result_with_agent_ip = []
	for item in result:
		item['agent_ip'] = agent_ip
		manager_result_with_agent_ip.append(item)
	hosts_results = hosts_results + manager_result_with_agent_ip

	if not hosts_results:
		resp = False
	else:
		resp = True 

	return resp


def exec_linux_cmd(linux_cmdline):
	p = subprocess.run(linux_cmdline, shell=True)
	if p.returncode == 0:
		action_subprocess_success = True
		action_subprocess_msg = 'Action executed successfully.'
	else:
		action_subprocess_success = False
		action_subprocess_msg = 'Failed to execute action.'	
	return action_subprocess_success, action_subprocess_msg


def stop_process(pid):
	try:
		os.kill(int(pid), signal.SIGKILL)
		action_subprocess_success = True
		action_subprocess_msg = 'Process was killed successfully.'		
	except:
		action_subprocess_success = False
		action_subprocess_msg = 'Process does not exist. It has already been stopped.'

	return action_subprocess_success, action_subprocess_msg	


def take_action(indicator_name, target_param, target_agent):
	if indicator_name == 'processes':
		pid = target_param
		action_subprocess_success, action_subprocess_msg = stop_process(pid)
		action_success_check = osquery_check_pid(pid, target_agent)

	elif indicator_name == 'socket_events':
		pid = target_param
		action_subprocess_success, action_subprocess_msg = stop_process(pid)
		action_success_check = osquery_check_pid(pid, target_agent)

	elif indicator_name == 'active_connections':
		pid = target_param
		action_subprocess_success, action_subprocess_msg = stop_process(pid)
		action_success_check = osquery_check_pid(pid, target_agent)

	elif indicator_name == 'listening_ports':
		pid = target_param
		action_subprocess_success, action_subprocess_msg = stop_process(pid)
		action_success_check = osquery_check_pid(pid, target_agent)		

	elif indicator_name == 'generic_stop_process':
		pid = target_param
		action_subprocess_success, action_subprocess_msg = stop_process(pid)
		action_success_check = osquery_check_pid(pid, target_agent)

	elif indicator_name == 'deb_packages':
		package_name = target_param
		linux_cmdline = 'apt purge -y ' + package_name
		action_subprocess_success, action_subprocess_msg = exec_linux_cmd(linux_cmdline)
		action_success_check = osquery_check_deb_package(package_name, target_agent)

	elif indicator_name == 'kernel_modules':
		module_name = target_param
		linux_cmdline = 'modprobe -r ' + module_name
		action_subprocess_success, action_subprocess_msg = exec_linux_cmd(linux_cmdline)
		action_success_check = osquery_check_kernel_module(module_name, target_agent)

	elif indicator_name == 'users':
		username = target_param
		linux_cmdline = 'deluser --remove-home ' + username
		action_subprocess_success, action_subprocess_msg = exec_linux_cmd(linux_cmdline)
		action_success_check = osquery_check_user(username, target_agent)

	elif indicator_name == 'last':
		username = target_param
		linux_cmdline = 'pkill -KILL -u ' + username
		action_subprocess_success, action_subprocess_msg = exec_linux_cmd(linux_cmdline)
		action_success_check = osquery_check_logged_in(username, target_agent)
		
	elif indicator_name == 'file_events':
		filepath = target_param
		filename = os.path.basename(filepath)
		linux_cmdline = 'mv ' + filepath + ' /var/impulse/data/quarantined_files'
		#print("linux_cmdline: ", linux_cmdline)
		action_subprocess_success, action_subprocess_msg = exec_linux_cmd(linux_cmdline)
		# linux_cmdline = 'chmod 600 /var/impulse/data/quarantined_files/' + filename
		# linux_cmdline = 'chmod -x /var/impulse/data/quarantined_files/' + filename
		action_success_check = os_check_file(filepath,target_agent)
	else: 
		pass 

	return action_subprocess_success, action_subprocess_msg, action_success_check
	

def osquery_check_pid(pid, target_agents):
	osquery_cmd = "select * from processes where pid = '" + pid + "';"
	result = run_osquery_check(osquery_cmd, target_agents)
	return result

def osquery_check_active_connection(remote_address, target_agents):
	osquery_cmd = "select * from process_open_sockets where remote_address = '" + remote_address + "';"
	result = run_osquery_check(osquery_cmd, target_agents)
	return result

def osquery_check_deb_package(package_name, target_agents):
	osquery_cmd =  "select * from deb_packages where name = '" + package_name + "';"
	result = run_osquery_check(osquery_cmd, target_agents)
	return result

def osquery_check_kernel_module(module_name, target_agents):
	osquery_cmd =  "select * from kernel_modules where name = '" + module_name + "';"
	result = run_osquery_check(osquery_cmd, target_agents)
	return result

def osquery_check_user(username, target_agents):
	osquery_cmd =  "select * from users where username = '" + username + "';"
	result = run_osquery_check(osquery_cmd, target_agents)
	return result

def osquery_check_logged_in(username, target_agents):
	osquery_cmd =  "select * from logged_in_users where user = '" + username + "';"
	result = run_osquery_check(osquery_cmd, target_agents)
	return result


def os_check_file(target_path, target_agents):
	check_file = os.path.isfile(target_path)
	if check_file == True:
		resp = True
	else:
		resp = False 
	return resp 


def check_can_take_action(indicator_name,target_param, target_agent):
	if indicator_name == 'processes':
		pid = target_param
		resp = osquery_check_pid(pid, target_agent)
		msg = "PID " + pid

	elif indicator_name == 'socket_events':
		pid = target_param
		resp = osquery_check_pid(pid, target_agent)
		msg = "PID " + pid

	elif indicator_name == 'active_connections':
		remote_address = target_param
		resp = osquery_check_active_connection(remote_address, target_agent)
		msg = "Connection to " + remote_address

	elif indicator_name == 'listening_ports':
		pid = target_param
		resp = osquery_check_pid(pid, target_agent)
		msg = "PID " + pid

	elif indicator_name == 'generic_stop_process':
		pid = target_param
		resp = osquery_check_pid(pid, target_agent)
		msg = "PID " + pid

	elif indicator_name == 'deb_packages':
		package_name = target_param
		resp = osquery_check_deb_package(package_name, target_agent)
		msg = "Package " + package_name

	elif indicator_name == 'kernel_modules':
		module_name = target_param
		resp = osquery_check_kernel_module(module_name, target_agent)
		msg = "Module " + module_name

	elif indicator_name == 'users':
		username = target_param
		resp = osquery_check_user(username, target_agent)
		msg = "User " + username

	elif indicator_name == 'last':
		username = target_param
		resp = osquery_check_logged_in(username, target_agent)
		msg = "Log in session for user " + username

	elif indicator_name == 'file_events':
		target_path = target_param
		resp = os_check_file(target_path, target_agent)
		msg = "File " + target_path
	else: 
		pass 

	if resp == False:
		respJson = { "state": False, "msg": msg }
	else:
		respJson = { "state": True, "msg": msg }

	return respJson


def find_rule_handle_in_chain(ip_addr, chain):
	rule_handle = None

	for item in chain['nftables']:
		if 'rule' in item:
			expr_list = item['rule']['expr']
			rule_handle_nft = item['rule']['handle']

			for i in expr_list:
				if 'match' in i:
					ip_addr_table = i['match']['right']
					if ip_addr == ip_addr_table:
						rule_handle = rule_handle_nft
						break 
					else:
						pass 
				else:
					pass 
		else:
			pass 
	return rule_handle


def get_nft_rule_handle(ip_addr):
	input_chain_json, output_chain_json = load_impulse_chains()
	rule_handle_input_chain = find_rule_handle_in_chain(ip_addr, input_chain_json)
	rule_handle_output_chain = find_rule_handle_in_chain(ip_addr, output_chain_json)
	return rule_handle_input_chain, rule_handle_output_chain


def exec_subprocess_run(cmd):
	return json.loads( subprocess.run(cmd, shell=True, capture_output=True).stdout )


def load_impulse_chains():
	input_chain_cmd = "nft --handle --numeric --json list chain inet impulse_table impulse_input_chain"
	output_chain_cmd = "nft --handle --numeric --json list chain inet impulse_table impulse_output_chain"

	input_chain_json = exec_subprocess_run(input_chain_cmd)
	output_chain_json = exec_subprocess_run(output_chain_cmd)

	return input_chain_json, output_chain_json


def get_address_family(ip_addr):
	address_family = None 
	try:
		ipaddress.IPv4Address(ip_addr)
		address_family = 'ip'
	except:
		pass 
	try:
		ipaddress.IPv6Address(ip_addr)
		address_family = 'ip6'
	except:
		pass 
	return address_family


def check_whitelisted(ip_addr):
	proceed_to_block = True
	## TODO model is not imported 
	ip_addr_whitelisted = WhitelistedIps.query.filter_by(ip_addr=ip_addr).first()

	if ip_addr_whitelisted != None:
		proceed_to_block = False
	elif ipaddress.ip_address(ip_addr).is_private == True:
		proceed_to_block = False
	elif '192.168.' in ip_addr:
		proceed_to_block = False
	else:
		pass 
	return proceed_to_block


def nft_block(ip_addr, state_action):
	if state_action == 'block':
		proceed_to_block = check_whitelisted(ip_addr)
		if proceed_to_block == True:
			address_family = get_address_family(ip_addr)
			block_in_cmd = "nft add rule inet impulse_table impulse_input_chain " + address_family + " saddr " + ip_addr + " drop"
			subprocess.run(block_in_cmd, shell=True)

			block_out_cmd = "nft add rule inet impulse_table impulse_output_chain " + address_family + " daddr " + ip_addr + " drop" 
			subprocess.run(block_out_cmd, shell=True)
		else:
			pass 

	elif state_action == 'unblock':
		rule_handle_input_chain, rule_handle_output_chain = get_nft_rule_handle(ip_addr)

		if rule_handle_input_chain != None:
			unblock_in_cmd = "nft delete rule inet impulse_table impulse_input_chain handle " + str(rule_handle_input_chain)
			subprocess.run(unblock_in_cmd, shell=True)
		else:
			pass 

		if rule_handle_output_chain != None:
			unblock_out_cmd = "nft delete rule inet impulse_table impulse_output_chain handle " + str(rule_handle_output_chain)
			subprocess.run(unblock_out_cmd, shell=True)
		else:
			pass 
	else:
		pass 

	pass 



def apply_ips_list(ips_list, state_action):
	try:
		for ip_addr in ips_list:
			nft_block(ip_addr, state_action)

		task_result = True
	except:
		task_result = False

	return task_result


def get_impulse_chain_ips_list(chain_json):
	impulse_chain_ips_list = []
	for item in chain_json['nftables']:
		try:
			ip_addr = item['rule']['expr'][0]['match']['right']
			impulse_chain_ips_list.append(ip_addr)
		except:
			pass
	return impulse_chain_ips_list


def ensure_impulse_nft_table_exists():
	try:
		check_table_exists = "nft --json list table inet impulse_table"
		subprocess.run(check_table_exists, shell=True, check=True, timeout=15, capture_output=True)
	except subprocess.CalledProcessError as e:
		# print(e, "..impulse_table not found..create it")
		apply_saved_impulse_table_rules_cmd = "nft -f /var/impulse/etc/nftables/nftables_impulse_table.rules"
		subprocess.run(apply_saved_impulse_table_rules_cmd, shell=True)

def save_impulse_table_ruleset():
	save_impulse_table_rules = "nft list table inet impulse_table > /var/impulse/etc/nftables/nftables_impulse_table.rules"
	subprocess.run(save_impulse_table_rules, shell=True)


def restart_nftables_service():
	#print("restart nftables.service")
	#subprocess.run("systemctl restart nftables.service", shell=True)
	pass 



def sync_impulse_fw_with_cs(ips_list_cs, state_action):	
	nft_ruleset_filepath = '/var/impulse/etc/nftables/nftables_impulse_table.rules'
	
	with open(nft_ruleset_filepath, "w") as nft_ruleset_file:
		nft_ruleset_file.write( ips_list_cs )
		nft_ruleset_file.close()

	flush_ruleset = "nft flush table inet impulse_table"
	subprocess.run(flush_ruleset, shell=True)

	load_latest_ruleset = "nft -f " + nft_ruleset_filepath
	subprocess.run(load_latest_ruleset, shell=True)


def set_blocked_ips_state_manager(ips_list, state_action):
	if state_action == 'block' or state_action == 'unblock':
		
		task_result = apply_ips_list(ips_list, state_action)
	elif state_action == 'sync':
		task_result = sync_impulse_fw_with_cs(ips_list, state_action)
	else:
		task_result = False 

	return task_result