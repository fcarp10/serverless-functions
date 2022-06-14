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

This function forwards JSON payloads to a destination url which can be used to
test chains of functions on the server side. If no destination is specified,
then just returns the JSON payload to the client. If destination is `none`, then
returns `{}` regardless of the payload received.

```shell
foo@bar:~$ faas deploy --image fcarp10/payload-echo --name payload-echo
```

- Case 1: The function forwards payload to `dst` url, this process is repeated N
  times which value is specified in `length`:
    ```
    foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo -d '{"dst":"http://127.0.0.1:8080/function/payload-echo","doc":{"test":"hello world!"}, "length": 10}'
    {"doc":{"test":"hello world!"},"dst":"http://127.0.0.1:8080/function/payload-echo","length":0}
    ```

- Case 2: If no destination url is specified, then the function returns the payload:
    ```
    foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo -d '{"test":"hello world!"}'
    {"test":"hello world!"}
    ```

- Case 3: If destination is `none`, then the function returns `{}`:
    ```
    foo@bar:~$ curl http://127.0.0.1:8080/function/payload-echo -d '{"dst":"none", "test":"hello world!"}'
    {}
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

### 5. `sentiment-analysis`

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

### 6. `fake-news-train`

This function trains a fake news detector ML model. The function expects in the
payload a dictionary with the statements and labels defined in JSON format. An
example of the data structure can be found
[here](fake-news-train/example_data.json).

```shell
foo@bar:~$ faas deploy --image fcarp10/fake-news-train --name fake-news-train --fprocess "python index.py"
foo@bar:~$ curl http://127.0.0.1:8080/function/fake-news-train -d @example_data.json
{"accuracy":0.7809669703566341,"best parameters":{"alpha":0.01,"fit_prior":false}}
```