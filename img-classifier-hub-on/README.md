## Image classifier function using TensorFlow Hub (Online version)

This function uses tensorflow hub and inception v3 model for image classification. 

* This version downloads the model on the fly the first time the container is deployed.

### Deploy the function on OpenFaas

```
faas deploy --image fcarp10/img-classifier-hub-on --name img-classifier-hub-on --fprocess "python index.py"
```
### Test the function using curl

```
curl http://127.0.0.1:8080/function/img-classifier-hub-on -d "https://upload.wikimedia.org/wikipedia/commons/6/61/Humpback_Whale_underwater_shot.jpg"
```

### Build

Building for `arm64`:
```
docker buildx build --push --platform linux/arm64 --tag fcarp10/img-classifier-hub-on:arm64 \
    --build-arg TENSORFLOW_PACKAGE="https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.3.0/tensorflow-2.3.0-cp37-none-linux_aarch64.whl" \
    --build-arg ADDITIONAL_PACKAGE="libatlas-base-dev gfortran libhdf5-dev libc-ares-dev libeigen3-dev libopenblas-dev libblas-dev liblapack-dev build-essential" .
```

Building for `amd64`:

```
docker buildx build --push --platform linux/amd64 --tag fcarp10/img-classifier-hub-on:amd64 .
```

Create and push a manifest with tag `latest` and add both images
``` 
docker manifest create fcarp10/img-classifier-hub-on:latest \
    --amend fcarp10/img-classifier-hub-on:arm64 \
    --amend fcarp10/img-classifier-hub-on:amd64

docker manifest push --purge fcarp10/img-classifier-hub-on:latest
```