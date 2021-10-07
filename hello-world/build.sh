#! /bin/bash

USER_DOCKER=fcarp10
IMAGE=hello-world
VERSION=v1.1.0

if [[ -z "${VERSION}" ]]; then
    echo "aborting..., specify a release version with 'export VERSION=v1.X.Y'"
    exit 1
fi

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build --push --platform linux/amd64 --tag "$USER_DOCKER"/"$IMAGE":"$VERSION"-amd64 \
    --build-arg TARGETOS=linux \
    --build-arg TARGETARCH=amd64 .

docker buildx build --push --platform linux/arm64 --tag "$USER_DOCKER"/"$IMAGE":"$VERSION"-arm64 \
    --build-arg TARGETOS=linux \
    --build-arg TARGETARCH=arm64 .

docker manifest create "$USER_DOCKER"/"$IMAGE":"$VERSION" \
    --amend "$USER_DOCKER"/"$IMAGE":"$VERSION"-arm64 \
    --amend "$USER_DOCKER/$IMAGE":"$VERSION"-amd64

docker manifest push --purge "$USER_DOCKER"/"$IMAGE":"$VERSION"

docker manifest create "$USER_DOCKER"/"$IMAGE":latest \
    --amend "$USER_DOCKER"/"$IMAGE":"$VERSION"-arm64 \
    --amend "$USER_DOCKER/$IMAGE":"$VERSION"-amd64

docker manifest push --purge "$USER_DOCKER"/"$IMAGE":latest
