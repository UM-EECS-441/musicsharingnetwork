import flask
from . import routes

# Returns a list of APIs that can be called
@routes.route('/', methods=['GET'])

def index():
    endpoints = {
        "message": """ Welcome to the MSN Backend Rest API. Documentation can be found at https://github.com/UM-EECS-441/musicsharingnetwork/wiki""",
        "url": flask.request.path
    }
    return flask.jsonify(**endpoints), 200