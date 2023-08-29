#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved. Impulse xSIEM   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

from flask import Flask
from main.config import Development
from flask_restful import Api
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate, MigrateCommand
from flask_cors import CORS
from celery import Celery
import subprocess
from main.helpers.shared.agent_conf import get_agent_config
from flask_mail import Mail

app = Flask(__name__)
#CORS(app, expose_headers=["Content-Disposition"]) # expose headers for file downloads
CORS(app)
app.config.from_object( Development() )

app.config['MAX_CONTENT_LENGTH'] = 1024 * 1024 * 10 
app.config['UPLOAD_EXTENSIONS'] = ['.json']

api = Api(app)
db = SQLAlchemy(app)
migrate = Migrate(app, db, compare_type=True)

from flask_jwt_extended import (
    JWTManager, 
    jwt_required, 
    jwt_refresh_token_required,
    create_access_token,
    create_refresh_token,
    get_jwt_identity,
    get_raw_jwt
)

# Flask-JWT-Extended
app.config['JWT_SECRET_KEY'] = 'super-secret'  
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 60 

# Email Alerts
manager_config = get_agent_config()

mail_server = manager_config.get('Env','MAIL_SERVER')
mail_port = manager_config.get('Env','MAIL_PORT')
mail_username = manager_config.get('Env','MAIL_USERNAME')
mail_password = manager_config.get('Env','MAIL_PASSWORD')


app.config['MAIL_SERVER']=mail_server
app.config['MAIL_PORT']=mail_port
app.config['MAIL_USERNAME']=mail_username
app.config['MAIL_PASSWORD']=mail_password
app.config['MAIL_USE_TLS']=True
app.config['MAIL_USE_SSL']=False

mail = Mail(app)
jwt = JWTManager(app)
blacklist = set()

#celery_app = Celery('tasks', broker='redis://127.0.0.1:7637/0')
celery_app = Celery()

celery_app.conf.update(
	broker_url='redis://127.0.0.1:7637/0',
	task_ignore_result = True,
	#worker_send_task_event = True,
	#task_send_sent_event = True,
	task_time_limit = 500,
	task_soft_time_limit=300, 
	task_acks_late = True,
	task_routes = {
		'main.bgtasks.general.general_tasks.*': {'queue': 'general_tasks'},
		'main.bgtasks.iocs.iocs_tasks.*': {'queue': 'iocs_tasks'},
		'main.bgtasks.nids.nids_tasks.*': {'queue': 'nids_tasks'}
	}
)



from main.events import events_routes
from main.analytics import analytics_routes 
from main.active_response import active_response_routes 
from main.users import user_routes  
from main.notifications import notification_routes  
from main.tasks import task_routes 
from main.manager_gateway import receive_routes  
from main.fleet import fleet_management_routes
from main.compromise_indicators import compromise_indicators_routes
from main.detections import detections_routes
from main.packs import packs_routes
from main.settings import settings_routes
from main.license_management import license_routes
from main.threat_intel import threat_intel_routes
from main.cve_vulns import cve_vulns_routes
from main.bgtasks.general import general_tasks
from main.bgtasks.nids import nids_tasks
from main.bgtasks.iocs import iocs_tasks
from main.sca import sca_routes 
#from main.tests import tests_routes 





