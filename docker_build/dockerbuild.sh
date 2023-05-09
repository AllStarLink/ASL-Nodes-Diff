#!/bin/bash

set -e

while [[ $# -gt 0 ]]; do
  case $1 in
    -o|--operating-system)
      $OPERATINGSYSTEM=$2
      shift
      shift
      ;;
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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PDIR=$(dirname $DIR)

if [ -z "$OPERATINGSYSTEM" ]; then
  OPERATINGSYSTEM=buster
fi

DPKG_BUILDOPTS="-b -uc -us"
docker build -f $DIR/Dockerfile -t asl-nodes-diff_builder --build-arg OS=$OPERATINGSYSTEM --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) $DIR
docker run -v $PDIR:/src -e DPKG_BUILDOPTS="$DPKG_BUILDOPTS" -e COMMIT_VERSIONING="$COMMIT_VERSIONING" asl-nodes-diff_builder
docker image rm --force asl-nodes-diff_builder
