import configparser


LINUX_IMPULSE_CONF = '/opt/impulse/impulse.conf'
WINDOWS_IMPULSE_CONF = 'C:\\Program Files\\impulse\\impulse.conf'

def get_agent_config():
	config = configparser.ConfigParser()
	config.read(LINUX_IMPULSE_CONF)
	return config