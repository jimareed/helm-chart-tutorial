#!/usr/bin/env sh

# Purpose: This script builds the Docker image.
# Instructions: make build-docker <IMAGE> <TAG> <DOCKERFILE>

set -eu

IMAGE="$1"
TAG="$2"
DOCKERFILE="$3"
BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
REV=`git rev-parse HEAD 2>/dev/null`

docker build --tag "$IMAGE":"$TAG" \
             --file "$DOCKERFILE" \
             --build-arg CREATED=$BUILD_DATE \
             --build-arg REVISION=$REV \
             --build-arg VERSION=$TAG \
            .
