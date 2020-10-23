## SentimentAnalysis

This is a forked version of the work by [Alexellis](https://github.com/openfaas/faas/tree/master/sample-functions/SentimentAnalysis) 

Python function provides a rating on sentiment positive/negative (polarity -1.0-1.0) and subjectivity to provided to each of the sentences sent in via the [TextBlob project](http://textblob.readthedocs.io/en/dev/).


Deploy and test:

```
faas-cli deploy --image fcarp10/sentimentanalysis --name sentiment --fprocess "python index.py"
curl http://127.0.0.1:8080/function/sentiment -d "Personally I like functions to do one thing and only one thing well, it makes them more readable."
```

