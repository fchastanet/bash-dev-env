#!/usr/bin/env sh

export DOCKER_HOST='unix:///var/run/docker.sock'
# enable docker build kit
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain
