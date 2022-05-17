#! /bin/bash

TENSORFLOW_PACKAGE_ARM64="https://github.com/lhelontra/tensorflow-on-arm/releases/download/v2.4.0/tensorflow-2.4.0-cp37-none-linux_aarch64.whl"
ADDITIONAL_PACKAGE_ARM64="libatlas-base-dev gfortran libhdf5-dev libc-ares-dev libeigen3-dev libopenblas-dev libblas-dev liblapack-dev build-essential wget"
ADDITIONAL_PACKAGE_AMD64="wget"
TENSORFLOW_PACKAGE_AMD64="tensorflow==2.4.1"

MODEL_URL="https://tfhub.dev/google/imagenet/inception_v3/classification/5?tf-hub-format=compressed"
IMAGE_LABELS_URL="https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt"

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build --push --platform linux/arm64 --tag "$image_tag":"$image_version"-arm64 \
    --build-arg MODEL_URL="$MODEL_URL" \
    --build-arg IMAGE_LABELS_URL="$IMAGE_LABELS_URL" \
    --build-arg TENSORFLOW_PACKAGE="$TENSORFLOW_PACKAGE_ARM64" \
    --build-arg ADDITIONAL_PACKAGE="$ADDITIONAL_PACKAGE_ARM64" .

docker buildx build --push --platform linux/amd64 --tag "$image_tag":"$image_version"-amd64 \
    --build-arg MODEL_URL="$MODEL_URL" \
    --build-arg IMAGE_LABELS_URL="$IMAGE_LABELS_URL" \
    --build-arg TENSORFLOW_PACKAGE="$TENSORFLOW_PACKAGE_AMD64" \
    --build-arg ADDITIONAL_PACKAGE="$ADDITIONAL_PACKAGE_AMD64" .

docker manifest create "$image_tag":"$image_version" \
    --amend "$image_tag":"$image_version"-arm64 \
    --amend "$image_tag":"$image_version"-amd64

docker manifest push --purge "$image_tag":"$image_version"

docker manifest create "$image_tag":latest \
    --amend "$image_tag":"$image_version"-arm64 \
    --amend "$image_tag":"$image_version"-amd64

docker manifest push --purge "$image_tag":latest
