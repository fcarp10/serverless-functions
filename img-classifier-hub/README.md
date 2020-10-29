## Image classifier function using TensorFlow Hub

Deploy and test:

```
faas deploy --image fcarp10/img-classifier-hub --name img-classifier-hub --fprocess "python index.py"
curl http://127.0.0.1:8080/function/img-classifier-hub -d "https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg"
```