import pickle

with open('function/model.pickle', 'rb') as handle:
    model = pickle.load(handle)

def predict(body):
    label_prediction = model.predict([body])
    return label_prediction[0]

