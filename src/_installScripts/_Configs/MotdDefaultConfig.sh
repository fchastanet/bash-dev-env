#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/_Configs/MotdDefaultConfig-conf" as conf_dir

helpDescription() {
  echo "Motd default configuration"
}

dependencies() {
  echo "installScripts/Anacron"
}

fortunes() {
  if [[ "${SHOW_MOTD}" = "1" ]]; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- You can set ${__HELP_EXAMPLE}SHOW_MOTD${__RESET_COLOR} to ${__HELP_EXAMPLE}0${__RESET_COLOR} in ${__HELP_EXAMPLE}${BASH_DEV_ENV_ROOT_DIR}/.env${__RESET_COLOR} to hide motd."
    echo "%"
  else
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- You can set ${__HELP_EXAMPLE}SHOW_MOTD${__RESET_COLOR} to ${__HELP_EXAMPLE}1${__RESET_COLOR} in ${__HELP_EXAMPLE}${BASH_DEV_ENV_ROOT_DIR}/.env${__RESET_COLOR} to display motd."
    echo "%"
  fi
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }
isInstallImplemented() { :; }
isTestInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
# jscpd:ignore-end

cleanBeforeExport() {
  rm -f "${HOME}/.motd_shown" || true
}

testCleanBeforeExport() {
  ((failures = 0)) || true
  Assert::fileNotExists "${HOME}/.motd_shown" || ((++failures))
  return "${failures}"
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  # shellcheck disable=SC2154
  SUDO=sudo Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    "etc" \
    "/etc"

  # disable some parts
  sudo chmod 600 \
    /etc/update-motd.d/00-header \
    /etc/update-motd.d/10-help-text \
    /etc/update-motd.d/50-motd-news \
    /etc/update-motd.d/90-updates-available \
    /etc/update-motd.d/91-contract-ua-esm-status \
    /etc/update-motd.d/91-release-upgrade \
    /etc/update-motd.d/92-unattended-upgrades \
    /etc/update-motd.d/95-hwe-eol ||
    true

  if [[ -f /usr/share/landscape/landscape-sysinfo.wrapper ]]; then
    sudo chmod 600 /usr/share/landscape/landscape-sysinfo.wrapper
  fi
  sudo sed -i -E \
    -e "s#^BASH_DEV_ENV_LOGS_DIR=.*\$#BASH_DEV_ENV_LOGS_DIR=${LOGS_DIR}#" \
    /etc/update-motd.d/03-wsl-automatic-upgrade

  # update motd cache
  sudo update-motd >/dev/null

}

testConfigure() {
  local -i failures=0
  Assert::fileExecutable "/etc/update-motd.d/00-wsl-header" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/01-wsl-sysinfo" || ((++failures))
  Assert::fileExecutable "/etc/update-motd.d/03-wsl-automatic-upgrade" || ((++failures))
  if grep -E -q '^BASH_DEV_ENV_LOGS_DIR=/invalid$' /etc/update-motd.d/03-wsl-automatic-upgrade; then
    Log::displayError "/etc/update-motd.d/03-wsl-automatic-upgrade contain invalid path"
    ((++failures))
  fi
  Assert::fileNotExecutable "/etc/update-motd.d/10-help-text" root root || ((++failures))
  Assert::fileNotExecutable "/etc/update-motd.d/00-header" root root || ((++failures))

  Assert::fileExecutable "/etc/cron.daily/motd" || ((++failures))

  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/motd.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/motd.zsh" || ((++failures))

  if ! sudo update-motd >/dev/null; then
    Log::displayWarning "motd not working"
    ((++failures))
  fi
  if [[ -z "$(sudo update-motd)" ]]; then
    Log::displayWarning "motd is empty"
    ((++failures))
  fi
  return "${failures}"
}
