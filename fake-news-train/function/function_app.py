#Import the libraries
import math
import pandas as pd
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import MultinomialNB
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import PassiveAggressiveClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.neural_network import MLPClassifier
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import cross_val_score, GridSearchCV
from sklearn.model_selection import RepeatedStratifiedKFold



def execute(req):
    # Dictionary for representing the results, the values would be None at the initial time
    global resultdict
    resultdict = {'accuracy': None, 'best parameters': None}

    #extract the elements of the X and y columns that would be used for the training
    X = []
    y = []
    for i in req['x_dict'].keys():
        btext = req['x_dict'][str(i)]
        X.append(btext)
    for i in req['y_dict'].keys():
        label = req['y_dict'][str(i)]
        y.append(label)


    #THE MODELS

    # PASSIVE AGGRESSIVE CLASSIFIER
    if req['model'] == 'pac':
        #Create a pipeline of Tfidf Vectorizer and Passive Aggressive Classifier
        pipeline = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                            ('pamodel', PassiveAggressiveClassifier(max_iter=100000))])
        # define search space
        param_grid = {'pamodel__loss': ['hinge', 'squared_hinge'],
                      'pamodel__fit_intercept': [True, False],
                      'pamodel__C': [0.0001, 0.001, 0.01, 0.1, 1, 10]}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        pc = list(d.values())[0]
        pfitintercept = list(d.values())[1]
        ploss = list(d.values())[2]
        m2 = bool(pfitintercept)
        bestparamarr = {'C': pc, 'fit_intercept': m2, 'loss': ploss}
        #update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_


    #LOGISTIC REGRESSION
    if req['model'] == 'log':
        # Create a pipeline of Tfidf Vectorizer and Logistic Regression
        pipeline2 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                              ('logreg', LogisticRegression(max_iter=1000000))])
        # define search space
        param_grid = {  # 'logreg__solver': ['liblinear', 'saga', 'sag'],
            'logreg__solver': ['saga'],
            'logreg__penalty': ['l1', 'l2', 'elasticnet'],
            'logreg__C': [0.0001, 0.001, 0.01, 0.1, 1, 10]}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline2, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        lsolver = list(d.values())[2]
        lpenalty = list(d.values())[1]
        lC = list(d.values())[0]
        lC = float(lC)
        bestparamarr = {'C': lC, 'penalty': lpenalty, 'solver': lsolver}
        # update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_


    #NB MULTINOMIAL MODEL
    if req['model'] == 'mnb':
        # Create a pipeline of Tfidf Vectorizer and Multinomial NB
        pipeline3 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                              ('Mnb', MultinomialNB())])
        # define search space
        param_grid = {'Mnb__fit_prior': [True, False],
                      'Mnb__alpha': [0.001, 0.01, 0.1, 1]}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline3, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        mnba = list(d.values())[0]
        mnbfitp = list(d.values())[1]
        m2 = bool(mnbfitp)
        bestparamarr = {'alpha':mnba, 'fit_prior':m2}
        # update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_


    #MLP CLASSIFIER (NEURAL NETWORK)
    if req['model'] == 'mlpc':
        #first use the length of data to determine the appropriate number of nodes per hidden layer
        #the formula derived from the rule of thumb for two hidden layers is implemented here
        #the formula is: ndn^2 + (3+no_classes)*ndn + 4 = length of data / 10, where no_classes = number of classes of y
        #the formula is used to determine ndn which is number of nodes per layer by solving as a quadratic equation
        l = len(X) / 10
        c = 4 - l
        uniq = len(pd.unique(y))
        b = 3 + uniq
        a = 1
        numera = b ** 2 - 4 * a * c
        x1 = (- b + (math.sqrt(numera))) / (2 * a)
        x2 = (- b - (math.sqrt(numera))) / (2 * a)
        if numera <= 0:
            ndn = 3
        elif x1 <= 0 and x2 <= 0:
            ndn = 3
        else:
            ndn = int(max(x1, x2))
            if ndn < 3:
                ndn = 3
        # Create a pipeline of Tfidf Vectorizer and Multilayer Perceptron Classifier
        pipeline4 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                              ('MLPC', MLPClassifier(max_iter=1000000))])
        # define search space
        param_grid = {'MLPC__hidden_layer_sizes': [(ndn, ndn), (int(ndn*2/3), int(ndn*2/3)), (int(ndn*4/9), int(ndn*4/9))],
                      'MLPC__activation': ['logistic', 'tanh', 'relu'],
                      #'MLPC__solver': ['lbfgs', 'sgd', 'adam'],
                      'MLPC__learning_rate_init': [0.001, 0.01, 1]}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline4, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        act = list(d.values())[0]
        hidden = list(d.values())[1]
        hiddenlayerdict = {'first_hidden_layer': None, 'second_hidden_layer': None}
        hiddenlayerdict['first_hidden_layer'] = str(hidden[0])
        hiddenlayerdict['second_hidden_layer'] = str(hidden[1])
        d['MLPC__hidden_layer_sizes'] = hiddenlayerdict
        learnrate = list(d.values())[2]
        m3 = float(learnrate)
        #solv = list(d.values())[3]
        bestparamarr = {'activation': act, 'hidden_layer_sizes': hiddenlayerdict, 'learning_rate': m3}
                        #'solver': solv}
        # update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_


    #SUPPORT VECTOR CLASSIFIER
    if req['model'] == 'svc':
        # Create a pipeline of Tfidf Vectorizer and Support Vector Classifier
        pipeline5 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                              ('SVC', SVC(max_iter=1000000))])
        # define search space
        param_grid = {'SVC__kernel': ['poly', 'rbf', 'sigmoid'],
                      'SVC__gamma': ['scale', 'auto'],
                      'SVC__C': [0.01, 0.1, 1, 10]}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline5, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        sc = list(d.values())[0]
        sc = float(sc)
        svck = list(d.values())[2]
        svcg = list(d.values())[1]
        bestparamarr = {'C':sc, 'gamma':svcg, 'kernel':svck}
        # update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_


    #DECISION TREE CLASSIFIER
    if req['model'] == 'dt':
        # Create a pipeline of Tfidf Vectorizer and Decision Tree Classifier
        pipeline6 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                              ('DT', DecisionTreeClassifier())])
        # define search space
        param_grid = {'DT__max_features': ['sqrt', 'log2', 'None'],
                      'DT__max_depth': [None, 5, 10],
                      'DT__criterion': ['gini', 'entropy']}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline6, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        crit = list(d.values())[0]
        md = list(d.values())[1]
        if md != None:
            md = float(md)
        mf = list(d.values())[2]
        bestparamarr = {'criterion': crit, 'max_depth': md, 'max_features': mf}
        # update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_


    #K NEIGHBORS CLASSIFIER
    if req['model'] == 'kn':
        # Create a pipeline of Tfidf Vectorizer and K Neighbors Classifier
        pipeline7 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                              ('KN', KNeighborsClassifier())])
        # define search space
        param_grid = {'KN__weights': ['uniform', 'distance'],
                      'KN__n_neighbors': [5, 10, 20],
                      'KN__algorithm': ['auto', 'ball_tree', 'kd_tree']}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline7, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        algo = list(d.values())[0]
        nneigh = list(d.values())[1]
        nneigh = float(nneigh)
        wei = list(d.values())[2]
        bestparamarr = {'algorithm': algo, 'n_neighbors': nneigh, 'weights': wei}
        # update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_


    #RANDOM FOREST CLASSIFIER
    if req['model'] == 'rf':
        # Create a pipeline of Tfidf Vectorizer and Random Forest Classifier
        pipeline8 = Pipeline([('tfidf', TfidfVectorizer(stop_words='english')),
                              ('RF', RandomForestClassifier())])
        # define search space
        param_grid = {'RF__n_estimators': [50, 100, 200],
                      'RF__max_depth': [None, 5, 10],
                      'RF__criterion': ['gini', 'entropy']}
        # define evaluation
        cv = RepeatedStratifiedKFold(n_splits=2, n_repeats=3, random_state=1)
        # define search
        # set n_jobs = -1 so as to use all the cores in ur system
        search = GridSearchCV(pipeline8, param_grid, cv=cv, n_jobs=-1, scoring='accuracy')
        # execute search
        result = search.fit(X, y)
        # summarize result
        d = result.best_params_
        crit = list(d.values())[0]
        md = list(d.values())[1]
        if md != None:
            md = float(md)
        ne = list(d.values())[2]
        ne = float(ne)
        bestparamarr = {'criterion': crit, 'max_depth': md, 'n_estimators': ne}
        # update the results dictionary with the values of the parameters and accuracy
        resultdict['best parameters'] = bestparamarr
        resultdict['accuracy'] = result.best_score_



    return resultdict

