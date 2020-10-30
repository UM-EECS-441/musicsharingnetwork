# Script for splitting data into training and testing data and test data into separate files
# For each file, each line will contain the review and score (out of 5) separated by a |
# Punctuation and weird html characters strings are removed
from string import punctuation
import helpers

def split_reviews(filename):
    # Split and clean reviews: 80% test, 20% train
    train_filename = "training_data.txt"
    test_filename = "test_data.txt"
    modulus = 5 # const value, every modulus review is put into test data
    
    # list of weird html substrings found in reviews. DO NOT CHANGE THIS.
    weird_strings = ["&#34;", "&#8230;", "&#8217;", "&#8211;", "&#8220;", "&#8222;", "&#8221;",
                     "&#8212;", "&#8216;", "&#65533;", "&#60;", "&#62;", "&#367;", "&#8203;",
                     "&#26368;", "&#39640;", "&#12384;", "&#12290;", "&#345;", "&#128521;", 
                     "&#949;", "&#9889;", "&#9837;", "&#257;", "&#65279;", "&#127775;", "&#8206;",
                     "&#128151;", "&#8978;", "&#8213;", "&#8978;", "&#8242;", "&amp;", "&#305;",
                     "&#351;", "&#128079;", "&#128077;", "&#9786;", "&#128155;", "&#128153;",
                     "&#128156;", "&#128154;", "&#128159;", "&#8226;", "&#128148;", "&#10084;",
                     "&#65039;", "&#3232;", "&#8364;", "quot"]

    # write reviews to the 2 data files
    with open(filename, 'r') as review_file:
        train_file = open(train_filename, 'w')
        test_file = open(test_filename, 'w')
        for i, line in enumerate(review_file):
            if i > 50000:
                break
            # read json
            data = eval(line)

            # remove weird strings and make all text lowercase
            reviewText = data['reviewText'].lower()
            for removal in weird_strings:
                reviewText = reviewText.replace(removal, "")

            # remove punctuation
            reviewText = helpers.remove_punctuation(reviewText)

            # evaluate score
            score = 0
            if data['overall'] > 3:
                score = 1

            # insert review into proper file
            if i % modulus != 0:
                train_file.write(reviewText + '|' + str(score) + '\n')
            else:
                test_file.write(reviewText + '|' + str(score) + '\n')


review_filename = 'mard_reviews.json'
split_reviews(review_filename)

