import flask
import uuid
from . import routes
from . import user_ref
from . import post_ref
from . import follow_ref
from . import sentiment_model
from . import sentiment_mapping
from . import FEATURES
from . import SEED_GENRES
from . import spotify_ref
from firebase_admin import firestore
import datetime
from sentimentanalysis import get_sentiment

@routes.route('/posts/create/', methods=['POST'])
def create_post():
    """ Creates a new post."""

    # checks if user is logged in before allowing create request to continue
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'must be logged in to make a new post', 'url': flask.request.path}), 401
    
    username = flask.session['username']
    
    # posts must either be a reply or have original content associated with them
    if ('content' not in flask.request.json and 'reply_to' not in flask.request.json):
        return flask.jsonify(**{'message': 'must have associated content or be a reply', 'url': flask.request.path}), 400

    post_id = uuid.uuid4()
    
    # if post contains a message, calculates the sentiment score for the message 
    if flask.request.json.get('message') is not None:
        direction, score = get_sentiment(sentiment_model, sentiment_mapping, flask.request.json['message'])
        score = abs(score) if direction else abs(score) * -1
    else:
        score = None
    
    # if the post has an associated song and calculated score, updates the user's attribute vector
    if flask.request.json.get('content') is not None and score is not None:
        update_attributes(username, flask.request.json['content'], score)
    
    data = {
        'post_id': str(post_id),
        'owner': username,
        'timestamp': datetime.datetime.utcnow(),
        'message': flask.request.json.get('message', None),
        'content': flask.request.json.get('content', None),
        'reply_to': flask.request.json.get('reply_to', None),
        'sentiment_score': score,
        'num_likes': 0,
        'num_reposts': 0
    }
    post_ref.document(str(post_id)).set(data)
    return flask.jsonify(**{'post': data, 'url': flask.request.path}), 201

@routes.route('/posts/', methods=['GET'])
def view_posts():
    """ Retrieves posts for timeline display."""

    # If user is not logged in, just return the most recent posts
    context = {'posts': [], 'url': flask.request.path}
    if 'username' not in flask.session:
        db_posts = (post_doc.to_dict() for post_doc in post_ref.order_by('timestamp', direction=firestore.Query.DESCENDING).stream())
        db_posts = [add_liked_to_post(post_dict, None) for post_dict in db_posts]
        context['posts'] = db_posts
        return flask.jsonify(**context), 200
    
    # collects all posts from users that the logged-in user follows (including themselves)
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
    """ Retrieves all the information (including all replies) for a single post."""

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
    
    # sorts replies in chronological order
    replies.sort(key=lambda x: x['timestamp'], reverse=True)

    return flask.jsonify(**{'post': post_dict, 'replies': replies}), 200

@routes.route('/posts/<post_id>/like/', methods=['POST'])
def update_like(post_id):
    """likes the post for the current user or unlikes it if they have already liked the post."""

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
    """ Adds the liked field to a post dictionary."""

    if username is None:
        post_dict['liked'] = False
    else:
        existing_like = post_ref.document(post_dict['post_id']).collection('likes').document(username).get()
        post_dict['liked'] = existing_like.exists
    
    return post_dict

def update_attributes(username, track_id, score):
    """ Updates user's attribute vectors based on the features of the song and sentiment score of their post."""

    feature_dict = user_ref.document(username).get().to_dict()['feature_vector']
    # get or initialize genre vector and artist vector for user
    genre_dict = user_ref.document(username).get().to_dict().get('genre_vector', {})
    artist_dict = user_ref.document(username).get().to_dict().get('artist_vector', {})

    # get the audio features for that track
    track = spotify_ref.audio_features(tracks=[track_id])[0]
    # get artist ids for artists on this track
    artist_ids = [artist['uri'] for artist in spotify_ref.track(track_id)['artists']]
    # get genres affiliated with those artists
    genres = set()
    artist_genres = [artist['genres'] for artist in spotify_ref.artists(artist_ids)['artists']]
    for genre_list in artist_genres:
        genres.update(genre_list)
    # filter genres to only contain seedable values for recommendations
    genres = genres.intersection(set(SEED_GENRES))
    print(genres)

    # increments/decrements the corresponding bucket value for each attribute based on sentiment score
    for feature in FEATURES:
        index = get_index(feature, track[feature])
        print(feature, index)
        feature_dict[feature][index] += score

    # updates the user's genre vector
    for genre in genres:
        genre_dict[genre] = genre_dict.get(genre, 0) + score
    
    for artist_id in artist_ids:
        artist_dict[artist_id] = artist_dict.get(artist_id, 0) + score
    
    user_ref.document(username).update({'feature_vector': feature_dict})
    user_ref.document(username).update({'genre_vector': genre_dict})
    user_ref.document(username).update({'artist_vector': artist_dict})
    

def get_index(feature, value):
    """ Calculates the corresponding bucket for a specific song attribute."""

    if feature == 'tempo':
        return min(int(round(value / 10)), 20)
    elif feature == 'loudness':
        return min(int(round(abs(value) / 6)), 10)
    else:
        return int(round(value, 1) * 10)
    




    


        

    
    
    
