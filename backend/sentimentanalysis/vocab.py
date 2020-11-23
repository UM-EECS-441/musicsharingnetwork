# Code for vocab related functions. This script is run after split between train and test data is complete
import sentimentanalysis.helpers as helpers
import sentimentanalysis.constants as constants

def get_vocab(filename):
    # Returns a list of all words in all reviews
    vocab = {}

    with open(filename, 'r') as reviewFile:
        for review in reviewFile:
            words = helpers.get_words(review, True)
            for i, word in enumerate(words):
                #if i == constants.max_review_length:
                #    break

                vocab[word] = vocab.get(word, 0) + 1

    # If a word is only used once in 1 review, get rid of it from the vocab list
    min_occurence = 1
    words = [word for word, count in vocab.items() if count > min_occurence]

    return words


def write_to_vocab_file(vocab):
    # Writes all vocabulary words to vocab.txt
    output_filename = "vocab.txt"
    with open(output_filename, 'w') as vocab_file:
        for word in vocab:
            vocab_file.write(word + "\n")


def load_vocab(vocab_filename):
    # Returns a list of all vocab words from the vocab_filename file
    vocab = list()
    with open(vocab_filename, 'r') as vocab_file:
        for line in vocab_file:
            line = line.strip()
            vocab.append(line)

    return vocab

vocab = get_vocab(constants.training_filename)
write_to_vocab_file(vocab)
