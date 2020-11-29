import flask
import datetime
import uuid
from firebase_admin import firestore
from . import routes
from . import conversation_ref
from . import user_ref

@routes.route('/messages/send/', methods=['POST'])
def send_message():
    """ Sends a direct message to the specified users. Creates a new conversation if one does not exist."""

    # check if user is logged in
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'must be logged in to send direct messages', 'url': flask.request.path}), 401
    
    # ensure correct parameters
    if 'recipients' not in flask.request.json:
        return flask.jsonify(**{'message': 'must specify recipients for a message', 'url': flask.request.path}), 400
    
    if 'message' not in flask.request.json and 'content' not in flask.request.json:
        return flask.jsonify(**{'message': 'must include a message or content', 'url': flask.request.path}), 400
    
    # add current user to group members
    username = flask.session['username']
    members = flask.request.json['recipients']
    if username not in members:
        members.append(username)
    
    # create conversationID
    members.sort()
    conversation_id = ''
    for member in members:
        conversation_id += member
        conversation_id += '_'

    conversation_id = conversation_id[:-1]

    # create database entry for conversation if not already existing
    conversation_entry = list(conversation_ref.where(conversation_id, '==', conversation_id).stream())
    if (len(conversation_entry) == 0):
        data = {
            'conversation_id': conversation_id,
            'members': members,
        }
        for member in members:
            user_entry = list(user_ref.where('username', '==', member).stream())
            if len(user_entry) == 0:
                return flask.jsonify(**{'message': 'recipient {} not found'.format(member), 'url': flask.request.path}), 404
            user_entry[0].reference.update({'direct_messages': firestore.ArrayUnion([conversation_id])})
        
        conversation_ref.document(conversation_id).set(data)

    # add message to database
    message_id = str(uuid.uuid4())
    message_data = {
        'id': message_id,
        'message': flask.request.json.get('message', None),
        'content': flask.request.json.get('content', None),
        'owner': username,
        'timestamp': datetime.datetime.utcnow()
    }
    conversation_ref.document(conversation_id).collection('messages').document(message_id).set(message_data)

    return flask.jsonify(**{'message': message_data, 'url': flask.request.path}), 201

# Returns all messages that belong to that conversation
@routes.route('/messages/<conversation_id>/info/', methods=['GET'])
def get_conversation(conversation_id):
    """ Retrieves all the messages for a conversation."""

    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'must be logged in to view direct messages', 'url': flask.request.path}), 401
    

    username = flask.session['username']
    conversation_entry = list(conversation_ref.where('conversation_id', '==', conversation_id).stream())
    
    # check if conversation exists and if the user is part of that conversation
    if len(conversation_entry) == 0:
        return flask.jsonify(**{'message': 'no conversation {} found'.format(conversation_id)}), 404
    
    if username not in conversation_entry[0].get('members'):
        return flask.jsonify(**{'message': 'user {} is not a member of conversation {}'.format(username, conversation_ref)}), 403
    
    context = {'conversation_id': conversation_id, 'members': conversation_entry[0].get('members'), 'url': flask.request.path}

    # Return all messages sorted by timestamp
    messages = list(conversation_entry[0].reference.collection('messages').order_by('timestamp', direction=firestore.Query.ASCENDING).stream())
    context['messages'] = [message.to_dict() for message in messages]

    return flask.jsonify(**context), 200

@routes.route('/messages/', methods=['GET'])
def get_messages():
    """Returns previews of all conversations that the user is a part of."""
    
    if 'username' not in flask.session:
        return flask.jsonify(**{'message': 'must be logged in to view direct messages', 'url': flask.request.path}), 401
    
    username = flask.session['username']
    user_entry = list(user_ref.where('username', '==', username).stream())

    if len(user_entry) == 0:
        return flask.jsonify(**{'message': 'no user {} found'.format(username), 'url': flask.request.path}), 404

    
    conversation_ids = user_entry[0].get('direct_messages')
    context = {'conversations': [], 'url': flask.request.path}

    # return info about the conversations that the user is part of
    for conversation_id in conversation_ids:
        conversation_entry = list(conversation_ref.where('conversation_id', '==', conversation_id).stream())
        first_message = conversation_entry[0].reference.collection('messages').order_by('timestamp').get()
        data = {
            'conversation_id': conversation_id,
            'members': conversation_entry[0].get('members'),
            'preview': first_message[0].to_dict()
        }
        context['conversations'].append(data)
    
    return flask.jsonify(**context), 200
