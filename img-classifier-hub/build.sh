#! /bin/bash

USER_DOCKER=fcarp10
IMAGE=img-classifier-hub

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build --push --platform linux/arm64 --tag "$USER_DOCKER"/"$IMAGE":"$VERSION"-arm64 \
    --build-arg TENSORFLOW_PACKAGE="https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-2.4.0-cp37-none-linux_aarch64.whl" \
    --build-arg ADDITIONAL_PACKAGE="libatlas-base-dev gfortran libhdf5-dev libc-ares-dev libeigen3-dev libopenblas-dev libblas-dev liblapack-dev build-essential" .

docker buildx build --push --platform linux/amd64 --tag "$USER_DOCKER"/"$IMAGE":"$VERSION"-amd64 .

docker manifest create "$USER_DOCKER"/"$IMAGE":"$VERSION" \
    --amend "$USER_DOCKER"/"$IMAGE":"$VERSION"-arm64 \
    --amend "$USER_DOCKER/$IMAGE":"$VERSION"-amd64

docker manifest push --purge "$USER_DOCKER"/"$IMAGE":"$VERSION"

docker manifest create "$USER_DOCKER"/"$IMAGE":latest \
    --amend "$USER_DOCKER"/"$IMAGE":"$VERSION"-arm64 \
    --amend "$USER_DOCKER/$IMAGE":"$VERSION"-amd64

docker manifest push --purge "$USER_DOCKER"/"$IMAGE":latest
