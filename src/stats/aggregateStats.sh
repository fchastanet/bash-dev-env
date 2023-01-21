#!/usr/bin/env bash

stats::aggregateStats() {
  local statFile="$1"
  local aggregateStatFile="$2"

  (
    if [[ ! -f "${aggregateStatFile}" ]]; then
      (
        echo "count=0"
        echo "error=0"
        echo "warning=0"
        echo "skipped=0"
        echo "help=0"
        echo "success=0"
        echo "duration=0"
        echo "statusSuccess=0"
      ) >"${aggregateStatFile}"
    fi
    if [[ ! -f "${statFile}" ]]; then
      return 0
    fi

    # shellcheck source=src/stats/logStats.example
    source "${statFile}"
    local newError="${error}"
    local newWarning="${warning}"
    local newSkipped="${skipped}"
    local newHelp="${help}"
    local newSuccess="${success}"
    local newDuration="${duration}"
    local newStatus="${status}"

    # shellcheck source=src/stats/aggregateStats.example
    source "${aggregateStatFile}"

    ((count++)) || true
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
    (
      echo "count=${count}"
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
