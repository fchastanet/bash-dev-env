#!/bin/bash

# @description select right file to load depending if file exists in this order:
# - from conf.override
# - from embedded file if provided
# - from conf dir
# @arg $1 file:String
# @arg $2 embedFile:String eventual embedded file
# @exitcode 1 if file does not exist at all
Conf::dynamicConfFile() {
  local file="${1/#\//}" # remove first slash if any
  local embedFile="${2:-}"
  if [[ -f "${CONF_OVERRIDE_DIR}/${file}" ]]; then
    echo "${CONF_OVERRIDE_DIR}/${file}"
    return 0
  elif [[ -f "${embedFile}" ]]; then
    echo "${embedFile}"
    return 0
  elif [[ -f "${CONF_DIR}/${file}" ]]; then
    echo "${CONF_DIR}/${file}"
    return 0
  fi
  if [[ "${IGNORE_ERROR:-0}" = "0" ]]; then
    Log::displayWarning "Conf::dynamicConfFile - ${file} does not exist in any config dirs declared"
    return 1
  fi
}
