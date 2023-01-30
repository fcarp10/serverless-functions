This function uses Tensorflow Hub and the inception v3 model to classify images.
The image can be sent in the payload coded in Base64 or by specifying the URL.

```shell
foo@bar:~$ curl http://127.0.0.1:8080/function/img-classifier-hub -d "https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg"
sea lion
```