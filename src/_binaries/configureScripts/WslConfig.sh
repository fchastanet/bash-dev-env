#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/WslConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/etc/wsl.conf" as wslConf

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "WslConfig"
}

helpDescription() {
  echo "WslConfig"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }

configure() {
  sudo hostnamectl set-hostname "${DISTRO_HOSTNAME}"
  SUDO=sudo Dns::addHost "${DISTRO_HOSTNAME}"
  if Assert::wsl && [[ ! -f "/etc/wsl.conf" ]]; then
    local fileToInstall
    # shellcheck disable=SC2154
    fileToInstall="$(Conf::dynamicConfFile "etc/wsl.conf" "${embed_file_wslConf}")" || return 1
    SUDO=sudo OVERWRITE_CONFIG_FILES=1 Install::file \
      "${fileToInstall}" "/etc/wsl.conf" root root "Install::setUserRootCallback"
  fi
}


testConfigure() {
  local -i failures=0
  if ! Assert::wsl; then
    return 0
  fi
  if [[ "$(hostnamectl | grep 'hostname' | awk -F ': ' '{print $2}')" != "${DISTRO_HOSTNAME}" ]]; then
    Log::displayError "Hostname ${DISTRO_HOSTNAME} has not been set on this distro"
    ((++failures))
  fi
  if ! Dns::checkHostname "${DISTRO_HOSTNAME}"; then
    Log::displayError "Hostname ${DISTRO_HOSTNAME} is not reachable"
    ((++failures))
  fi
  if ! Assert::fileExists "/etc/wsl.conf" "root" "root"; then
    ((++failures))
    if ! grep -q -E "^root = /mnt/$" "/etc/wsl.conf"; then
      Log::displayError "/etc/wsl.conf does not contains root = /mnt/ instruction"
      ((++failures))
    fi
  fi
  return "${failures}"
}
