import configparser


def get_agent_config():
	config = configparser.ConfigParser()
	config.read('/opt/impulse/impulse.conf')
	return config