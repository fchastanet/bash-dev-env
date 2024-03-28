#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalContainerArg="node"

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalUserArg="${userArg:-node}"

# we are using // to keep compatibility with "windows git bash"
# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalCommandArg=("${commandArg:-//bin/bash}")
