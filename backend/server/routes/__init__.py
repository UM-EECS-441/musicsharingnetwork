from flask import Blueprint
from firebase_admin import credentials, firestore, initialize_app

routes = Blueprint('routes', __name__)
cred = credentials.Certificate('key.json')
default_app = initialize_app(cred)
db = firestore.client()
user_ref = db.collection('users')
follow_ref = db.collection('following')
post_ref = db.collection('posts')

from .index import *
from .users import *
from .posts import *