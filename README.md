# OpenFaas functions repository

Repository of OpenFaas functions built using [of-watchdog](https://github.com/openfaas/of-watchdog#1-http-modehttp) in `http` mode.

## Serverless functions

### 1. `hello-world`

Function in bash that returns `Hello World!` string.

```
faas deploy --image fcarp10/hello-world --name hello-world
curl http://127.0.0.1:8080/function/hello-world
```

### 2. `payload-echo`

This function returns back the string data received.

```
faas deploy --image fcarp10/payload-echo --name payload-echo
curl http://127.0.0.1:8080/function/payload-echo -d '{"test":"hello world!","index":"123"}'
```

### 3. `img-classifier-hub`

This function uses tensorflow hub and inception v3 model for image classification.

```
faas deploy --image fcarp10/img-classifier-hub --name img-classifier-hub --fprocess "python index.py"
curl http://127.0.0.1:8080/function/img-classifier-hub -d "https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg"
```

### 4. `fib-go`

Recursive Fibonacci function in Go.

```
faas deploy --image fcarp10/fib-go --name fib-go
curl http://127.0.0.1:8080/function/fib-go -d "10"
```

### 5. `payload-echo-workflow`

This function forwards the payload received to other endpoints.

```shell
faas deploy --image fcarp10/payload-echo-workflow --name payload-echo-workflow
```
Forwarding to rabbitmq (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"rburl":"amqp://user:password@rabbitmq:5672/","event_timestamp":"2021-07-27T13:19:19.923274599+02:00", "exchangerb":"amq.topic", "routingkeyrb":"logstash","doc":{"key_ex":"value_ex"}}'
```
Forwarding to elasticsearch (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"esurl":"http://elasticsearch-master:9200", "event_timestamp":"2021-07-27T13:19:19.923274599+02:00","ides":"bench_kns", "pipees": "calculate_lag", "doces":"1" ,"doc":{"key_ex":"value_ex"}}'
```
Forwarding to payload-echo-workflow (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"fsurl":"http://127.0.0.1:8080/function/payload-echo-workflow", "event_timestamp":"2021-07-27T13:19:19.923274599+02:00","doc":{"key_ex":"value_ex"}, "forwards": 3}'
```
Forwarding to client (example):

```shell
curl http://127.0.0.1:8080/function/payload-echo-workflow -d '{"event_timestamp":"2021-07-27T13:19:19.923274599+02:00","doc":{"key_ex":"value_ex"}}'
```

### 6. `sentiment-analysis`

This is a forked version of the work by
[Alexellis](https://github.com/openfaas/faas/tree/master/sample-functions/SentimentAnalysis).
This function provides a rating on sentiment positive/negative
(polarity-1.0-1.0) and subjectivity to provided to each of the sentences sent in
via the [TextBlob project](http://textblob.readthedocs.io/en/dev/).

```
faas deploy --image fcarp10/sentiment-analysis --name sentiment --fprocess "python index.py"
curl http://127.0.0.1:8080/function/sentiment -d "Personally I like functions to do one thing and only one thing well, it makes them more readable."
```

### 7. `fake-news-train`

TBD
