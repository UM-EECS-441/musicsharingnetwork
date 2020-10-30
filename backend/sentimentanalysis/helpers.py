# This file contains a bunch of functions that may be used by several other files
from string import punctuation
import array
import torch

def get_words(review, separator=True):
    # Returns list of all words in review
    reviewText = review
    if separator:
        split_index = review.rfind('|')
        reviewText = review[:split_index]

    # Split text by whitespace, return list
    reviewText = reviewText.strip()
    return reviewText.split()


def remove_punctuation(reviewText):
    # Removes punctuation from review text
    return reviewText.translate(reviewText.maketrans('', '', punctuation))


def get_labels(filename):
    # Gets labels for all preprocessed review docs
    labels = list()

    with open(filename, 'r') as review_doc:
        for line in review_doc:
            line = line.strip()
            split_index = line.rfind('|')
            label = float(line[split_index+1:])
            labels.append(label)
    
    return labels


def clean_review(reviewText, vocab):
    # Returns string of review text with non vocab words removed
    words = get_words(reviewText)
    words = [word for word in words if word in vocab]
    return ' '.join(words)


def get_max_review_length(reviews):
    # Returns the max number of words in a single review out of a list of reviews
    result = 0
    for review in reviews:
        if len(review.split()) > result:
            result = len(review.split())

    return result


def array_to_long_tensor(arr):
    arr = torch.Tensor(arr)
    return arr.long()