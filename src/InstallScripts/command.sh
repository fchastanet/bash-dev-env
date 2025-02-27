#!/bin/bash

# @description the command launch different actions(install, configure, test)
# depending on the options selected
# @env SKIP_INSTALL
# @env SKIP_CONFIGURE
# @env SKIP_TEST
# @env STATS_DIR
# @env LOGS_INSTALL_SCRIPTS_DIR
InstallScripts::command() {
  local logsDir="${LOGS_INSTALL_SCRIPTS_DIR:-#}"
  local statsDir="${STATS_DIR:-#}"
  local fullScriptName
  fullScriptName="$(fullScriptName)"
  local scriptName="${fullScriptName//\//@}"
  rm -f "${statsDir}/${scriptName}-"* || true

  # shellcheck disable=SC2317
  onInterrupt() {
    Log::displayError "${scriptName} aborted"
    exit 1
  }
  trap onInterrupt INT TERM ABRT

  local startDate logFile statsFile
  local installStatus="0"
  sourceHook() {
    local hookName="$1"
    local configDir
    # shellcheck disable=SC2154
    local -a overriddenDirs=()
    # shellcheck disable=SC2154
    if [[ -d "${embed_dir_hooks_dir}" ]]; then
      overriddenDirs+=("${embed_dir_hooks_dir}")
    fi
    local dir
    for dir in "${CONF_OVERRIDE_DIRS[@]}"; do
      overriddenDirs+=("${dir}/${scriptName//\//@}")
    done
    configDir="$(Conf::getOverriddenDir "${overriddenDirs[@]}")" || return 0

    # ensure necessary functions are imported
    # Assert::dirExists
    # Assert::fileExists
    hook="${configDir}/${hookName}.sh"
    if [[ -n "${hook}" && -f "${hook}" && -x "${hook}" ]]; then
      Log::displayInfo "Running hook ${hook}"
      # shellcheck source=src/_installScripts/_Defaults/SimpleTest-hooks/preInstall.sh
      source "${hook}" || {
        Log::displayError "${scriptName} - unable to load hook '${hook}'"
        exit 1
      }
    fi
  }
  local globalStatsFile="${statsDir}/${scriptName}-global.stat"
  local hook
  if [[ "${SKIP_INSTALL}" = "0" ]] && ! InstallScripts::scriptFunctionEmpty install; then
    LOG_CONTEXT="${scriptName} - " Log::headLine "INSTALL" "Installing ${scriptName}"
    logFile="${logsDir}/${scriptName}-install.log"
    statsFile="${statsDir}/${scriptName}-install.stat"

    # break at first install error
    (
      startDate="$(date +%s)"
      # shellcheck disable=SC2317
      computeStats() {
        local rc=$1
        LOG_CONTEXT="${scriptName} - " Stats::statusLine "${statsFile}" "Installation"
        Stats::computeFromLog \
          "${logFile}" "${rc}" "${statsFile}" "${startDate}"
        Stats::aggregateGlobalStats \
          "${globalStatsFile}" "1" "${statsFile}"
        exit "${rc}"
      }
      trap 'computeStats "$?"' EXIT INT TERM ABRT

      local -i failures=0
      sourceHook preInstall || ((++failures))
      install || ((++failures))
      sourceHook postInstall || ((++failures))
      exit "${failures}"
    ) 2>&1 | tee "${logFile}"
  fi

  local testInstallStatus="0"
  if [[ "${SKIP_TEST}" = "0" && "${installStatus}" = "0" ]] &&
    ! InstallScripts::scriptFunctionEmpty testInstall; then
    Log::headLine "TEST" "Testing ${scriptName} installation"
    logFile="${logsDir}/${scriptName}-test-install.log"
    statsFile="${statsDir}/${scriptName}-test-install.stat"
    (
      startDate="$(date +%s)"
      # shellcheck disable=SC2317
      computeStats() {
        local rc=$1
        Stats::statusLine "${statsFile}" "Test Install ${scriptName}"
        Stats::computeFromLog \
          "${logFile}" "${rc}" "${statsFile}" "${startDate}"
        Stats::aggregateGlobalStats \
          "${globalStatsFile}" "1" "${statsFile}"
        exit "${rc}"
      }
      trap 'computeStats "$?"' EXIT INT TERM ABRT

      local -i failures=0
      sourceHook preTestInstall || ((++failures))
      testInstall || ((++failures))
      sourceHook postTestInstall || ((++failures))
      exit "${failures}"
    ) 2>&1 | tee "${logFile}" || testInstallStatus="$?" || true
    if [[ "${testInstallStatus}" != "0" ]] && breakOnTestFailure; then
      # break if test script error
      exit "${testInstallStatus}"
    fi
  fi

  local configStatus="0"
  if [[ "${SKIP_CONFIGURE}" = "0" && "${installStatus}" = "0" ]] &&
    ! InstallScripts::scriptFunctionEmpty configure; then
    Log::headLine "CONFIG" "Configuring ${scriptName}"
    logFile="${logsDir}/${scriptName}-config.log"
    statsFile="${statsDir}/${scriptName}-config.stat"
    (
      startDate="$(date +%s)"
      # shellcheck disable=SC2317
      computeStats() {
        local rc=$1
        Stats::statusLine "${statsFile}" "Configuration ${scriptName}"
        Stats::computeFromLog \
          "${logFile}" "${rc}" "${statsFile}" "${startDate}"
        Stats::aggregateGlobalStats \
          "${globalStatsFile}" "1" "${statsFile}"
        exit "${rc}"
      }
      trap 'computeStats "$?"' EXIT INT TERM ABRT

      local -i failures=0
      sourceHook preConfigure || ((++failures))
      configure || ((++failures))
      sourceHook postConfigure || ((++failures))
      exit "${failures}"
    ) 2>&1 | tee "${logFile}" || configStatus="$?" || true

    if [[ "${configStatus}" != "0" ]] && breakOnConfigFailure; then
      # break if config script error
      exit "${configStatus}"
    fi
  fi

  local testConfigStatus="0"
  if [[ "${SKIP_TEST}" = "0" && "${installStatus}" = "0" && "${configStatus}" = "0" ]] &&
    ! InstallScripts::scriptFunctionEmpty configure; then
    Log::headLine "TEST" "Testing ${scriptName} configuration"
    logFile="${logsDir}/${scriptName}-test-configuration.log"
    statsFile="${statsDir}/${scriptName}-test-configuration.stat"
    (
      startDate="$(date +%s)"
      # shellcheck disable=SC2317
      computeStats() {
        local rc=$1
        Stats::statusLine "${statsFile}" "Test Configuration ${scriptName}"
        Stats::computeFromLog \
          "${logFile}" "${rc}" "${statsFile}" "${startDate}"
        Stats::aggregateGlobalStats \
          "${globalStatsFile}" "1" "${statsFile}"
        exit "${rc}"
      }
      trap 'computeStats "$?"' EXIT INT TERM ABRT

      local -i failures=0
      sourceHook preTestConfigure || ((++failures))
      testConfigure || ((++failures))
      sourceHook postTestConfigure || ((++failures))
      exit "${failures}"
    ) 2>&1 | tee "${logFile}" || testConfigStatus="$?" || true
    if [[ "${testConfigStatus}" != "0" ]] && breakOnTestFailure; then
      # break if test script error
      exit "${testConfigStatus}"
    fi
  fi

  local cleanBeforeExportStatus="0"
  if [[ "${PREPARE_EXPORT}" = "1" && "${installStatus}" = "0" ]] &&
    ! InstallScripts::scriptFunctionEmpty cleanBeforeExport; then
    Log::headLine "CLEAN" "Cleaning ${scriptName}"
    logFile="${logsDir}/${scriptName}-clean-before-export.log"
    statsFile="${statsDir}/${scriptName}-clean-before-export.stat"
    (
      startDate="$(date +%s)"
      # shellcheck disable=SC2317
      computeStats() {
        local rc=$1
        Stats::statusLine "${statsFile}" "Cleaning ${scriptName}"
        Stats::computeFromLog \
          "${logFile}" "${rc}" "${statsFile}" "${startDate}"
        Stats::aggregateGlobalStats \
          "${globalStatsFile}" "1" "${statsFile}"
        exit "${rc}"
      }
      trap 'computeStats "$?"' EXIT INT TERM ABRT

      local -i failures=0
      if ! InstallScripts::scriptFunctionEmpty cleanBeforeExport; then
        cleanBeforeExport || ((++failures))
        if [[ "${failures}" = "0" ]] && ! InstallScripts::scriptFunctionEmpty testCleanBeforeExport; then
          testCleanBeforeExport || ((++failures))
        fi
      fi
      exit "${failures}"
    ) 2>&1 | tee "${logFile}" || cleanBeforeExportStatus="$?" || true

    if [[ "${cleanBeforeExportStatus}" != "0" ]]; then
      # break if config script error
      exit "${cleanBeforeExportStatus}"
    fi
  fi
}
