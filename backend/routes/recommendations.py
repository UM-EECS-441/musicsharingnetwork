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

    # returns the top 25 songs in the United States if a user is not logged in (or has not created a post)
    if 'username' not in flask.session:
        default_rec = True
    else:
        username = flask.session['username']
        num_posts = len(list(post_ref.where('owner', '==', username).stream()))
        default_rec = num_posts < 1

    if default_rec:
        popular_songs = spotify_ref.playlist_items('16wsvPYpJg1dmLhz0XTOmX', fields=['items.track.uri'], limit=25)
        popular_song_ids = [item['track']['uri'] for item in popular_songs['items']]
        return flask.jsonify(**{'popular_songs': popular_song_ids, 'url': flask.request.path}), 200
    
    # gets query vector and random genre seeds to fetch first set of recommendations
    query_vector = build_query_vector(username)
    random_genres = get_random_genres()
    print(query_vector)
    
    # gets attribute-based recommendations (w/ random genres)
    recommendations = spotify_ref.recommendations(seed_genres=random_genres, limit=10, country='US', **query_vector)
    attribute_track_ids = [track['uri'] for track in recommendations['tracks']]
    
    # gets genre-and-attribute-based recommendations (does not calculate accuracy)
    personalized_genres = get_personalized_genres(username)
    if len(personalized_genres) > 0:
        recommendations = spotify_ref.recommendations(seed_genres=personalized_genres, limit=10, country='US', **query_vector)
        genre_track_ids = [track['uri'] for track in recommendations['tracks']]
    else:
        genre_track_ids = []
    
    #gets artist-and-attribute-based recommendations (does not calculate accuracy)
    personalized_artists = get_personalized_artists(username)
    if len(personalized_artists) > 0:
        recommendations = spotify_ref.recommendations(seed_artists=personalized_artists, limit=5, country='US', **query_vector)
        artist_track_ids = [track['uri'] for track in recommendations['tracks']]
    else:
        artist_track_ids = []
    
    #filter out duplicates (look for duplicate recommendations between recommendation arrays)
    attribute_track_ids = list(set(attribute_track_ids) - set(genre_track_ids) - set(artist_track_ids))
    genre_track_ids = list(set(genre_track_ids) - set(artist_track_ids))
    
    #calculates accuracy for all the recommendations
    
    accuracy_dict = calculate_accuracy(query_vector, attribute_track_ids + genre_track_ids + artist_track_ids)
    
    return flask.jsonify(**{'attribute_recommendations': attribute_track_ids, 'genre_recommendations': genre_track_ids,
        'artist_recommendations': artist_track_ids, 'attribute_error': accuracy_dict, 'url': flask.request.path}), 200
    

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

def get_random_genres(specify_genres=[], mode='random'):
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

def get_personalized_genres(username):
    """ Retrieves the user's top 5 favorite genres to seed recommendations."""
    genre_dict = user_ref.document(username).get().to_dict().get('genre_vector', {})
    genre_dict = {key:value for (key, value) in genre_dict.items() if value > 0}

    genres_sorted = sorted(genre_dict, key=genre_dict.get, reverse=True)
    if len(genres_sorted) > 5:
        return genres_sorted[:5]
    else:
        return genres_sorted

def get_personalized_artists(username):
    """ Retrieves the user's top 5 favorite artists to seed recommendations."""
    artist_dict = user_ref.document(username).get().to_dict().get('artist_vector', {})
    artist_dict = {key:value for (key, value) in artist_dict.items() if value > 0}

    artists_sorted = sorted(artist_dict, key=artist_dict.get, reverse=True)
    if len(artists_sorted) > 5:
        return artists_sorted[:5]
    else:
        return artists_sorted

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