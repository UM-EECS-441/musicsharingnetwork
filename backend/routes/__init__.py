from flask import Blueprint
from firebase_admin import credentials, firestore, initialize_app
import sentimentanalysis
import os


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

from .index import *
from .users import *
from .posts import *
from .messages import *
