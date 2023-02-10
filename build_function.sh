#! /bin/bash

function build_image() {
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

    docker buildx build --provenance=false --push --platform linux/amd64 --tag "$full_tag":"$image_version"-amd64 \
        --build-arg TARGETOS=linux \
        --build-arg TARGETARCH=amd64 \
        --build-arg ADDITIONAL_PACKAGE="$ADDITIONAL_PACKAGE_AMD64" \
        --build-arg EXTRA_ARG="$EXTRA_ARG_AMD64" .

    docker buildx build --provenance=false --push --platform linux/arm64 --tag "$full_tag":"$image_version"-arm64 \
        --build-arg TARGETOS=linux \
        --build-arg TARGETARCH=arm64 \
        --build-arg ADDITIONAL_PACKAGE="$ADDITIONAL_PACKAGE_ARM64" \
        --build-arg EXTRA_ARG="$EXTRA_ARG_ARM64" .

    docker manifest create "$full_tag":"$image_version" \
        --amend "$full_tag":"$image_version"-arm64 \
        --amend "$full_tag":"$image_version"-amd64

    docker manifest push --purge "$full_tag":"$image_version"

    docker manifest create "$full_tag":latest \
        --amend "$full_tag":"$image_version"-arm64 \
        --amend "$full_tag":"$image_version"-amd64

    docker manifest push --purge "$full_tag":latest
}

function print_docker_repo_tags() {
    for Repo in $* ; do
        curl -s -S "https://registry.hub.docker.com/v2/repositories/$1/$2/tags/?page_size=5" | \
        sed -e 's/,/,\n/g' -e 's/\[/\[\n/g' | \
        grep '"name"' | \
        awk -F\" '{print $4;}' | \
        sort -fu | \
        sed -e "s/^/$2:/"
    done
}

read -p "Registry (e.g. registry.gitlab.com, or leave empty to use Docker Hub): " registry
read -p "Project (e.g. openfaas-functions, or leave empty when using Docker Hub): " project
read -p "User: " user_registry

select image_tag in */
do  
    image_tag=${image_tag::-1} 
    echo "Listing tags in registry ..."
    print_docker_repo_tags $user_registry $image_tag
    image_version=`echo $(grep "^$image_tag" versions.txt)`
    image_version=${image_version#*=}
    break;
done


if [ ! -z "${registry}" ]; then
    registry=${registry}/
fi

if [ ! -z "${project}" ]; then
    project=${project}/
fi

full_tag=${registry}${user_registry}/${project}${image_tag}

while true; do
    echo "Ready to build/push: $full_tag:$image_version"
    read -r -p "Are You Sure? [Y/n] " input
    case $input in
    [yY][eE][sS] | [yY])
        cd $image_tag || exit
        if [[ $image_tag == *"-hub"* ]]; then
            ADDITIONAL_PACKAGE_AMD64="wget"
            EXTRA_ARG_AMD64="tensorflow==2.4.1"
            ADDITIONAL_PACKAGE_ARM64="libatlas-base-dev gfortran libhdf5-dev libc-ares-dev libeigen3-dev libopenblas-dev libblas-dev liblapack-dev build-essential wget"
            EXTRA_ARG_ARM64="https://github.com/KumaTea/tensorflow-aarch64/releases/download/v2.4/tensorflow-2.4.1-cp38-cp38-linux_aarch64.whl"
        fi
        build_image
        break
        ;;
    [nN][oO] | [nN])
        echo "Aborting..."
        break
        ;;
    *)
        echo "Invalid input..."
        ;;
    esac
done
