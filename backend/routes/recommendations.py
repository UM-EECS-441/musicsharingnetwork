import flask
import random
from . import user_ref
from . import post_ref
from . import routes
from . import FEATURES
from . import SEED_GENRES
from . import spotify_ref

@routes.route('/recommendations/', methods=['GET'])
def get_recommendations():
    """ Returns recommendations for songs on Spotify based on user's attribute vector."""

    # returns the top 15 songs in the United States if a user is not logged in (or has not created a post)
    if 'username' not in flask.session:
        standard_recs = True
    else:
        username = flask.session['username']
        num_posts = len(list(post_ref.where('owner', '==', username).stream()))
        standard_recs = num_posts < 1

    if standard_recs:
        recommendations = spotify_ref.playlist_items('16wsvPYpJg1dmLhz0XTOmX', fields=['items.track.uri'], limit=15)
        recommendation_ids = [item['track']['uri'] for item in recommendations['items']]
        return flask.jsonify(**{'recommendations': recommendation_ids, 'url': flask.request.path}), 200
    
    # gets query vector and genre seeds to fetch recommendations
    query_vector = build_query_vector(username)
    genres = get_genres()
    print(query_vector)
    
    # gets recommendations and calculates accuracy of recommendations
    recommendations = spotify_ref.recommendations(seed_genres=genres, limit=15, country='US', **query_vector)
    track_ids = [track['uri'] for track in recommendations['tracks']]
    accuracy_dict = calculate_accuracy(query_vector, track_ids)
    print(accuracy_dict)
    return flask.jsonify(**{'recommendations': track_ids, 'attribute_error': accuracy_dict, 'url': flask.request.path}), 200
    

def build_query_vector(username):
    kwargs = {}
    feature_dict = user_ref.document(username).get().to_dict()['feature_vector']
    for feature in feature_dict.items():
        kwargs['target_'+feature[0]] = get_feature_values(feature[0], feature[1])
    return kwargs


def get_feature_values(feature, lst):
    """ Selects the target attribute value based on highest bucket values."""

    # sorts indices of list by bucket value (selects top 2 bucket values)
    lst_indices = sorted(range(len(lst)), key = lambda s: lst[s])[-2:]

    # randomly selects one of the top 2 (if selected is 0, changes selection)
    random_index = random.randint(0, 1)
    if lst[lst_indices[random_index]] == 0:
        random_index = 1 - random_index
    
    lst_index = lst_indices[random_index]

    # calculates the target attribute value based on the bucket index
    if feature == 'tempo':
        target_val = (lst_index * 10)
    elif feature == 'loudness':
        target_val = (lst_index * -6)
    else:
        target_val = (lst_index / 10)
    
    return target_val

def get_genres(specify_genres=[], mode='random'):
    """ Selects genres to seed the recommendations request."""

    # get_recommendations allows only five genres
    # you can specify which genres
    if mode == 'match':
        # genres = specified genres that are also in spotify
        genres = list(set(SEED_GENRES) & set(specify_genres))
    # or get five random genres
    elif mode == 'random':
        genres = random.sample(SEED_GENRES, 5)
    return genres

def calculate_accuracy(query_vector, track_ids):
    """ Calculates the average % of error in the recommendations for each song attribute."""

    track_infos = spotify_ref.audio_features(track_ids)
    accuracy_dict = {}
    for feature in FEATURES:
        accuracy_dict[feature] = 0
        for track_info in track_infos:
            # normalizes the error value for tempo and loudness (bc they are on different scales)
            if feature == 'tempo':
                accuracy_dict[feature] += abs(query_vector['target_'+feature] - track_info[feature])/200
            elif feature == 'loudness':
                accuracy_dict[feature] += abs(query_vector['target_'+feature] - track_info[feature])/60
            else:
                accuracy_dict[feature] += abs(query_vector['target_'+feature] - track_info[feature])
        accuracy_dict[feature] /= len(track_infos)
        accuracy_dict[feature] = round(accuracy_dict[feature], 4)
    
    return accuracy_dict