#!/usr/bin/env bash
#
# Push build docker images to dockerhub

set -uo pipefail
IFS=$'\n\t'

info() {
  printf "%s\n" "$@"
}

fatal() {
  printf "**********\n"
  printf "%s\n" "$@"
  printf "**********\n"
  exit 1
}

docker login -e "$DOCKER_EMAIL" -u "$DOCKER_USER" -p "$DOCKER_PASS"

cd $(cd ${0%/*} && pwd -P);

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
  versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
  if [[ "$version" == "docs" ]]; then
    continue
  fi

  tag=$(cat $version/Dockerfile | grep "ENV NODE_VERSION" | awk '{split($2,a,"=");print a[2]}')

  info "Pushing $tag..."
  docker push urbanmassage/node:$tag


  variants=$(ls -d $version/*/ | awk -F"/" '{print $2}')
  for variant in $variants; do
    info "Pushing $tag-$variant..."
    docker push urbanmassage/node:$tag-$variant
    info "Completed push for $tag-$variant"
  done

done

info "All builds successful!"

exit 0
