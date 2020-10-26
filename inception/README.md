
## Inception

This is a forked version of the work by [Alexellis](https://github.com/faas-and-furious/inception-function). It has been extended by adding the possibility of sending images directly encoded with Basae64 instead of downloading them. It has also been added ARM compatibility. 


Deploy and test:

```
faas deploy --image fcarp10/inception --name inception --fprocess "python index.py"
curl http://127.0.0.1:8080/function/inception -d "https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg"
```
