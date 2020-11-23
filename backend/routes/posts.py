import flask
import uuid
from . import routes
from . import user_ref
from . import post_ref
from . import follow_ref
from . import sentiment_model
from . import sentiment_mapping
from firebase_admin import firestore
import datetime
from sentimentanalysis import get_sentiment

@routes.route('/posts/create/', methods=['POST'])
def create_post():
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'must be logged in to make a new post', 'url': flask.request.path}), 401
    
    username = flask.session['username']
    
    if ('content' not in flask.request.json and 'reply_to' not in flask.request.json):
        return flask.jsonify(**{'message': 'must have associated content or be a reply', 'url': flask.request.path}), 400

    post_id = uuid.uuid4()
    
    if flask.request.json.get('message') is not None:
        direction, score = get_sentiment(sentiment_model, sentiment_mapping, flask.request.json['message'])
    else:
        direction = None
        score = None
    
    data = {
        'post_id': str(post_id),
        'owner': username,
        'timestamp': datetime.datetime.utcnow(),
        'message': flask.request.json.get('message', None),
        'content': flask.request.json.get('content', None),
        'reply_to': flask.request.json.get('reply_to', None),
        'sentiment_dir': direction,
        'sentiment_score': score,
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
        db_posts = (post_doc.to_dict() for post_doc in post_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).stream())
        db_posts = [add_liked_to_post(post_dict, None) for post_dict in db_posts]
        context['posts'] = db_posts
        return flask.jsonify(**context), 200
    
    username = flask.session['username']
    following = list(follow_ref.where('follower', '==', username).stream())
    for user in following:
        user_posts = [post_doc.to_dict() for post_doc in post_ref.where('owner', '==', user.get('followed')).stream()]
        user_posts = [add_liked_to_post(post_dict, username) for post_dict in user_posts]
        context['posts'].extend(user_posts)
    
    context['posts'].sort(key=lambda x: x['timestamp'], reverse=True)
    return flask.jsonify(**context), 200


@routes.route('/posts/<post_id>/info/', methods=['GET'])
def view_post(post_id):
    # retrieves all the information (including all replies) for a single post
    post = post_ref.document(post_id).get()
    if not post.exists:
        return flask.jsonify(**{'message': 'specified post id {} not found'.format(post_id), 'url': flask.request.path}), 404
    
    #gets the post dictionary and adds liked status to that dictionary
    post_dict = post.to_dict()
    replies = [reply.to_dict() for reply in post_ref.where('reply_to', '==', post.id).stream()]
    
    if 'username' in flask.session:
       post_dict = add_liked_to_post(post_dict, flask.session['username'])
       replies = [add_liked_to_post(reply, flask.session['username']) for reply in replies]
    else:
       post_dict = add_liked_to_post(post_dict, None)
       replies = [add_liked_to_post(reply, None) for reply in replies]
    
    replies.sort(key=lambda x: x['timestamp'], reverse=True)

    return flask.jsonify(**{'post': post_dict, 'replies': replies}), 200

@routes.route('/posts/<post_id>/like/', methods=['POST'])
def update_like(post_id):
    #likes the post for the current user or unlikes it if they have already liked the post
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'must be logged in to like a post', 'url': flask.request.path}), 401
    
    username = flask.session['username']

    # check if the specified post exists in our database
    post_doc = post_ref.document(post_id)
    if not post_doc.get().exists:
        return flask.jsonify(**{'message': 'specified post id {} not found'.format(post_id), 'url': flask.request.path}), 404

    # look for an existing like in the post's subcollection
    existing_like = post_doc.collection('likes').document(username).get()
    # like does not exist so we add a document with id username to subcollection and increment count
    if not existing_like.exists:
        post_doc.collection('likes').document(username).set({})
        post_doc.get().reference.update({'num_likes': firestore.Increment(1)})
    # like does exist so we want to remove that document from the subcollection and decrement count
    else:
        existing_like.reference.delete()
        post_doc.get().reference.update({'num_likes': firestore.Increment(-1)})
    
    liked = not existing_like.exists
    # returns true if like action occurred and false if unlike action occurred
    return flask.jsonify(**{'url': flask.request.path, 'liked': liked}), 200
    
def add_liked_to_post(post_dict, username):
    if username is None:
        post_dict['liked'] = False
    else:
        existing_like = post_ref.document(post_dict['post_id']).collection('likes').document(username).get()
        post_dict['liked'] = existing_like.exists
    
    return post_dict






    


        

    
    
    
