#!/bin/bash

# @description trap function responsible to compute and display stats after each script execution
# @arg $1 status:int
# @arg $2 logFile:String
# @arg $3 statFile:String
# @arg $4 startDate:String date at which log started
Stats::computeStatsTrap() {
  local status="$1"
  local logFile="$2"
  local statFile="$3"
  local startDate="$4"
  local endDate
  endDate="$(date +%s)"
  Stats::computeFromLog "${logFile}" "${status}" "$((endDate - startDate))" >"${statFile}"
  return "${status}"
}
