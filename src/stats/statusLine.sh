#!/usr/bin/env bash

stats::statusLine() {
  local statFile="$1"
  local msg="$2"
  if [[ ! -f "${statFile}" ]]; then
    return 0
  fi

  (
    # shellcheck source=src/stats/logStats.example
    source "${statFile}" || exit 1

    local color="${__TEST_ERROR_COLOR}"
    local statusMsg
    if [[ "${status}" = "0" ]]; then
      if [[ "${skipped}" = "0" ]]; then
        color="${__SUCCESS_COLOR}"
        statusMsg="SUCCESS - ${msg} successful"
      else
        color="${__SKIPPED_COLOR}"
        statusMsg="SKIPPED - ${msg} skipped"
      fi
    elif [[ "${status}" = "-1" ]]; then
      statusMsg="ABORTED - ${msg} not executed"
    else
      statusMsg="ERROR  - ${msg} in error"
    fi
    # overwrite final TEST line
    echo -e "${color}${statusMsg}${__RESET_COLOR}"
  )
}
