#!/usr/bin/env bash

set -e

./.travis/compile-domain-list.sh

docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
export TAG=`if [ "$TRAVIS_BRANCH" == "master" ]; then echo "latest"; else echo $TRAVIS_BRANCH | tr / - ; fi`
docker build -t anroots/ee-domains:$TAG .

docker push anroots/ee-domains:$TAG
docker rmi anroots/ee-domains:$TAG

docker logout
