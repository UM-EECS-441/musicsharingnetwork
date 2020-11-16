import numpy as np
from sklearn.svm import SVC
import helpers
import constants

def create_dictionary():
    # creates a mapping of words
    word_dict = {}
    idx = 1
    with open(constants.vocab_filename) as vocab:
        for word in vocab:
            word = word.strip()
            if word not in word_dict:
                word_dict[word] = idx
                idx += 1

    return word_dict


def prep_data(reviews, mapping):
    # return feature matrix
    feature_size = len(mapping) + 1
    num_reviews = len(reviews)
    features = np.zeros((num_reviews, feature_size))
    for i in range(len(reviews)):
        words = reviews[i].split()
        for word in words:
            if word in mapping:
                features[i][mapping[word]] = 1

    return features


def get_accuracy(y_pred, y_true):
    total = len(y_pred)
    correct = 0.0
    for i in range(total):
        if y_true[i] == y_pred[i]:
            correct += 1

    return float(correct) / float(total)


def test_model():
    # This function is only necessary to test our models accuracy. It does not need to be called by anything.
    model = helpers.load_model()
    mapping = create_dictionary()
    X_Test, Y_Test = helpers.read_file(constants.test_filename)
    Y_Test = np.array(Y_Test)
    helpers.fix_svc_labels(Y_Test)
    X_Test = prep_data(X_Test, mapping)
    predictions = model.predict(X_Test)
    accuracy = get_accuracy(predictions, Y_Test)
    phrase = ""
    if accuracy > .65:
        phrase = "exceeds"
    else:
        phrase = "is less than"
    print("Our model has an accuracy of " + str(accuracy * 100) + "% which " + phrase + " our acceptance criteria of 65%.")


def main():
    # Load Data
    print("Loading data...")
    X_Train, Y_Train = helpers.read_file(constants.training_filename)
    X_Test, Y_Test = helpers.read_file(constants.test_filename)
    Y_Train = np.array(Y_Train)
    Y_Test = np.array(Y_Test)

    # fix labels
    helpers.fix_svc_labels(Y_Train)
    helpers.fix_svc_labels(Y_Test)

    # Prep data
    print("prepping data...")
    mapping = create_dictionary()
    X_Train = prep_data(X_Train, mapping)
    X_Test = prep_data(X_Test, mapping)

    # Create model 
    print("Training Model...")
    model = SVC(kernel='linear', C=.1, class_weight='balanced')
    model.fit(X_Train, Y_Train)

    # Test
    print("testing...")
    y_pred = model.predict(X_Test)
    accuracy = get_accuracy(y_pred, Y_Test)

    print("accuracy:", accuracy)
    # Save model parameters if our accuracy is better than 65%
    if accuracy > .65:
        helpers.save_model(model)



if __name__ == '__main__':
    main()