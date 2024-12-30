#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# in order to log in to aws ecr - private docker registry
if command -v aws &>/dev/null; then
  alias aws-docker-login='aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin ${AWS_DEFAULT_DOCKER_REGISTRY_ID}'
fi
