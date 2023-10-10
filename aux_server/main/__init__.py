#
# Copyright (c) 2021-2023, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

from flask import Flask
from main.config import Development
from flask_restful import Api
from flask_cors import CORS
import os
import subprocess


app = Flask(__name__)
CORS(app)
app.config.from_object( Development() )
api = Api(app)


from main.auxiliary_routes import auxiliary_routes
from main.helpers.shared.active_response_helper import restart_nftables_service, ensure_impulse_nft_table_exists

ensure_impulse_nft_table_exists()

