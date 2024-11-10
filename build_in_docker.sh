#!/bin/bash

set -eu -o pipefail

DOCKER_IMAGE=ubuntu:24.04
ISO_IMAGE=$(pwd)/Downloads/kubuntu-24.10-desktop-amd64.iso
ISO_WORK_DIR="$(pwd)/kubuntu-iso"
CHROOT_DIR="$(pwd)/kubuntu-edit"  
mkdir -p "$ISO_WORK_DIR"
mkdir -p "$CHROOT_DIR"
echo "DOCKER_IMAGE=${DOCKER_IMAGE}"
echo "ISO_IMAGE=${ISO_IMAGE}"
echo "ISO_WORK_DIR=${ISO_WORK_DIR}"
docker pull ${DOCKER_IMAGE}

docker run \
  --privileged \
  --rm \
  -t \
  -v "$(pwd)":/repo \
  -v "$ISO_IMAGE:$ISO_IMAGE:ro" \
  -v "$ISO_WORK_DIR:/iso_work_dir" \
  -v "$CHROOT_DIR:/chroot_dir" \
  -e ISO_IMAGE="$ISO_IMAGE" \
  -e ISO_WORK_DIR="/iso_work_dir" \
  -e CHROOT_DIR="/chroot_dir" \
  ${DOCKER_IMAGE} \
  /bin/bash -c 'cd /repo && ./build.sh'

