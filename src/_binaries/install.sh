#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/install
# FACADE
# BASH_DEV_ENV_ROOT_DIR_RELATIVE_TO_BIN_DIR=

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

# variables
CONFIG_LIST=()
PROFILE=
SKIP_INSTALL=0
SKIP_CONFIGURE=0
SKIP_TEST=0
# shellcheck disable=SC2034
PREPARE_EXPORT=0
# shellcheck disable=SC2034
SKIP_DEPENDENCIES=0

INSTALL_START="$(date +%s)"

# trap errors
err_report() {
  echo "$0 - Upgrade failure - Error on line $1"
  exit 1
}
trap 'err_report $LINENO' ERR

.INCLUDE "$(dynamicTemplateDir _binaries/install.options.tpl)"

# shellcheck disable=SC2317
declare summaryDisplayed="0"
summary() {
  local startDate="$1"
  if [[ "${summaryDisplayed}" = "1" ]]; then
    return 0
  fi
  UI::drawLine '-'
  Log::headLine "Important messages recapitulative"
  Stats::logRecapitulative "${LOGS_DIR}/automatic-upgrade"

  UI::drawLine '-'
  Log::headLine "Summary"
  if [[ "${SKIP_INSTALL}" = "0" ]]; then
    Stats::aggregateStatsSummary "installation(s)" "${LOGS_DIR:-#}/install.stat" "${#CONFIG_LIST[@]}"
  fi
  if [[ "${SKIP_CONFIGURE}" = "0" ]]; then
    Stats::aggregateStatsSummary "configuration(s)" "${LOGS_DIR:-#}/config.stat" "${#CONFIG_LIST[@]}"
  fi
  if [[ "${SKIP_TEST}" = "0" ]]; then
    Stats::aggregateStatsSummary "test(s)" "${LOGS_DIR:-#}/test-install.stat" "${#CONFIG_LIST[@]}"
    Stats::aggregateStatsSummary "test(s)" "${LOGS_DIR:-#}/test-configuration.stat" "${#CONFIG_LIST[@]}"
  fi
  local endDate
  endDate="$(date +%s)"
  Log::displayInfo "Total duration: $((endDate - startDate))s"
  summaryDisplayed="1"
}
trap 'summary "${INSTALL_START}"' EXIT INT TERM ABRT

executeScript() {
  local configName="$1"
  local -a installCmd=(
    "${INSTALL_SCRIPTS_DIR}/${configName}"
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

  "${installCmd[@]}"
}

# we need non root user to be sure that all variables will be correctly deduced
# @require Linux::requireExecutedAsUser
run() {

  LOGS_DIR="${LOGS_DIR:-${PERSISTENT_TMPDIR}}"
  rm -f "${LOGS_DIR:-#}/${SCRIPT}-"* || true

  # load selected profile
  if [[ -n "${PROFILE}" ]]; then
    mapfile -t CONFIG_LIST < <(
      IFS=$'\n' Profiles::loadProfile "${BASH_DEV_ENV_ROOT_DIR}/profiles" "${PROFILE}"
    )
  fi

  Log::displayInfo "Install ${CONFIG_LIST[*]}"

  Profiles::checkScriptsExistence "${INSTALL_SCRIPTS_DIR}" "" "${CONFIG_LIST[@]}"
  Log::displayInfo "Will Install ${CONFIG_LIST[*]}"

  # Start install process
  Log::rotate "${LOGS_DIR}/automatic-upgrade"
  rm -f \
    "${LOGS_DIR:-#}/"{install,config,test-install,test-configuration}.stat \
    &>/dev/null || true

  UI::drawLine '-'

  if (
    # shellcheck disable=SC2317
    for configName in "${CONFIG_LIST[@]}"; do
      installStatus="0"
      (
        aggregateStat() {
          if [[ "${SKIP_INSTALL}" = "0" ]]; then
            Stats::aggregateStats "${LOGS_DIR:-#}/${configName}-install.stat" "${LOGS_DIR:-#}/install.stat"
            rm -f "${LOGS_DIR:-#}/${configName}-install.stat" || true # avoid to aggregate twice if trapped twice
          fi
          if [[ "${SKIP_CONFIGURE}" = "0" ]]; then
            Stats::aggregateStats "${LOGS_DIR:-#}/${configName}-config.stat" "${LOGS_DIR:-#}/config.stat"
            rm -f "${LOGS_DIR:-#}/${configName}-config.stat" || true # avoid to aggregate twice if trapped twice
          fi
          if [[ "${SKIP_TEST}" = "0" ]]; then
            Stats::aggregateStats "${LOGS_DIR:-#}/${configName}-test-install.stat" "${LOGS_DIR:-#}/test-install.stat"
            rm -f "${LOGS_DIR:-#}/${configName}-test-install.stat" || true # avoid to aggregate twice if trapped twice
            Stats::aggregateStats "${LOGS_DIR:-#}/${configName}-test-configuration.stat" "${LOGS_DIR:-#}/test-configuration.stat"
            rm -f "${LOGS_DIR:-#}/${configName}-test-configuration.stat" || true # avoid to aggregate twice if trapped twice
          fi
        }
        trap 'aggregateStat' EXIT INT TERM ABRT

        rm -f \
          "${LOGS_DIR:-#}/${configName}"-{install,config,test-install,test-configuration}.stat \
          &>/dev/null || true

        executeScript "${configName}"
      ) || installStatus="$?"
      if [[ "${installStatus}" != "0" ]]; then
        Log::displayError "Aborted after ${configName} failure"
        exit "${installStatus}"
      fi
    done
  ) | tee "${LOGS_DIR}/automatic-upgrade"; then
    Log::displaySuccess "Successful Installation"
  else
    Log::displayError "Installation error, check logs /var/log/automatic-upgrade"
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run "$@" &>/dev/null
else
  run "$@"
fi