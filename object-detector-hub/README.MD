This function uses Tensorflow Hub and the FasterRCNN+InceptionResNet V2
to apply object dectection to the images.
The image can be sent specifying the URL and will provide an output in form of a base64 encoded string of a .png file.
Use the comand line to write it into a file or decoded into a .png image

```shell
foo@bar:~$ curl http://127.0.0.1:8080/function/object-detector-hub -d "https://upload.wikimedia.org/wikipedia/commons/6/60/Naxos_Taverna.jpg"
```