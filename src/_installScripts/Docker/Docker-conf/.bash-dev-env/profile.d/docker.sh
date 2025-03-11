#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

if command -v docker &>/dev/null; then
  export DOCKER_HOST='unix:///run/docker.sock'
  # enable docker build kit
  export DOCKER_BUILDKIT=1
  export BUILDKIT_PROGRESS=plain
  export COMPOSE_DOCKER_CLI_BUILD=true
  export COMPOSE_BAKE=true
fi
