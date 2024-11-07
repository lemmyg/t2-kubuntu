#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE=ubuntu:24.04
ISO_IMAGE=$(pwd)/Downloads/kubuntu-24.10-desktop-amd64.iso
docker pull ${DOCKER_IMAGE}
docker run \
  --privileged \
  --rm \
  -t \
  -v "$(pwd)":/repo \
  -v "$ISO_IMAGE:$ISO_IMAGE:ro" \
  -e ISO_IMAGE="$ISO_IMAGE" \
  ${DOCKER_IMAGE} \
  /bin/bash -c 'cd /repo && ./build.sh'
