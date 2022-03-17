#import pickle5 as pickle

#Import the libraries
import pandas as pd
from sklearn import metrics
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import PassiveAggressiveClassifier

#import pickle
#Import the dataset
data = pd.read_csv('function/news.csv')
#Get the shape of the dataset
print(data.shape)
#Assign the label fake or real as variable y and text as variable X
X = data['text']
y = data['label']
#Split the data into train and test data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 6)

#PASSIVE AGGRESSIVE CLASSIFIER
#Create a pipeline of Tfidf Vectorizer and Passive Aggressive Classifier
pipeline = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                    ('pamodel', PassiveAggressiveClassifier())])
#Train the model with the train data
pipeline.fit(X_train, y_train)
#Predict the label of the test data
y_pred = pipeline.predict(X_test)

#LOGISTIC REGRESSION MODEL
pipeline2 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                    ('logreg', LogisticRegression())])
#Train the model with the train data
pipeline2.fit(X_train, y_train)
#Predict the label of the test data
y_pred2 = pipeline2.predict(X_test)

#NB MULTIMONIAL MODEL
pipeline3 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                    ('Mnb', MultinomialNB())])
#Train the model with the train data
pipeline3.fit(X_train, y_train)
#Predict the label of the test data
y_pred3 = pipeline3.predict(X_test)
'''
with open('function/model.pickle', 'rb') as handle:
    model = pickle.load(handle, protocol=4) '''

def predict(body):
    label_prediction = pipeline3.predict([body])
    return label_prediction[0]

