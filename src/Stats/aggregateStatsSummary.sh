#!/usr/bin/env bash

# @description display aggregated stats computed using Stats::aggregateStats
# @stdout aggregated stats report
Stats::aggregateStatsSummary() {
  local msg="$1"
  local aggregateStatFile="$2"
  if [[ ! -f "${aggregateStatFile}" ]]; then
    return 0
  fi

  (
    # shellcheck source=src/Stats/aggregateStats.example
    source "${aggregateStatFile}"

    echo -e "${__SUCCESS_COLOR}${count}${__RESET_COLOR} / ${__INFO_COLOR}${appCount}${__RESET_COLOR} ${msg} executed"
    if [[ "${error}" != "0" ]]; then
      echo -e " - ${__ERROR_COLOR}${error} ${msg} with error${__RESET_COLOR}"
    fi
    if [[ "${skipped}" != "0" ]]; then
      echo -e " - ${__SKIPPED_COLOR}${skipped} partial ${msg} (check logs marked as skipped)${__RESET_COLOR}"
    fi
    if [[ "${warning}" != "0" ]]; then
      echo -e " - ${__WARNING_COLOR}${warning} ${msg} with warning${__RESET_COLOR}"
    fi
    echo -e " - ${__INFO_COLOR}Duration: ${duration}s${__RESET_COLOR}"
  )
}
