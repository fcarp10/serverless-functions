#! /bin/bash

function build_generic_image() {
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

    docker buildx build --push --platform linux/amd64 --tag "$full_tag":"$image_version"-amd64 \
        --build-arg TARGETOS=linux \
        --build-arg TARGETARCH=amd64 .

    docker buildx build --push --platform linux/arm64 --tag "$full_tag":"$image_version"-arm64 \
        --build-arg TARGETOS=linux \
        --build-arg TARGETARCH=arm64 .

    docker manifest create "$full_tag":"$image_version" \
        --amend "$full_tag":"$image_version"-arm64 \
        --amend "$full_tag":"$image_version"-amd64

    docker manifest push --purge "$full_tag":"$image_version"

    docker manifest create "$full_tag":latest \
        --amend "$full_tag":"$image_version"-arm64 \
        --amend "$full_tag":"$image_version"-amd64

    docker manifest push --purge "$full_tag":latest
}

source image_versions.env

read -p "Registry (e.g. registry.gitlab.com, or leave empty to use Docker Hub): " registry
read -p "Project (e.g. openfaas-functions, or leave empty when using Docker Hub): " project
read -p "User: " user_registry
select image_tag in hello-world payload-echo img-classifier-hub fig-go payload-echo-workflow sentiment-analysis fake-news-train 
do  
    case $image_tag in
		hello-world)
			image_version=$hello_world_version
			;;
		payload-echo)
			image_version=$payload_echo_version	
			;;
		img-classifier-hub) 
			image_version=$img_classifier_hub_version							    
			;;		
		fig-go) 
			image_version=$fig_go_version									
			;;		
		payload-echo-workflow)
			image_version=$payload_echo_workflow_version									
			;;
		sentiment-analysis)
			image_version=$sentiment_analysis_version							
			;;		
		fake-news-train)
			image_version=$fake_news_train_version							
			;;
		*)		
			echo "Error: Please try again (select 1..7)!"
			;;		
	esac
    echo "Image tag selected $image_tag:$image_version"
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
    echo "The image tag to build and push is: $full_tag:$image_version"
    read -r -p "Are You Sure? [Y/n] " input
    case $input in
    [yY][eE][sS] | [yY])
        cd $image_tag || exit
        if [ "$image_tag" = "img-classifier-hub" ]; then
            source build_specific.sh
        else
            build_generic_image
        fi
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
