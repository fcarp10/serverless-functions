This function uses Tensorflow Hub and the FasterRCNN+InceptionResNet V2 to
perform object detection. The function expects the URL of an image and returns a
processed image encoded as base64. Example:

```shell
foo@bar:~$ curl http://127.0.0.1:8080/function/object-detector-hub -d "https://upload.wikimedia.org/wikipedia/commons/6/60/Naxos_Taverna.jpg" | base64 -d > processed_image.jpg
```