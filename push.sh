#!/usr/bin/env bash
#
# Push build docker images to dockerhub

set -e

docker login -e "$DOCKER_EMAIL" -u "$DOCKER_USER" -p "$DOCKER_PASS"

echo "About to start push"
docker push urbanmassage/node
echo "Completed push"
