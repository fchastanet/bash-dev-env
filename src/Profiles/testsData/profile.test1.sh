#!/usr/bin/env bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# profile to be used with configure
# create your own profile and comment the configuration you want to skip

CONFIG_LIST+=(
  Install1.sh # depends on Install4
  Install2.sh
  Install4.sh # depends on Install2 and Install3
)
