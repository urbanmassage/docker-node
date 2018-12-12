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

# https://nodejs.org/dist/latest-v6.x/
# https://nodejs.org/dist/latest-v8.x/
# https://nodejs.org/dist/latest-v10.x/
versions=("6.15.1" "8.14.0" "10.14.2")
variants=("slim")

for version in "${versions[@]}"; do
  MINOR_VERSION=$(echo $version | awk '{split($0,b,".");print b[1]"."b[2]}')
  MAJOR_VERSION=$(echo $MINOR_VERSION | awk '{split($0,b,".");print b[1]}')

  for variant in $variants; do
    mkdir -p $version/$variant

    cat Dockerfile-template-$variant | sed 's/%%NODE_VERSION%%/'$version'/' > $version/$variant/Dockerfile

    info "Building $version-$variant variant..."
    docker build -q -t urbanmassage/node:$version-$variant $version/$variant
    docker tag urbanmassage/node:$version-$variant urbanmassage/node:$MINOR_VERSION-$variant

    if [ $MAJOR_VERSION != "0" ]; then
      docker tag urbanmassage/node:$version-$variant urbanmassage/node:$MAJOR_VERSION-$variant
    fi
    
    docker tag -f urbanmassage/node:$version-$variant urbanmassage/node:latest

    if [[ $? -gt 0 ]]; then
      fatal "Build of $version-$variant failed!"
    else
      info "Build of $version-$variant succeeded."
    fi

    OUTPUT=$(docker run --rm -it urbanmassage/node:$version-$variant node -e "process.stdout.write(process.versions.node)")
    if [ "$OUTPUT" != "$version" ]; then
      fatal "Test of $version-$variant failed!"
    else
      info "Test of $version-$variant succeeded."
    fi

  done

done

info "All builds successful!"

exit 0
