#!/bin/bash

# @description install file from embedded variable
# @arg $1 prefixDir:String file prefix directory
# @arg $@ list of files to install
# @exitcode 1 if embedded file not found or copy error
Conf::installFromEmbed() {
  local prefixDir="$1"
  shift || true
  local -a files=("$@")
  for file in "${files[@]}"; do
    local fileToInstall
    local embedFileVar="embed_file_${file}"
    # shellcheck disable=SC2154
    fileToInstall="$(Conf::dynamicConfFile "${prefixDir}/.${file}" "${!embedFileVar}")" || return 1
    Install::file \
      "${fileToInstall}" "${USER_HOME}/.${file}" || return 1
  done
}
