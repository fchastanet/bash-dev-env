#!/usr/bin/env bash

afterParseCallback

LOGS_DIR="${LOGS_DIR:-${PERSISTENT_TMPDIR}}"
# shellcheck disable=SC2034
INSTALL_START="$(date +%s)"
rm -f "${LOGS_DIR:-#}/${SCRIPT}-"* || true

# trap errors
err_report() {
  echo "$0 - Upgrade failure - Error on line $1"
  exit 1
}
# shellcheck disable=SC2016
trap 'err_report $LINENO' ERR

# shellcheck disable=SC2317
declare -g summaryDisplayed="0"
summary() {
  local installResultCode="$1"
  local startDate="$2"
  if [[ "${summaryDisplayed}" = "1" ]]; then
    return "${rc}"
  fi
  (
    Log::headLine "" "Important messages recapitulative"
    Stats::logRecapitulative "${LOGS_DIR}/lastInstallLogRecapitulative.log"

    Log::headLine "" "Summary"
    Stats::aggregateStatsSummary "software installation(s)" \
      "${STATS_DIR:-#}/global.stat"
    Log::headLine "" "Details"
    if [[ "${SKIP_INSTALL}" = "0" ]]; then
      Stats::aggregateStatsSummary "installation(s)" \
        "${STATS_DIR:-#}/install.stat"
    fi
    if [[ "${SKIP_TEST}" = "0" ]]; then
      Stats::aggregateStatsSummary "installation test(s)" \
        "${STATS_DIR:-#}/test-install.stat"
    fi
    if [[ "${SKIP_CONFIGURE}" = "0" ]]; then
      Stats::aggregateStatsSummary "configuration(s)" \
        "${STATS_DIR:-#}/config.stat"
    fi
    if [[ "${SKIP_TEST}" = "0" ]]; then
      Stats::aggregateStatsSummary "configuration test(s)" \
        "${STATS_DIR:-#}/test-configuration.stat"
    fi
    local endDate
    endDate="$(date +%s)"
    Log::displayInfo "Total duration: $((endDate - startDate))s"
    summaryDisplayed="1"
    if [[ "${installResultCode}" = "0" ]]; then
      Log::displaySuccess "Successful Installation"
    else
      Log::displayError "Aborted after ${currentConfigName} failure"
    fi
  ) | tee >(sed -r 's/\x1b\[[0-9;]*m//g' >>"${LOGS_DIR}/lastInstallSummary")
  (
    if [[ "${installResultCode}" = "0" ]]; then
      echo -e "${__SUCCESS_COLOR}Bash-dev-env installation success${__RESET_COLOR}"
    else
      echo -e "${__ERROR_COLOR}Bash-dev-env installation aborted after ${currentConfigName} failure${__RESET_COLOR}"
    fi
    echo "Last execution date: $(date)"
    echo "Command: ${SCRIPT_NAME} ${ORIGINAL_BASH_FRAMEWORK_ARGV[*]}"
    echo "From directory: ${BASH_DEV_ENV_ROOT_DIR}"
    echo "Logs path: ${LOGS_DIR}/lastInstall.log"
    if [[ "${installResultCode}" != "0" ]]; then
      cat "${LOGS_DIR}/lastInstallSummary"
    fi
  ) >"${LOGS_DIR:-#}/lastInstallStatus"
  Log::displayInfo "regenerating motd"
  sudo update-motd &>/dev/null || true
  rm -f "${HOME}/.motd_shown" &>/dev/null || true
  exit "${installResultCode}"
}
# shellcheck disable=SC2016
trap 'summary "$?" "${INSTALL_START}"' EXIT INT TERM ABRT

executeScript() {
  local configName="$1"
  local -a installCmd=(
    "${BASH_DEV_ENV_ROOT_DIR}/${configName}"
  )
  if [[ "${SKIP_INSTALL}" = "1" ]]; then
    installCmd+=(--skip-install)
  fi
  if [[ "${SKIP_CONFIGURE}" = "1" ]]; then
    installCmd+=(--skip-configure)
  fi
  if [[ "${SKIP_TEST}" = "1" ]]; then
    installCmd+=(--skip-test)
  fi
  if [[ -n "${PROFILE}" ]]; then
    installCmd+=(--profile "${PROFILE}")
  fi
  LOG_CONTEXT="${configName} - " "${installCmd[@]}"
}

