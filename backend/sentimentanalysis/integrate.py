# Functions necessary for integration with backend. No other file is necessary for backend integration.
import helpers
import numpy as np
import constants
import svc


def get_model():
    # Returns model
    return helpers.load_model()


def get_mapping():
    # Returns mapping needed to encode a review
    return svc.create_dictionary()

def get_sentiment(model, mapping, reviewText):
    # Returns a tuple of True/False value for if they liked it, as well as a score for how strongly they feel
    reviewText = helpers.remove_punctuation(reviewText)
    encoding = svc.prep_data([reviewText], mapping)
    prediction = model.predict(encoding)
    theta = model.coef_[0]
    dot = np.dot(encoding[0], theta)
    return prediction[0] == 1.0, dot


