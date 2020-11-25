import flask
from . import user_ref
from . import routes

@routes.route('/recommendations/', methods=['GET'])
def get_recommendations():
    """ Returns recommendations for songs on Spotify based on user's attribute vector."""

    recommendation_ids = ['spotify:track:7o4gBbTM6UBLkOYPw9xMCz', 'spotify:track:1f38Gx6xQz6r4H1jGVNBJo',
    'spotify:track:6D7K7dyxET1NAxjHTcjGAc', 'spotify:track:1H7KnK26kc1YyellpbINEn',
    'spotify:track:6CN7FuZ7o1xle9TNxApGeQ']

    return flask.jsonify(**{'recommendations': recommendation_ids, 'url': flask.request.path}), 200
    

