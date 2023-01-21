#!/usr/bin/env bash

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

SCRIPT="<% ${SCRIPT} %>"

# we need non root user to be sure that all variables will be correctly deduced
Assert::expectNonRootUser

showHelp() {
  # shellcheck disable=SC2154,SC2086
  engine::installScript::showHelp \
    "$("installScripts_${SCRIPT}_helpDescription")" \
    "$("installScripts_${SCRIPT}_helpVariables")" \
    "$("installScripts_${SCRIPT}_dependencies")"
}

.INCLUDE "${TEMPLATE_DIR}/installScripts/definitions/${SCRIPT}.sh"

# parse options
.INCLUDE "${TEMPLATE_DIR}/engine/installScript/_optionsParse.sh"

.INCLUDE "${TEMPLATE_DIR}/engine/config/load.sh"

rm -f "${CONFIG_LOGS_DIR}/${SCRIPT}-.*" || true

# shellcheck disable=SC2317
computeStats() {
  local status="$?"
  local step="$1"
  local logFile="$2"
  local statFile="$3"
  local END
  END="$(date +%s)"
  stats::computeFromLog "${logFile}" "${status}" "$((END - START))" >"${statFile}"
  stats::statusLine "${statFile}" "${step}"
  return "${status}"
}

onInterrupt() {
  Log::displayError "${SCRIPT} aborted"
  exit 1
}
trap 'onInterrupt' INT TERM ABRT

declare installStatus="0"
if [[ "${SKIP_INSTALL}" = "0" ]]; then
  Log::headLine "INSTALL - Installing ${SCRIPT}"
  installLogFile="${CONFIG_LOGS_DIR}/${SCRIPT}-install.log"
  installStatsFile="${CONFIG_LOGS_DIR}/${SCRIPT}-install.stat"

  (
    declare START
    START="$(date +%s)"
    trap 'computeStats "Installation ${SCRIPT}" "${installLogFile}" "${installStatsFile}"' EXIT INT TERM ABRT

    "installScripts_${SCRIPT}_install" 2>&1 | tee "${installLogFile}"
  ) || installStatus="$?" || true
  if [[ "${installStatus}" != "0" ]]; then
    # break at first install error
    exit "${installStatus}"
  fi
fi

declare configStatus="0"
if [[ "${SKIP_CONFIGURE}" = "0" && "${installStatus}" = "0" ]]; then
  Log::headLine "CONFIG  - Configuring ${SCRIPT}"
  configLogFile="${CONFIG_LOGS_DIR}/${SCRIPT}-config.log"
  configStatsFile="${CONFIG_LOGS_DIR}/${SCRIPT}-config.stat"
  (
    declare START
    START="$(date +%s)"
    trap 'computeStats "Configuration ${SCRIPT}" "${configLogFile}" "${configStatsFile}"' EXIT INT TERM ABRT

    "installScripts_${SCRIPT}_configure" 2>&1 | tee "${configLogFile}"
  ) || configStatus="$?" || true

  if [[ "${configStatus}" != "0" ]] && "installScripts_${SCRIPT}_breakOnConfigFailure"; then
    # break if config script error
    exit "${configStatus}"
  fi
fi

declare testStatus="0"
if [[ "${SKIP_TEST}" = "0" && "${installStatus}" = "0" && "${configStatus}" = "0" ]]; then
  Log::headLine "TEST    - Testing ${SCRIPT}"
  testLogFile="${CONFIG_LOGS_DIR}/${SCRIPT}-test.log"
  testStatsFile="${CONFIG_LOGS_DIR}/${SCRIPT}-test.stat"
  (
    declare START
    START="$(date +%s)"
    trap 'computeStats "Test ${SCRIPT}" "${testLogFile}" "${testStatsFile}"' EXIT INT TERM ABRT

    "installScripts_${SCRIPT}_test" 2>&1 | tee "${testLogFile}"
  ) || testStatus="$?" || true
  if [[ "${testStatus}" != "0" ]] && "installScripts_${SCRIPT}_breakOnTestFailure"; then
    # break if test script error
    exit "${testStatus}"
  fi
fi
