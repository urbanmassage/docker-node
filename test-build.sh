#!/usr/bin/env bash
#
# Run a test build for all images.

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

  NODE_VERSION=$(cat $version/Dockerfile | grep "ENV NODE_VERSION" | awk '{split($2,a,"=");print a[2]')
  MINOR_VERSION=$(echo $NODE_VERSION | awk '{split($0,b,".");print b[1]"."b[2]}')
  MAJOR_VERSION=$(echo $MINOR_VERSION | awk '{split($0,b,".");print b[1]}')

  variants=$(ls -d $version/*/ | awk -F"/" '{print $2}')

  for variant in $variants; do
    info "Building $NODE_VERSION-$variant variant..."
    docker build -q -t urbanmassage/node:$NODE_VERSION-$variant $version/$variant
    docker tag urbanmassage/node:$NODE_VERSION-$variant urbanmassage/node:$NODE_VERSION-$MINOR_VERSION

    if [ $MAJOR_VERSION != "0" ]; then
      docker tag urbanmassage/node:$NODE_VERSION-$variant urbanmassage/node:$NODE_VERSION-$MAJOR_VERSION
    fi

    if [[ $? -gt 0 ]]; then
      fatal "Build of $NODE_VERSION-$variant failed!"
    else
      info "Build of $NODE_VERSION-$variant succeeded."
    fi

    OUTPUT=$(docker run --rm -it urbanmassage/node:$NODE_VERSION-$variant node -e "process.stdout.write(process.versions.node)")
    if [ "$OUTPUT" != "$NODE_VERSION" ]; then
      fatal "Test of $tag-$variant failed!"
    else
      info "Test of $tag-$variant succeeded."
    fi

  done

done

info "All builds successful!"

exit 0
