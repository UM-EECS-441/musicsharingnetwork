import flask
import re
import uuid
import hashlib
from firebase_admin import firestore
from . import routes
from . import user_ref
from . import follow_ref
from . import post_ref

@routes.route('/users/create', methods=['POST'])
def create_user():
    """Creates a new user with the specified credentials and profile information."""
    if 'username' in flask.session:
        # redirect them to the settings page or something eventually 
        return flask.jsonify(**{'message': 'user is currently logged in', 'url': flask.request.path}), 400

    #make sure the request has necessary parameters
    if ('username' not in flask.request.json or 'password' not in flask.request.json):
        return flask.jsonify(**{'message': 'requires username and password', 'url': flask.request.path}), 400

    username = flask.request.json['username'].lower()
    # TODO: validate username format
    
    existing_users = list(user_ref.where('username', '==', username).stream())
    if (len(existing_users) > 0):
        return flask.jsonify(**{'message': 'existing user {}'.format(username), 'url': flask.request.path}), 409

    password = flask.request.json['password']
    # TODO: validate the password
    
    # hash the password
    password_db_entry = hash_password(password)
    # TODO: take in profile picture and upload to storage

    # set database entry
    data = {
        'username': username,
        'password': password_db_entry,
        'profile_pic': flask.request.json.get('profile_pic', None),
        'full_name': flask.request.json.get('full_name', None),
        'user_bio': flask.request.json.get('user_bio', None),
        'streaming_service': flask.request.json.get('streaming_service', None),
        'access_token': flask.request.json.get('access_token', None),
        'refresh_token': flask.request.json.get('refresh_token', None),
        'expires_at': flask.request.json.get('expires_at', None),
        'num_following': 0,
        'num_followers': 0,
        'direct_messages': [],
        'recommendations': [],
        'archived_recommendations': [],
        'sentiment_weights': {}
    }
    user_ref.document(username).set(data)
    # have the user follow themselves (representational purposes) (SEE IF THIS WORKS)
    data = {
        'follower': username,
        'followed': username
    }
    follow_ref.document(username + '-' + username).set(data)
    # set flask session token and return response
    flask.session['username'] = username
    return flask.jsonify(**{'url': flask.request.path}), 201


@routes.route('/users/password', methods = ['PATCH'])
def change_password():
    """Modify current user credentials (password)."""
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'user is currently not logged in', 'url': flask.request.path}), 400

    username = flask.session['username']
    db_credentials = list(user_ref.where('username', '==', username).stream())

    if (len(db_credentials) == 0):
        return flask.jsonify(** {'message': 'no user {} found'.format(username), 'url': flask.request.path}), 401
    
    old_password = flask.request.json['old_password']

    if not compare_hash(old_password, db_credentials):
        return flask.jsonify(**{'message': 'invalid password', 'url': flask.request.path}), 401
    
    new_password = flask.request.json['new_password']
    #TODO: validate new password

    password_db_entry = hash_password(new_password)
    db_credentials[0].reference.update({'password': password_db_entry})
    return flask.jsonify(**{'url': flask.request.path}), 204

        
@routes.route('/users/login/', methods = ['POST'])
def login():
    """Authenticate user credentials to start a session."""
    if 'username' in flask.session:
        # redirect them to the settings page or something eventually 
        return flask.jsonify(**{'message': 'user is currently logged in', 'url': flask.request.path}), 400
    
    #make sure the request has necessary parameters
    if ('username' not in flask.request.json or 'password' not in flask.request.json):
        return flask.jsonify(**{'message': 'requires username and password', 'url': flask.request.path}), 400

    # validate credentials for user
    username = flask.request.json['username']
    db_credentials = list(user_ref.where('username', '==', username).stream())

    if (len(db_credentials) == 0):
        return flask.jsonify(**{'message': 'no user {} found'.format(username), 'url': flask.request.path}), 401

    password = flask.request.json['password']
    if not compare_hash(password, db_credentials):
        return flask.jsonify(**{'message': 'invalid password', 'url': flask.request.path}), 401
    
    # Create session cookie and log in user
    flask.session['username'] = username
    return flask.jsonify(**{'url': flask.request.path}), 200
      

@routes.route('/users/logout/', methods = ['POST'])
def logout():
    """Clear flask session for current user."""
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'user is currently not logged in'}), 400
    # Clear flask session and logout user
    flask.session.clear()
    return flask.jsonify(**{'url': flask.request.path}), 200


