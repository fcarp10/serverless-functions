#! /bin/bash

TENSORFLOW_PACKAGE_ARM64="https://github.com/KumaTea/tensorflow-aarch64/releases/download/v2.4/tensorflow-2.4.1-cp38-cp38-linux_aarch64.whl"
ADDITIONAL_PACKAGE_ARM64="libatlas-base-dev gfortran libhdf5-dev libc-ares-dev libeigen3-dev libopenblas-dev libblas-dev liblapack-dev build-essential wget"
ADDITIONAL_PACKAGE_AMD64="wget"
TENSORFLOW_PACKAGE_AMD64="tensorflow==2.4.1"

MODEL_URL="https://tfhub.dev/google/imagenet/inception_v3/classification/5?tf-hub-format=compressed"
IMAGE_LABELS_URL="https://storage.googleapis.com/download.tensorflow.org/data/ImageNetLabels.txt"

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build --push --platform linux/arm64 --tag "$full_tag":"$image_version"-arm64 \
    --build-arg MODEL_URL="$MODEL_URL" \
    --build-arg IMAGE_LABELS_URL="$IMAGE_LABELS_URL" \
    --build-arg TENSORFLOW_PACKAGE="$TENSORFLOW_PACKAGE_ARM64" \
    --build-arg ADDITIONAL_PACKAGE="$ADDITIONAL_PACKAGE_ARM64" .

docker buildx build --push --platform linux/amd64 --tag "$full_tag":"$image_version"-amd64 \
    --build-arg MODEL_URL="$MODEL_URL" \
    --build-arg IMAGE_LABELS_URL="$IMAGE_LABELS_URL" \
    --build-arg TENSORFLOW_PACKAGE="$TENSORFLOW_PACKAGE_AMD64" \
    --build-arg ADDITIONAL_PACKAGE="$ADDITIONAL_PACKAGE_AMD64" .

docker manifest create "$full_tag":"$image_version" \
    --amend "$full_tag":"$image_version"-arm64 \
    --amend "$full_tag":"$image_version"-amd64

docker manifest push --purge "$full_tag":"$image_version"

docker manifest create "$full_tag":latest \
    --amend "$full_tag":"$image_version"-arm64 \
    --amend "$full_tag":"$image_version"-amd64

docker manifest push --purge "$full_tag":latest
