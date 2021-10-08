#! /bin/bash

REGISTRY=registry.gitlab.com/ # comment out when pushing to docker hub 
PROJECT=openfaas-functions/ # comment out when pushing to docker hub 
USER_DOCKER=fcarp10
IMAGE=payload-echo-rbes
VERSION=v1.0.1

if [[ -z "${VERSION}" ]]; then
    echo "aborting..., specify a release version with 'export VERSION=v1.X.Y'"
    exit 1
fi

TAG="$REGISTRY""$USER_DOCKER"/"$PROJECT""$IMAGE"

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build --push --platform linux/amd64 --tag "$TAG":"$VERSION"-amd64 \
    --build-arg TARGETOS=linux \
    --build-arg TARGETARCH=amd64 .

docker buildx build --push --platform linux/arm64 --tag "$TAG":"$VERSION"-arm64 \
    --build-arg TARGETOS=linux \
    --build-arg TARGETARCH=arm64 .

docker manifest create "$TAG":"$VERSION" \
    --amend "$TAG":"$VERSION"-arm64 \
    --amend "$TAG":"$VERSION"-amd64

docker manifest push --purge "$TAG":"$VERSION"

docker manifest create "$TAG":latest \
    --amend "$TAG":"$VERSION"-arm64 \
    --amend "$TAG":"$VERSION"-amd64

docker manifest push --purge "$TAG":latest
