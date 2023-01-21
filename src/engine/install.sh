#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/install
# ROOT_DIR_RELATIVE_TO_BIN_DIR=

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

# we need non root user to be sure that all variables will be correctly deduced
Assert::expectNonRootUser

INSTALL_START="$(date +%s)"

showHelp() {
  # shellcheck disable=SC2317
  engine::install::showHelp "Installs, updates softwares (kube, aws, composer, node, ...),
  configure Home environnement (git config, kube, motd, ssh, dns, ...) and check configuration"
}

.INCLUDE "${TEMPLATE_DIR}/engine/install/_optionsParse.sh"

.INCLUDE "${TEMPLATE_DIR}/engine/install/_trapError.sh"

.INCLUDE "${TEMPLATE_DIR}/engine/config/load.sh"

# load selected profile
if [[ -n "${PROFILE}" ]]; then
  mapfile -t CONFIG_LIST < <(
    IFS=$'\n' Profiles::loadProfile "${ROOT_DIR}" "${PROFILE}"
  )
fi
Log::displayInfo "Install ${CONFIG_LIST[*]}"

if [[ "${SKIP_DEPENDENCIES}" = "0" ]]; then
  CONFIG_LIST=("MinimumRequirements" "Upgrade" "MandatorySoftwares" "${CONFIG_LIST[@]}" "Clean")
  if [[ "${PREPARE_EXPORT}" = "1" ]]; then
    CONFIG_LIST+=("_Export")
  fi

  declare rootDependency="your software selection"
  if [[ -n "${PROFILE}" ]]; then
    rootDependency="profile ${PROFILE}"
  fi
  # deduce dependencies
  declare -ag allDepsResult=()
  # shellcheck disable=SC2034
  declare -Ag allDepsResultSeen=()

  Profiles::allDepsRecursive \
    "${SRC_DIR}/installScripts/definitions" "${rootDependency}" "${CONFIG_LIST[@]}"

  CONFIG_LIST=("${allDepsResult[@]}")
fi

Profiles::checkScriptsExistence "${INSTALL_SCRIPTS_DIR}" "" "${CONFIG_LIST[@]}"
Log::displayInfo "Will Install ${CONFIG_LIST[*]}"

# Start install process
Log::rotate "${LOGS_DIR}/automatic-upgrade"
UI::drawLine '-'

# shellcheck source=./lib/installMain.sh
# if time "${LIB_DIR}/installMain.sh" "${PROFILE}" "${PREPARE_EXPORT}" "${SKIP_INSTALL}" "${SKIP_CONFIGURE}" "${SKIP_TEST}" "${CONFIG_LIST[@]}" 2>&1 | tee /var/log/automatic-upgrade; then
#   # everything OK
#   Log::displaySuccess "Successful Installation"
# else
#   Log::displayError "Installation error, check logs /var/log/automatic-upgrade"
# fi

# shellcheck disable=SC2317
declare summaryDisplayed="0"
summary() {
  if [[ "${summaryDisplayed}" = "1" ]]; then
    return 0
  fi
  UI::drawLine '-'
  Log::headLine "Important messages recapitulative"
  stats::logRecapitulative "${LOGS_DIR}/automatic-upgrade"

  UI::drawLine '-'
  Log::headLine "Summary"
  if [[ "${SKIP_INSTALL}" = "0" ]]; then
    stats::aggregateStatsSummary "installation(s)" "${TMPDIR}/install.stat" "${#CONFIG_LIST[@]}"
  fi
  if [[ "${SKIP_CONFIGURE}" = "0" ]]; then
    stats::aggregateStatsSummary "configuration(s)" "${TMPDIR}/config.stat" "${#CONFIG_LIST[@]}"
  fi
  if [[ "${SKIP_TEST}" = "0" ]]; then
    stats::aggregateStatsSummary "test(s)" "${TMPDIR}/test.stat" "${#CONFIG_LIST[@]}"
  fi
  INSTALL_END="$(date +%s)"
  Log::displayInfo "Total duration: $((INSTALL_END - INSTALL_START))s"
  summaryDisplayed="1"
}
trap 'summary' EXIT INT TERM ABRT

(
  # shellcheck disable=SC2317
  for configName in "${CONFIG_LIST[@]}"; do
    installCmd=(
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
    installStatus="0"

    (
      aggregateStat() {
        if [[ "${SKIP_INSTALL}" = "0" ]]; then
          stats::aggregateStats "${TMPDIR}/${configName}-install.stat" "${TMPDIR}/install.stat"
          rm -f "${TMPDIR}/${configName}-install.stat" || true # avoid to aggregate twice if trapped twice
        fi
        if [[ "${SKIP_CONFIGURE}" = "0" ]]; then
          stats::aggregateStats "${TMPDIR}/${configName}-config.stat" "${TMPDIR}/config.stat"
          rm -f "${TMPDIR}/${configName}-config.stat" || true # avoid to aggregate twice if trapped twice
        fi
        if [[ "${SKIP_TEST}" = "0" ]]; then
          stats::aggregateStats "${TMPDIR}/${configName}-test.stat" "${TMPDIR}/test.stat"
          rm -f "${TMPDIR}/${configName}-test.stat" || true # avoid to aggregate twice if trapped twice
        fi
      }
      trap 'aggregateStat' EXIT INT TERM ABRT

      CONFIG_LOGS_DIR="${TMPDIR}" "${installCmd[@]}"
    ) || installStatus="$?"
    if [[ "${installStatus}" != "0" ]]; then
      Log::displayError "Aborted after ${configName} failure"
      exit "${installStatus}"
    fi
  done
) | tee "${LOGS_DIR}/automatic-upgrade"
