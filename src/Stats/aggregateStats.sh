#!/usr/bin/env bash

# @description aggregate number of skip/error/... log messages
# and export the result in aggregateStatFile
# @arg $1 statFile:String the current stat file to add to aggregateStatFile
# @arg $2 aggregateStatFile:String the file in which aggregated
# if it doesn't exist, the file is created with needed variables set to 0
# stats will be saved
Stats::aggregateStats() {
  local statFile="$1"
  local aggregateStatFile="$2"

  (
    if [[ ! -f "${aggregateStatFile}" ]]; then
      (
        echo "count=0"
        echo "appCount=0"
        echo "error=0"
        echo "warning=0"
        echo "skipped=0"
        echo "help=0"
        echo "success=0"
        echo "duration=0"
        echo "statusSuccess=0"
      ) >"${aggregateStatFile}"
    fi

    # shellcheck source=src/Stats/logStats.example
    if [[ -f "${statFile}" ]]; then
      source "${statFile}"
    fi
    local newError="${error}"
    local newWarning="${warning}"
    local newSkipped="${skipped}"
    local newHelp="${help}"
    local newSuccess="${success}"
    local newDuration="${duration}"
    local newStatus="${status}"
    # shellcheck source=src/Stats/aggregateStats.example
    source "${aggregateStatFile}"
    if [[ -f "${statFile}" ]]; then
      ((count++)) || true
      ((appCount++)) || true
      if ((newStatus == 0)); then
        ((statusSuccess++)) || true
      fi
      if ((newError > 0)); then
        ((error++)) || true
      fi
      if ((newWarning > 0)); then
        ((warning++)) || true
      fi
      if ((newSkipped > 0)); then
        ((skipped++)) || true
      fi
      if ((newHelp > 0)); then
        ((help++)) || true
      fi
      if ((newSuccess > 0)); then
        ((success++)) || true
      fi
      ((duration = duration + newDuration)) || true
    fi
    (
      echo "count=${count}"
      echo "appCount=${appCount}"
      echo "error=${error}"
      echo "warning=${warning}"
      echo "skipped=${skipped}"
      echo "help=${help}"
      echo "success=${success}"
      echo "duration=${duration}"
      echo "statusSuccess=${statusSuccess}"
    ) >"${aggregateStatFile}"
  )
}
