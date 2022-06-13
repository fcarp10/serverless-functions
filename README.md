# OpenFaas functions repository

Repository of OpenFaas functions built using [of-watchdog](https://github.com/openfaas/of-watchdog#1-http-modehttp) in `http` mode.

## Serverless functions

### 1. `hello-world`

This function returns `Hello World!` string.

```shell
foo@bar:~$ faas deploy --image fcarp10/hello-world --name hello-world
foo@bar:~$ curl http://127.0.0.1:8080/function/hello-world
Hello, World!
```

### 2. `payload-echo`

This function returns the same payload sent using JSON.

```shell
foo@bar:~$ faas deploy --image fcarp10/payload-echo --name payload-echo
foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo -d '{"test":"hello world!"}'
{"test":"hello world!"}
```

### 3. `img-classifier-hub`

This function uses Tensorflow Hub and the inception v3 model to classify images.
The image can be sent in the payload coded in Base64, or a URL of the image can
be specified instead.

```shell
foo@bar:~$ faas deploy --image fcarp10/img-classifier-hub --name img-classifier-hub --fprocess "python index.py"
foo@bar:~$  curl http://127.0.0.1:8080/function/img-classifier-hub -d "https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg"
sea lion
```

### 4. `fib-go`

This function calculates the recursive Fibonacci number from the specified value.

```shell
foo@bar:~$ faas deploy --image fcarp10/fib-go --name fib-go
foo@bar:~$ curl http://127.0.0.1:8080/function/fib-go -d "10"
102334155
```

### 5. `payload-echo-workflow`

This function is used to create chain on functions on the server side. Specify
the URL of the destination function in `dsturl`, the JSON message in `doc` and
the length of the chain in `length`. If the workflow was successful, the
response should have `"length":0`.

```shell
foo@bar:~$ faas deploy --image fcarp10/payload-echo-workflow --name payload-echo-workflow
foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"dsturl":"http://127.0.0.1:8080/function/payload-echo-workflow","doc":{"test":"hello world!"}, "length": 10}'
{"doc":{"test":"hello world!"},"dsturl":"http://127.0.0.1:8080/function/payload-echo-workflow","length":0}
```

### 6. `sentiment-analysis`

This is a forked version of the work by
[Alexellis](https://github.com/openfaas/faas/tree/master/sample-functions/SentimentAnalysis).
This function provides a rating on sentiment positive/negative
(polarity-1.0-1.0) and subjectivity to provided to each of the sentences sent in
via the [TextBlob project](http://textblob.readthedocs.io/en/dev/).

```shell
foo@bar:~$ faas deploy --image fcarp10/sentiment-analysis --name sentiment --fprocess "python index.py"
foo@bar:~$ curl http://127.0.0.1:8080/function/sentiment -d "Personally I like functions to do one thing and only one thing well, it makes them more readable."
{"polarity": 0.16666666666666666, "subjectivity": 0.6, "sentence_count": 1}
```

### 7. `fake-news-train`

This function trains a fake news detector ML model. The function expects in the
payload a dictionary with the statements and labels defined in JSON format. An
example of the data structure can be found
[here](fake-news-train/example_data.json).

```shell
foo@bar:~$ faas deploy --image fcarp10/fake-news-train --name fake-news-train --fprocess "python index.py"
foo@bar:~$ curl http://127.0.0.1:8080/function/fake-news-train -d @example_data.json
{"accuracy":0.7809669703566341,"best parameters":{"alpha":0.01,"fit_prior":false}}
```