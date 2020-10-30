import flask
import uuid
from . import routes
from . import user_ref
from . import post_ref
from . import follow_ref
from firebase_admin import firestore
import datetime

@routes.route('/posts/create', methods=['POST'])
def create_post():
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'must be logged in to make a new post', 'url': flask.request.path}), 401
    
    username = flask.session['username']
    
    if ('content' not in flask.request.json and 'reply_to' not in flask.request.json):
        return flask.jsonify(**{'message': 'must have associated content or be a reply', 'url': flask.request.path}), 400

    post_id = uuid.uuid4()
    data = {
        'post_id': str(post_id),
        'owner': username,
        'timestamp': datetime.datetime.utcnow(),
        'message': flask.request.json.get('message', None),
        'content': flask.request.json.get('content', None),
        'reply_to': flask.request.json.get('reply_to', None),
        'num_likes': 0,
        'num_reposts': 0
    }
    post_ref.document(str(post_id)).set(data)
    return flask.jsonify(**{'post': data, 'url': flask.request.path}), 201

@routes.route('/posts/', methods=['GET'])
def view_posts():
    # If user is not logged in, just return the most recent posts
    context = {'posts': [], 'url': flask.request.path}
    if 'username' not in flask.session:
        db_posts = list(post_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).stream())
        for post in db_posts:
            context['posts'].append(post.to_dict())
        return flask.jsonify(**context), 200
    
    username = flask.session['username']
    following = list(follow_ref.where('follower', '==', username).stream())
    for user in following:
        user_posts = list(post_ref.where('owner', '==', user.get('followed')).stream())
        for post in user_posts:
            context['posts'].append(post.to_dict())
    
    context['posts'].sort(key=lambda x: x['timestamp'], reverse=True)
    return flask.jsonify(**context), 200


    


        

    
    
    
