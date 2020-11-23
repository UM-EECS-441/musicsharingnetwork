# Code for Embedder class

import sentimentanalysis.vocab as vocab
import sentimentanalysis.helpers as helpers
import numpy as np
import torch


class Embedder:
    def __init__(self, vocab_list, baseReviews):
        # Initialize Embedder class
        self.embeddings = dict()
        self.prepare_mapping(vocab_list)
        self.max_review_length = helpers.get_max_review_length(baseReviews)
        if self.max_review_length > 684:
            self.max_review_length = 684
        

    def prepare_mapping(self, vocab_list):
        # Creates a dictionary mapping words to their embedding value, which is a unique integer
        embedding = 1
        for word in vocab_list:
            self.embeddings[word] = embedding
            embedding += 1
    

    def pad_encodings(self, reviewList, encodings):
        # Pads encodings with 0s at the end to fit max review length
        for encoding in encodings:
            padding = [0 for _ in range(self.max_review_length - len(encoding))]
            encoding = encoding.extend(padding)
        
        return encodings


    def encode_reviews(self, reviewList):
        # Returns a 2d numpy array of encoded reviews
        # Takes input of review texts
        encoded_list = []
        for review in reviewList:
            review = review.strip()
            words = review.split()
            encoding = [0 for _ in range(len(words))]
            for i, word in enumerate(words):
                encoding[i] = self.embeddings[word]
            
            if len(encoding) > 684:
                encoding = encoding[:684]

            encoded_list.append(encoding)

        return self.pad_encodings(reviewList, encoded_list)


    def save_embed_mapping(self, output_filename):
        # Prints the word followed by its unique integer id in order to save the embeddings
        with open(output_filename, 'w') as save_file:
            for word in self.embeddings:
                save_file.write(word + ' ' + self.embeddings[word] + '\n')

        