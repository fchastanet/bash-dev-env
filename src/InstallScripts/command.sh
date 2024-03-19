#!/bin/bash

# @description the command launch different actions(install, configure, test)
# depending on the options selected
# @see src/_includes/install.default.options.tpl
# @env SKIP_INSTALL
# @env SKIP_CONFIGURE
# @env SKIP_TEST
# @env LOGS_DIR
InstallScripts::command() {
  local logsDir="${LOGS_DIR:-#}"
  local scriptName
  scriptName="$(scriptName)"
  rm -f "${logsDir}/${scriptName}-.*" || true

  # shellcheck disable=SC2317
  onInterrupt() {
    Log::displayError "${scriptName} aborted"
    exit 1
  }
  trap onInterrupt INT TERM ABRT

  local startDate logFile statsFile
  local installStatus="0"
  if [[ "${SKIP_INSTALL}" = "0" ]]; then
    Log::headLine "INSTALL - Installing ${scriptName}"
    logFile="${logsDir}/${scriptName}-install.log"
    statsFile="${logsDir}/${scriptName}-install.stat"

    # break at first install error
    (
      startDate="$(date +%s)"
      trap 'Stats::computeStatsTrap "Installation ${scriptName}" "${logFile}" "${statsFile}" "${startDate}"' EXIT INT TERM ABRT

      install 2>&1 | tee "${logFile}"
    )
  fi

  local configStatus="0"
  if [[ "${SKIP_CONFIGURE}" = "0" && "${installStatus}" = "0" ]]; then
    Log::headLine "CONFIG  - Configuring ${scriptName}"
    logFile="${logsDir}/${scriptName}-config.log"
    statsFile="${logsDir}/${scriptName}-config.stat"
    (
      startDate="$(date +%s)"
      trap 'Stats::computeStatsTrap "Configuration ${scriptName}" "${logFile}" "${statsFile}" "${startDate}"' EXIT INT TERM ABRT

      configure 2>&1 | tee "${logFile}"
    ) || configStatus="$?" || true

    if [[ "${configStatus}" != "0" ]] && breakOnConfigFailure; then
      # break if config script error
      exit "${configStatus}"
    fi
  fi

  local testInstallStatus="0"
  if [[ "${SKIP_TEST}" = "0" && "${installStatus}" = "0" ]]; then
    Log::headLine "TEST    - Testing ${scriptName} installation"
    logFile="${logsDir}/${scriptName}-test-install.log"
    statsFile="${logsDir}/${scriptName}-test-install.stat"
    (
      startDate="$(date +%s)"
      trap 'Stats::computeStatsTrap "Test ${scriptName}" "${logFile}" "${statsFile}" "${startDate}"' EXIT INT TERM ABRT

      testInstall 2>&1 | tee "${logFile}"
    ) || testInstallStatus="$?" || true
    if [[ "${testInstallStatus}" != "0" ]] && breakOnTestFailure; then
      # break if test script error
      exit "${testInstallStatus}"
    fi
  fi

  local testConfigStatus="0"
  if [[ "${SKIP_TEST}" = "0" && "${installStatus}" = "0" && "${configStatus}" = "0" ]]; then
    Log::headLine "TEST    - Testing ${scriptName} configuration"
    logFile="${logsDir}/${scriptName}-test-configuration.log"
    statsFile="${logsDir}/${scriptName}-test-configuration.stat"
    (
      startDate="$(date +%s)"
      trap 'Stats::computeStatsTrap "Test ${scriptName}" "${logFile}" "${statsFile}" "${startDate}"' EXIT INT TERM ABRT

      testConfigure 2>&1 | tee "${logFile}"
    ) || testConfigStatus="$?" || true
    if [[ "${testConfigStatus}" != "0" ]] && breakOnTestFailure; then
      # break if test script error
      exit "${testConfigStatus}"
    fi
  fi
}