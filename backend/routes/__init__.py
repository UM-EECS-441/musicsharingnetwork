from flask import Blueprint
from firebase_admin import credentials, firestore, initialize_app
import sentimentanalysis
import os
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
from spotipy.oauth2 import SpotifyOAuth

# initialize database and spotify reference objects
routes = Blueprint('routes', __name__)
cred = credentials.Certificate('key.json')
default_app = initialize_app(cred)
db = firestore.client()
user_ref = db.collection('users')
follow_ref = db.collection('following')
post_ref = db.collection('posts')
conversation_ref = db.collection('conversations')
sentiment_model = sentimentanalysis.get_model()
sentiment_mapping = sentimentanalysis.get_mapping()

SPOTIFY_CLIENT_SECRET = '225ff590d76d4d6db2168af29e627dd4'
SPOTIFY_CLIENT_ID = 'c0a5c9b2c5b94d00b5599dd76b092414'
spotify_ref = spotipy.Spotify(client_credentials_manager=SpotifyClientCredentials(SPOTIFY_CLIENT_ID,
                                                        SPOTIFY_CLIENT_SECRET))
spotify_auth = spotify_ref.client_credentials_manager
token = spotify_auth.get_access_token()

# construct list of features to build our model around
DUMMY_ID = '1rFMYAZxBoAKSzXI54brMu'
FEATURES = spotify_ref.audio_features(tracks=[DUMMY_ID])[0].keys()
EXCLUDE_FEATURES = ['track_href', 'uri', 'analysis_url', 'id', 'type', 'time_signature', 'duration_ms', 'key', 'mode']
FEATURES = FEATURES - EXCLUDE_FEATURES

from .index import *
from .users import *
from .posts import *
from .messages import *
from .recommendations import *
