This function is an updated version of the work by
[Alexellis](https://github.com/openfaas/store-functions/tree/master/sentimentanalysis).
This function provides a rating on sentiment positive/negative
(polarity-1.0-1.0) and subjectivity to provided to each of the sentences sent in
via the [TextBlob project](http://textblob.readthedocs.io/en/dev/).

```shell
foo@bar:~$ curl http://127.0.0.1:8080/function/sentiment-analysis -d "Personally I like functions to do one thing and only one thing well, it makes them more readable."
{"polarity": 0.16666666666666666, "subjectivity": 0.6, "sentence_count": 1}
```