@routes.route('/users/<target_user>/', methods = ['GET'])
def show_user(target_user):
    """Returns information about a user's profile to display. """
    # We allow non-authenticated users to view another user's profile.
    db_entry = list(user_ref.where('username', '==', target_user).stream())

    if (len(db_entry) == 0):
        return flask.jsonify(** {'message': 'no user {} found'.format(target_user), 'url': flask.request.path}), 404
    
    db_posts = list(post_ref.where('owner', '==', target_user).stream())
    posts = [post.to_dict() for post in db_posts]

    response = {
        'target_user': db_entry[0].get('username'),
        'full_name': db_entry[0].get('full_name'),
        'profile_pic': db_entry[0].get('profile_pic'),
        'user_bio': db_entry[0].get('user_bio'),
        'num_following': db_entry[0].get('num_following'),
        'num_followers': db_entry[0].get('num_followers'),
        'posts': posts,
        'url': flask.request.path
    }
    return flask.jsonify(**response), 200    


@routes.route('/users/<target_user>/follow', methods = ['POST'])
def follow_user(target_user):
    """Follows the specified user for the current user."""
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'Cannot follow user, not logged in', 'url': flask.request.path}), 401

    username = flask.session['username']
    target_entry = list(user_ref.where('username', '==', target_user).stream())
    user_entry = list(user_ref.where('username', '==', username).stream())

    # Make sure current user and target user exist
    if (len(target_entry) == 0):
        return flask.jsonify(** {'message': 'no target user {} found'.format(target_user), 'url': flask.request.path}), 404
    
    if (len(user_entry) == 0):
        return flask.jsonify(** {'message': 'no current user {} found'.format(username), 'url': flask.request.path}), 401

    # Check if the follow relationship already exists
    follow_check = list(follow_ref.where('follower', '==', username).where('followed', '==', target_user).stream())
    if (len(follow_check) > 0):
        return flask.jsonify(** {'message': 'user {} already follows user {}'.format(username, target_user), 
        'url': flask.request.path}), 409

    #Create database entry for following relationship and increment profile counts
    data = {
        'follower': username,
        'followed': target_user
    }
    follow_ref.document(username + '-' + target_user).set(data)
    user_entry[0].reference.update({'num_following': firestore.Increment(1)})
    target_entry[0].reference.update({'num_followers': firestore.Increment(1)})
    return flask.jsonify(**{'url': flask.request.path}), 204


@routes.route('/users/<target_user>/unfollow', methods = ['POST'])
def unfollow_user(target_user):
    """Unfollows the specified user for the current user."""
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'Cannot unfollow user, not logged in', 'url': flask.request.path}), 401

    username = flask.session['username']
    target_entry = list(user_ref.where('username', '==', target_user).stream())
    user_entry = list(user_ref.where('username', '==', username).stream())

    # Make sure current user and target user exist
    if (len(target_entry) == 0):
        return flask.jsonify(** {'message': 'no target user {} found'.format(target_user), 'url': flask.request.path}), 404
    
    if (len(user_entry) == 0):
        return flask.jsonify(** {'message': 'no current user {} found'.format(username), 'url': flask.request.path}), 401

    # Check if the follow relationship exists before deleting from table
    follow_check = list(follow_ref.where('follower', '==', username).where('followed', '==', target_user).stream())
    if (len(follow_check) == 0):
        return flask.jsonify(** {'message': 'user {} does not follow user {}'.format(username, target_user), 
        'url': flask.request.path}), 404

    
    follow_check[0].reference.delete()
    user_entry[0].reference.update({'num_following': firestore.Increment(-1)})
    target_entry[0].reference.update({'num_followers': firestore.Increment(-1)})
    return flask.jsonify(**{'url': flask.request.path}), 204     
    

def hash_password(password):
    """Hash password for database storage."""
    algorithm = 'sha512'
    salt = uuid.uuid4().hex
    hash_obj = hashlib.new(algorithm)
    password_salted = salt + password
    hash_obj.update(password_salted.encode('utf-8'))
    password_hash = hash_obj.hexdigest()
    return "$".join([algorithm, salt, password_hash])


def compare_hash(password, db_credentials):
    """Extract hash from db query and computes hash of input."""
    pass_list = db_credentials[0].get('password').split('$')
    algorithm = pass_list[0]
    salt = pass_list[1]
    db_passhash = pass_list[2]

    hash_obj = hashlib.new(algorithm)
    password_salted = salt + password
    hash_obj.update(password_salted.encode('utf-8'))
    password_hash = hash_obj.hexdigest()
    return password_hash == db_passhash