#!/bin/bash

# @description select right dir to load depending if dir exists in this order:
# - from conf.override
# - from embedded dir if provided
# - from conf dir
# @arg $1 dir:String
# @arg $2 embedDir:String eventual embedded dir
# @exitcode 1 if dir does not exist at all
Conf::dynamicConfDir() {
  local dir="${1/#\//}" # remove first slash if any
  local embedDir="${2:-}"
  if [[ -d "${CONF_OVERRIDE_DIR}/${dir}" ]]; then
    echo "${CONF_OVERRIDE_DIR}/${dir}"
    return 0
  elif [[ -d "${embedDir}" ]]; then
    echo "${embedDir}"
    return 0
  elif [[ -d "${CONF_DIR}/${dir}" ]]; then
    echo "${CONF_DIR}/${dir}"
    return 0
  fi
  Log::displayWarning "Conf::dynamicConfDir - ${dir} does not exist in any config dirs declared"
  return 1
}
