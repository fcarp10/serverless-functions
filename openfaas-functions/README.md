# OpenFaas functions repository

Repository of OpenFaas functions built using
[of-watchdog](https://github.com/openfaas/of-watchdog#1-http-modehttp) in `http`
mode.

## Functions

### Simple:
- `hello-world`: returns a "Hello World!" string.
- `payload-echo`: forwards JSON payloads to a specific url.
- `fib-go`: calculates the recursive Fibonacci number of the specified value.
- `sleep`: sleeps for a time duration specified in milliseconds.

### ML:
- `img-classifier-hub`: uses Tensorflow Hub and the inception v3 model to
classify images. The image can be sent in the payload coded in Base64 or by
specifying the URL.
- `object-detector-hub`: uses Tensorflow Hub and the FasterRCNN+InceptionResNet V2
to apply object dectection to the images. The image can be sent by specifying the URL. 
- `sentiment-analysis`: is an updated version of the work by
[Alexellis](https://github.com/openfaas/store-functions/tree/master/sentimentanalysis).
This function provides a rating on sentiment positive/negative
(polarity-1.0-1.0) and subjectivity to provided to each of the sentences sent in
via the [TextBlob project](http://textblob.readthedocs.io/en/dev/).
- `fake-news-train`: trains a fake news detector ML model. The function expects
a JSON with statements and labels. An example of the data structure can be found
[here](fake-news-train/example_data.json).

## Deploy 

To deploy a function using `faas`, for instance:

```shell
foo@bar:~$ cd hello-world
foo@bar:~/hello-world$ faas deploy -f hello-world.yml
```
