#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

makeTargetsCompletion() {
  if [[ -r Makefile ]]; then
    grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' Makefile | sed 's/[^a-zA-Z0-9_-]*$//'
  else
    (echo >&2 -n "no Makefile")
    return 1
  fi
}
complete -W "\`makeTargetsCompletion\`" make
