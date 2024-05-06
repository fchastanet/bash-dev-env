#!/bin/bash

REAL_SCRIPT_FILE="$(readlink -e "$(realpath "${BASH_SOURCE[0]}")")"
CURRENT_DIR="${REAL_SCRIPT_FILE%/*}"
FRAMEWORK_ROOT_DIR="${CURRENT_DIR}/vendor/bash-tools-framework"

set -o errexit
set -o pipefail

declare image="$1"
shift || true

# build docker image
docker pull "${image}"
set -x
declare imageRefUser="${image}-user"
DOCKER_BUILDKIT=1 docker build \
  --cache-from "scrasnups/${image}" \
  --build-arg "BASH_IMAGE=${image}" \
  --build-arg SKIP_USER=0 \
  --build-arg USER_ID="${USER_ID:-$(id -u)}" \
  --build-arg GROUP_ID="${GROUP_ID:-$(id -g)}" \
  -f "${FRAMEWORK_ROOT_DIR}/.docker/DockerfileUser" \
  -t "${imageRefUser}" \
  "${FRAMEWORK_ROOT_DIR}/.docker"

# run docker image
declare -a localDockerRunArgs=(
  --rm
  -e KEEP_TEMP_FILES=0
  -e BATS_FIX_TEST=0
  -e USER_ID="1000"
  -e GROUP_ID="1000"
  --user "1000:1000"
  -w /bash
  -v "$(pwd):/bash"
  --entrypoint /usr/local/bin/bash
)
# shellcheck disable=SC2154
if [[ "${CI_MODE:-0}" = "0" ]]; then
  localDockerRunArgs+=(-v "/tmp:/tmp")
  localDockerRunArgs+=(-it)
fi
localDockerRunArgs+=(-e KEEP_TEMP_FILES="${KEEP_TEMP_FILES:-0}")
localDockerRunArgs+=(-e BATS_FIX_TEST="${BATS_FIX_TEST:-0}")

docker run \
  "${localDockerRunArgs[@]}" \
  "${imageRefUser}" \
  /bash/vendor/bash-tools-framework/vendor/bats/bin/bats \
  "$@"
