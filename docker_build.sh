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



function show_usage (){
    printf "Usage: $0 [options [parameters]]\n"
    printf "\n"
    printf "Options:\n"
    printf " -u|--user, Username of the registry (required)\n"
    printf " -i|--image, Image tag to build (required)\n"
    printf " -r|--registry, Registry (default: docker.io)\n"
    printf " -p|--project, Project (default: empty)\n"
    printf " -d|--dir, Directory of the function (default: ./ )\n"
    printf " -h|--help, Print help\n"
exit 1
}

user_reg=""
image_tag=""
registry=""
project=""
dir="."

while [ -n "$1" ]; do
  case "$1" in
     --user|-u)
        shift
        user_reg=$1
         ;;
     --image|-i)
        shift
        image_tag=$1
         ;;
     --registry|-r)
         shift
         registry=$1
         ;;
     --project|-p)
         shift
         project=$1
         ;;
     --dir|-d)
        shift
        dir=$1
         ;;
     *)
        show_usage
        ;;
  esac
shift
done

if [ -n "${registry}" ]; then
    registry=${registry}/
fi

if [ -n "${project}" ]; then
    project=${project}/
fi

if [ -z "${user_reg}" ] || [ -z "${image_tag}" ]; then
    show_usage
fi

echo "Listing tags in registry ..."
print_docker_repo_tags "$user_reg" "$image_tag"
image_version=$(grep "^$image_tag" versions.txt)
image_version=${image_version#*=}

full_tag=${registry}${user_reg}/${project}${image_tag}
while true; do
    echo "Ready to build/push: $full_tag:$image_version"
    read -r -p "Are You Sure? [Y/n] " input
    case $input in
    [yY][eE][sS] | [yY])
        cd "$dir"/"${image_tag}" || exit
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
