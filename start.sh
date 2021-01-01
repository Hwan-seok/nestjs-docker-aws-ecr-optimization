#!/bin/bash

red=$( tput setaf 1 )
green=$( tput setaf 2 )
reset=$( tput sgr0 )

DOCKER_REMOTE_REPOSITORY=552560817422.dkr.ecr.ap-northeast-2.amazonaws.com
VERSION=$(cat package.json | jq '.version' | tr -d '"')
REGION=ap-northeast-2
PROFILE=terraform
REPOSITORY_NAME=repo
ERROR_FILE_NAME=error.log

echo -n "${green} Please type a build stage {dev, stage, real}}: "
read BUILD_STAGE

[[ "$BUILD_STAGE" =~ ^(dev|stage|real)$ ]] || { echo "${red} Please Type Appropriate Stage}"; exit 1; } 

echo -n "${green} Please type a version update type {major, minor, patch or implicit version (ex. 1.0.0-1) (current: $VERSION)}: "
read UPDATE_TYPE

[[ "$UPDATE_TYPE" =~ ^(major|minor|patch|[0-9]+\.[0-9]+\.[0-9]+(-[0-9]+)?)$ ]] || { echo "${red} Please Type Appropriate Version}"; exit 1; } 

IMAGE_VERSION=$BUILD_STAGE-$VERSION

npm version $UPDATE_TYPE -no-git-tag-version

aws ecr get-login-password --region $REGION --profile $PROFILE | docker login --username AWS --password-stdin $DOCKER_REMOTE_REPOSITORY

docker build -t $REPOSITORY_NAME:$IMAGE_VERSION --build-arg NODE_ENV=dev .
docker tag $REPOSITORY_NAME:$IMAGE_VERSION $DOCKER_REMOTE_REPOSITORY/$REPOSITORY_NAME:$IMAGE_VERSION
docker push $DOCKER_REMOTE_REPOSITORY/$REPOSITORY_NAME:$IMAGE_VERSION 2>$ERROR_FILE_NAME

REMOTE_VERSION=$(aws ecr describe-images --repository-name $REPOSITORY_NAME --profile $PROFILE --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags')
echo $REMOTE_VERSION | grep \"$IMAGE_VERSION\"

if [ $? = 1 ] || [ -s $ERROR_FILE_NAME ]
then
    echo "${red}Package Version Not Updated"
    echo "Remote Version: $REMOTE_VERSION, Pushed Version: $IMAGE_VERSION, See $ERROR_FILE_NAME If Exists"
    cat $ERROR_FILE_NAME
    for i in `seq 0 5` 
    do
        echo "${red}FAILED"
    done
else
    echo "${green}Docker Image Pushed Successfully"
fi
