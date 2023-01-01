#!/bin/bash

set -e

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--commit-versioning)
      COMMIT_VERSIONING=YES
      shift
      ;;
    -*|--*|*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

A="amd64"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PDIR=$(dirname $DIR)

DPKG_BUILDOPTS="-b -uc -us"
docker build -f $DIR/Dockerfile.$A -t asl-nodes-diff_builder.$A --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) $DIR
docker run -v $PDIR:/src -e DPKG_BUILDOPTS="$DPKG_BUILDOPTS" asl-nodes-diff_builder.$A
docker image rm --force asl-nodes-diff_builder.$A
