#!/bin/bash

red=$( tput setaf 1 )
green=$( tput setaf 2 )
reset=$( tput sgr0 )

DOCKER_REMOTE_REPOSITORY=069343908751.dkr.ecr.ap-northeast-2.amazonaws.com
VERSION=$(cat package.json | jq '.version' | tr -d '"')v
REGION=ap-northeast-2
PROFILE=damin
IMAGE_NAME=repo-dev

echo -n "${green} Please type a version update type {major, minor, patch}: "
read UPDATE_TYPE

[[ "$UPDATE_TYPE" =~ ^(major|minor|patch)$ ]] || { echo "${red} Please Type One of {major, minor, patch}"; exit 1; } 

aws ecr get-login-password --region $REGION --profile $PROFILE | docker login --username AWS --password-stdin $DOCKER_REMOTE_REPOSITORY

docker build -t $IMAGE_NAME:$VERSION --build-arg NODE_ENV=dev .
docker tag $IMAGE_NAME:$VERSION $DOCKER_REMOTE_REPOSITORY/$IMAGE_NAME:$VERSION
docker push $DOCKER_REMOTE_REPOSITORY/$IMAGE_NAME:$VERSION 2>error.log

REMOTE_VERSION=$(aws ecr describe-images --repository-name repo-dev --profile damin --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' | tr -d '"')

if [ $REMOTE_VERSION != $VERSION ] || [ -s "./error.log" ]
then
    echo "${red}Newly Pushed Image Digest Not Changed Or Package Version Not Updated"
    echo "Remote Version: $REMOTE_VERSION, Pushed Version: $VERSION, See error.log If Exists"
    for i in `seq 0 5` 
    do
        echo "${red}FAILED"
    done
else
    echo "${green}Docker Image Pushed Successfully"
fi

rm error.log 2> /dev/null