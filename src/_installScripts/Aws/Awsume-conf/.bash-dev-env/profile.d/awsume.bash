#!/usr/bin/env bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

_awsume() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  # shellcheck disable=SC2034
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  opts=$(awsume-autocomplete)
  # shellcheck disable=SC2207,SC2086
  COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
  return 0
}
complete -F _awsume awsume
