#
# Copyright (c) 2024, Bozhidar Genev - All Rights Reserved.Impulse XDR   
# Impulse is licensed under the Impulse User License Agreement at the root of this project.
#

from main import app
#socketio


if __name__ == "__main__":
	app.run(host=app.config['HOST'], port=app.config['PORT'], debug=app.config['DEBUG'], threaded=True)

	#socketio.run(app, host='127.0.0.1' port=5005)