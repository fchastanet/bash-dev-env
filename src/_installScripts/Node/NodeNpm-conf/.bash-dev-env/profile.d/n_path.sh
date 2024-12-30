#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

export N_PREFIX="${HOME}/n"
[[ :${PATH}: == *":${N_PREFIX}/bin:"* ]] || PATH="${N_PREFIX}/bin:${PATH}"
[[ :${PATH}: == *":${HOME}/.npm-global/bin:"* ]] || PATH="${HOME}/.npm-global/bin:${PATH}"

if command -v yarn &>/dev/null; then
  declare yarnPath
  yarnPath="$(yarn global bin)"
  [[ :${PATH}: == *":${yarnPath}:"* ]] || PATH="${yarnPath}:${PATH}"
fi

export PATH
