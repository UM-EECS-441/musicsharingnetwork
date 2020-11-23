# This file contains a bunch of functions that may be used by several other files
from string import punctuation
import array
import torch
import pickle
import sentimentanalysis.constants as constants
import random

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


def count_labels(filename):
    result = {}
    labels = get_labels(filename)
    for label in labels:
        result[label] = result.get(label, 0) + 1 

    for (key, val) in result.items():
        print("label:", key, "\tcount:", val)
        print(type(key))
        print(key)

    return result


def trim_file(filename):
    counts = count_labels(filename)
    lower = counts[0.0]
    outfilename = filename[:-4] + '2.txt'
    outfile = open(outfilename, 'w')
    lines = []
    with open(filename, 'r') as reader:
        added = 0
        done_with_1 = False
        for line in reader:
            line = line.strip()
            split_index = line.rfind('|')
            label = float(line[split_index+1:])
            if label == 1.0:
                if done_with_1:
                    continue
                
                lines.append(line)
                #outfile.write(line + '\n')
                added += 1
                if added >= 2*lower:
                    done_with_1 = True
            
            else:
                lines.append(line)
                #outfile.write(line + '\n')

    random.shuffle(lines)
    for line in lines:
        outfile.write(line + '\n')
    outfile.close()


def read_file(filename):
    # returns an array of reviews and an array of labels
    reviews = []
    labels = []
    with open(filename) as data:
        for line in data:
            line = line.strip()
            split_idx = line.rfind('|')
            review = line[:split_idx]
            label = float(line[split_idx+1:])
            review = remove_punctuation(review)
            reviews.append(review)
            labels.append(label)

    return reviews, labels


def fix_svc_labels(labels):
    # changes all 0 labels to -1
    for i in range(len(labels)):
        if labels[i] == 0:
            labels[i] = -1


def save_model(model):
    # Saves model parameters to the proper file
    pickle.dump(model, open(constants.saved_model_filename, 'wb'))


def load_model():
    return pickle.load(open(constants.saved_model_filename, 'rb'))

