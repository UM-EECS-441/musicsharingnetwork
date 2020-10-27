# Flask framework for backend REST API

import os
import flask

from routes import *

app = flask.Flask(__name__)
app.register_blueprint(routes)
app.secret_key = b'\xc4i\x92\xcc\x1a\xab\x9a#R\x94\xa6[\xce\xc0\xb0\t\x10$e\x1bi\xaf-\xae'

port = int(os.environ.get('PORT', 8080))
if __name__ == '__main__':
    app.run(threaded=True, host='0.0.0.0', port=port)