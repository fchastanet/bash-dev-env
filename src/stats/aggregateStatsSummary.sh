#!/usr/bin/env bash

stats::aggregateStatsSummary() {
  local msg="$1"
  local aggregateStatFile="$2"
  local appCount="$3"
  if [[ ! -f "${aggregateStatFile}" ]]; then
    return 0
  fi

  (
    # shellcheck source=src/stats/aggregateStats.example
    source "${aggregateStatFile}"

    echo -e "${__SUCCESS_COLOR}${count}${__RESET_COLOR} / ${__INFO_COLOR}${appCount}${__RESET_COLOR} ${msg} executed"
    echo -e " - ${__ERROR_COLOR}${error} ${msg} with error${__RESET_COLOR}"
    echo -e " - ${__SKIPPED_COLOR}${skipped} partial ${msg} (check logs marked as skipped)${__RESET_COLOR}"
    echo -e " - ${__WARNING_COLOR}${warning} ${msg} with warning${__RESET_COLOR}"
    echo -e " - ${__INFO_COLOR}Duration: ${duration}s${__RESET_COLOR}"
  )
}