declare -g currentConfigName="init"
executeScripts() {
  local -i configIndex=1
  local -i configCount=${#CONFIG_LIST[@]}

  # compute number of config for each step
  local -i installConfigCount=0
  local -i installTestConfigCount=0
  local -i configConfigCount=0
  local -i configTestConfigCount=0
  local configName
  local -i installScriptError=0
  for configName in "${CONFIG_LIST[@]}"; do
    if ! SKIP_REQUIRES=1 "${BASH_DEV_ENV_ROOT_DIR}/${configName}" isInterfaceImplemented; then
      ((++installScriptError))
    fi
    if [[ "${SKIP_INSTALL}" = "0" ]] &&
      SKIP_REQUIRES=1 "${BASH_DEV_ENV_ROOT_DIR}/${configName}" isInstallImplemented; then
      ((++installConfigCount))
    fi
    if [[ "${SKIP_CONFIGURE}" = "0" ]] &&
      SKIP_REQUIRES=1 "${BASH_DEV_ENV_ROOT_DIR}/${configName}" isConfigureImplemented; then
      ((++configConfigCount))
    fi
    if [[ "${SKIP_TEST}" = "0" ]]; then
      if SKIP_REQUIRES=1 "${BASH_DEV_ENV_ROOT_DIR}/${configName}" isTestInstallImplemented; then
        ((++installTestConfigCount))
      fi
      if SKIP_REQUIRES=1 "${BASH_DEV_ENV_ROOT_DIR}/${configName}" isTestConfigureImplemented; then
        ((++configTestConfigCount))
      fi
    fi
  done
  if ((installScriptError > 0)); then
    exit 1
  fi
  # shellcheck disable=SC2317
  for currentConfigName in "${CONFIG_LIST[@]}"; do
    (
      local installStatus="0"
      (
        aggregateStat() {
          local rc="$1"
          local -a statFiles=()
          local scriptName="${currentConfigName//\//@}"
          local scriptCmd="${BASH_DEV_ENV_ROOT_DIR}/${currentConfigName}"
          if [[ "${SKIP_INSTALL}" = "0" ]] &&
            SKIP_REQUIRES=1 "${scriptCmd}" isInstallImplemented; then
            Stats::aggregateStats \
              "${STATS_DIR:-#}/install.stat" \
              "${installConfigCount}" \
              "${STATS_DIR:-#}/${scriptName}-install.stat"
            statFiles+=("${STATS_DIR:-#}/${scriptName}-install.stat")
          fi
          if [[ "${SKIP_CONFIGURE}" = "0" ]] &&
            SKIP_REQUIRES=1 "${scriptCmd}" isConfigureImplemented; then
            Stats::aggregateStats \
              "${STATS_DIR:-#}/config.stat" \
              "${configConfigCount}" \
              "${STATS_DIR:-#}/${scriptName}-config.stat"
            statFiles+=("${STATS_DIR:-#}/${scriptName}-config.stat")
          fi
          if [[ "${SKIP_TEST}" = "0" ]]; then
            if SKIP_REQUIRES=1 "${scriptCmd}" isTestInstallImplemented; then
              Stats::aggregateStats \
                "${STATS_DIR:-#}/test-install.stat" \
                "${installTestConfigCount}" \
                "${STATS_DIR:-#}/${scriptName}-test-install.stat"
              statFiles+=("${STATS_DIR:-#}/${scriptName}-test-install.stat")
            fi
            if SKIP_REQUIRES=1 "${scriptCmd}" isTestConfigureImplemented; then
              Stats::aggregateStats \
                "${STATS_DIR:-#}/test-configuration.stat" \
                "${configTestConfigCount}" \
                "${STATS_DIR:-#}/${scriptName}-test-configuration.stat"
              statFiles+=("${STATS_DIR:-#}/${scriptName}-test-configuration.stat")
            fi
          fi
          Stats::aggregateGlobalStats \
            "${STATS_DIR:-#}/global.stat" \
            "${configCount}" \
            "${statFiles[@]}"
          exit "${rc}"
        }
        trap 'aggregateStat "$?"' EXIT INT TERM ABRT

        rm -f \
          "${STATS_DIR:-#}/${scriptName}"-{install,config,test-install,test-configuration,global,current}.stat \
          &>/dev/null || true

        UI::drawLineWithMsg "Installing ${currentConfigName} (${configIndex}/${configCount})" '#'
        executeScript "${currentConfigName}"
      ) || installStatus="$?"
      if [[ "${installStatus}" != "0" ]]; then
        Log::displayError "Aborted after ${currentConfigName} failure"
        exit "${installStatus}"
      fi
    ) 2>&1 | tee >(sed -r 's/\x1b\[[0-9;]*m//g' >>"${LOGS_DIR}/lastInstall.log") || exit 1
    ((++configIndex))
  done
}

Profiles::checkScriptsExistence "${BASH_DEV_ENV_ROOT_DIR}" "" "${CONFIG_LIST[@]}"
Log::displayInfo "Will Install ${CONFIG_LIST[*]}"

# Start install process
declare -i maxLogRotationCount=3
Log::rotate "${LOGS_DIR}/lastInstall.log" "${maxLogRotationCount}"
Log::rotate "${LOGS_DIR}/lastInstallSummary" "${maxLogRotationCount}"
rm -f \
  "${STATS_DIR:-#}/"{install,config,test-install,test-configuration,global}.stat \
  "${LOGS_DIR}/lastInstallStatus" \
  "${LOGS_DIR}/lastInstallLogRecapitulative.log" \
  &>/dev/null || true

UI::drawLine '-'

Linux::createSudoerFile

# indicate to install scripts to avoid loading wsl
export WSL_GARBAGE_COLLECT=0
export WSL_INIT=0
export CHECK_ENV=0
# force interactive mode, otherwise Assert::tty return false
export INTERACTIVE=1

executeScripts || return 1
currentConfigName="executeScripts"
