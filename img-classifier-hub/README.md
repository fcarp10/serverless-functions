## img-classifier-hub

This function uses tensorflow hub and inception v3 model for image classification.

### Deploy the function on OpenFaas

```
faas deploy --image fcarp10/img-classifier-hub --name img-classifier-hub --fprocess "python index.py"
```

### Test the function using curl

```
curl http://127.0.0.1:8080/function/img-classifier-hub -d "https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg"
```

### Build 

```
export VERSION=v1.x.x
chmod +x build.sh
./build.sh
```

