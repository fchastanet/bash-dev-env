#!/usr/bin/env bash

# @description extract stats form log
# @arg $1 logFile:String the log file to parse
# @arg $2 status:int the status of the command associated to that log file
# @arg $3 duration:int the duration  of the command associated to that log file
# @stdout output with the format provided by this example src/Stats/aggregateStats.example
# @see src/Stats/aggregateStats.example
Stats::computeFromLog() {
  local logFile="$1"
  local status="$2"
  local duration="$3"

  local logStatsAwkScript
  logStatsAwkScript="$(
    cat <<'EOF'
.INCLUDE "${TEMPLATE_DIR}/Stats/logStats.awk"
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
