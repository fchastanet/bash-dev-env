#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalContainerArg="mongo"

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalUserArg="${userArg:-root}"

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalCommandArg=(mongo collection -u user1 -p user1pass --authenticationDatabase authDatabase)
