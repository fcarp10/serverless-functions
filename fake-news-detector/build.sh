#! /bin/bash

# general parameters
USER_REGISTRY=fcarp10 # registry user name
IMAGE=fake-news-detector # image tag name
VERSION=v1.0.0 # image version

# parameters when using registries different than docker hub, comment out otherwise
REGISTRY_ALTER=registry.gitlab.com/ # registry different than docker hub (comment out for docker hub) 
PROJECT_ALTER=openfaas-functions/ # project name (comment out for docker hub) 


TAG="$REGISTRY_ALTER""$USER_REGISTRY"/"$PROJECT_ALTER""$IMAGE"

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build --push --platform linux/arm64 --tag "$TAG":"$VERSION"-arm64 .
docker buildx build --push --platform linux/amd64 --tag "$TAG":"$VERSION"-amd64 .

docker manifest create "$TAG":"$VERSION" \
    --amend "$TAG":"$VERSION"-arm64 \
    --amend "$TAG":"$VERSION"-amd64

docker manifest push --purge "$TAG":"$VERSION"

docker manifest create "$TAG":latest \
    --amend "$TAG":"$VERSION"-arm64 \
    --amend "$TAG":"$VERSION"-amd64

docker manifest push --purge "$TAG":latest
