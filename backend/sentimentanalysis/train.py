# Code for developing our model

import vocab as vocab_functions
import helpers
import numpy as np
from embedder import Embedder
from model import Model
import torch

def process_reviews(filename, vocab):
    # Returns list of reviewText strings
    reviews = []
    with open(filename, 'r') as reviewFile:
        for line in reviewFile:
            line = line.strip()
            processed_review = helpers.clean_review(line, vocab)
            reviews.append(processed_review)

    return reviews


def predictions(logits):
    predictions = []
    print(logits)
    for result in logits:
        best_score = 0
        idx = 0
        i = 0
        while i < len(result):
            if result[i] > best_score:
                best_score = result[i]
                idx = i
            i += 1
        predictions.append(idx)

    return predictions


def train_epoch(model, X, y, loss, optimization):
    # Train an epoch!
    optimization.zero_grad()

    # run model on data, then adjust and optimize model
    results = model(X)
    epoch_loss = loss(results, y)
    epoch_loss.backward()


def evaluate_model(model, X):
    with torch.no_grad():
        output = model(X)
        return predictions(output.data)


def get_accuracy(y_pred, y_true):
    total = len(y_pred)
    correct = 0.0
    for i in range(total):
        if y_true[i] == y_pred[i]:
            correct += 1

    return float(correct) / float(total)

def main():
    # define filename constants
    vocab_filename = 'vocab.txt'
    training_filename = 'training_data.txt'
    test_filename = 'test_data.txt'

    # load vocab 
    print("Loading vocabulary...")
    vocab_list = vocab_functions.load_vocab(vocab_filename)

    # Gather training data
    print("Loading training data...")
    training_reviews = process_reviews(training_filename, vocab_list)
    Y_Train = helpers.get_labels(training_filename)

    # Set up Embedder
    print("Embedding process initiated...")
    embedder = Embedder(vocab_list, training_reviews)
    X_Train = embedder.encode_reviews(training_reviews)

    # Create Model
    print("Initiating model parameters to random values...")
    model = Model(len(vocab_list))

    # Define Loss and Optimization metrics
    learning_rate = 1e-3
    loss = torch.nn.CrossEntropyLoss()
    optimization = torch.optim.Adam(model.parameters(), lr=learning_rate)


    # Begin training
    print("Begin training...")
    start_idx = 0
    epoch_size = 40
    while start_idx + epoch_size - 1 < len(Y_Train):
        print("Training model with training indices from", start_idx, "to", start_idx + epoch_size -1)
        # Get data for this epoch, put data into epoch
        X_epoch = X_Train[start_idx:start_idx + epoch_size]
        X_epoch = helpers.array_to_long_tensor(X_epoch)
        Y_epoch = Y_Train[start_idx:start_idx + epoch_size]
        Y_epoch = helpers.array_to_long_tensor(Y_epoch)

        # train model
        train_epoch(model, X_epoch, Y_epoch, loss, optimization)
        start_idx += epoch_size

    print("Model has been trained")
    print("Evaluating model with test data...")

    test_filename = 'smaller_test.txt'

    # prepare testing data
    X_test = process_reviews(test_filename, vocab_list)
    X_test = embedder.encode_reviews(X_test)

    y_test = helpers.get_labels(test_filename)

    start_idx = 0
    epoch_size = 40
    y_pred = []
    y_true = []
    print("length of test data:", len(y_test))
    while start_idx + epoch_size - 1 < len(y_test):
        print("Testing model with testing indices from", start_idx, "to", start_idx + epoch_size -1)
        # Get data for this epoch
        X_epoch = X_test[start_idx:start_idx + epoch_size]
        X_epoch = helpers.array_to_long_tensor(X_epoch)

        # test model
        temp_pred = evaluate_model(model, X_epoch)
        y_pred.extend(list(temp_pred))
        y_true.extend(y_test[start_idx:start_idx + epoch_size])

        start_idx += epoch_size


    # output results
    '''
    print("\n\n\nOUTPUT FORMAT")
    print("Predicted - Actual")
    for i in range(len(y_true)):
        print(y_pred[i], y_true[i])
    '''
    print('\n\n\n')
    print(y_true)
    print("Accuracy:", get_accuracy(y_pred, y_true))
    

if __name__ == '__main__':
    main()