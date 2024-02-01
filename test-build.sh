#!/bin/bash
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

# https://nodejs.org/dist/latest-v12.x/
# https://nodejs.org/dist/latest-v14.x/
# https://nodejs.org/dist/latest-v16.x/
info "++ Build Node.js 12 to 16"
versions=("12.22.12" "14.21.3" "16.20.2")
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
    
    docker tag urbanmassage/node:$version-$variant urbanmassage/node:latest

    if [[ $? -gt 0 ]]; then
      fatal "Build of $version-$variant failed!"
    else
      info "Build of $version-$variant succeeded."
    fi

    OUTPUT=$(docker run --rm -it urbanmassage/node:$version-$variant node -e "process.stdout.write(process.versions.node)")
    if [[ $OUTPUT != *"$version"* ]]; then
      fatal "Test of $version-$variant failed with output $OUTPUT"
    else
      info "Test of $version-$variant succeeded."
    fi

  done

done



info "++ Build Node.js 18+"
versions=("18.19.0")
variants=("alpine3.19")

for version in "${versions[@]}"; do
  MINOR_VERSION=$(echo $version | awk '{split($0,b,".");print b[1]"."b[2]}')
  MAJOR_VERSION=$(echo $MINOR_VERSION | awk '{split($0,b,".");print b[1]}')

  # echo $MINOR_VERSION
  # echo $MAJOR_VERSION

  for variant in $variants; do
    mkdir -p $version/$variant

    cat Dockerfile-template-alpine | sed 's/NODE_VERSION/'$version'/'  | sed 's/VARIANT/'$variant'/' > $version/$variant/Dockerfile

    info "Building $version-$variant variant..."
    docker build -q -t urbanmassage/node:$version-$variant $version/$variant
    docker tag urbanmassage/node:$version-$variant urbanmassage/node:$MINOR_VERSION-$variant

    if [ $MAJOR_VERSION != "0" ]; then
      docker tag urbanmassage/node:$version-$variant urbanmassage/node:$MAJOR_VERSION-$variant
    fi
    
    docker tag urbanmassage/node:$version-$variant urbanmassage/node:$MINOR_VERSION-latest

    if [[ $? -gt 0 ]]; then
      fatal "Build of $version-$variant failed!"
    else
      info "Build of $version-$variant succeeded."
    fi

    OUTPUT=$(docker run --rm -it urbanmassage/node:$version-$variant node -e "process.stdout.write(process.versions.node)")
    echo "OUTPUT: ${OUTPUT}"
    if [[ $OUTPUT != *"$version"* ]]; then
      fatal "Test of $version-$variant failed with output $OUTPUT"
    else
      info "Test of $version-$variant succeeded."
    fi

  done

done


info "All builds successful!"

exit 0
