#!/bin/bash

# @description check if function is empty
# @arg $1 function:Function
# @exitcode 0 if function is considered empty (body with : or true)
InstallScripts::scriptFunctionEmpty() {
  local pattern="^[ \t]+(:|true)"
  if ! declare -f "$1" &>/dev/null; then
    return 0
  fi
  local functionBody
  functionBody=$(declare -f "$1")
  local line3 line4
  line3=$(sed '3q;d' <<<"${functionBody}")
  line4=$(sed '4q;d' <<<"${functionBody}")
  [[ "${line3}" =~ ${pattern} && "${line4}" = "}" ]]
}
