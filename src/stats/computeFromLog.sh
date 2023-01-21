#!/usr/bin/env bash

stats::computeFromLog() {
  local logFile="$1"
  local status="$2"
  local duration="$3"

  local logStatsAwkScript
  logStatsAwkScript="$(
    cat <<'EOF'
.INCLUDE "${TEMPLATE_DIR}/stats/logStats.awk"
EOF
  )"

  if [[ -f "${logFile}" ]]; then
    awk --source "${logStatsAwkScript}" "${logFile}"
    echo "status=${status}"
    echo "duration=${duration}"
  else
    # not executed
    echo "status=-1"
  fi
}
