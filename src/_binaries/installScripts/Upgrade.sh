#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Upgrade
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

installScript_helpDescription() {
  echo "Upgrade ubuntu apt softwares"
}

installScript_helpVariables() {
  # shellcheck disable=SC2317
  cat <<EOF
  ${__HELP_EXAMPLE}UPGRADE_UBUNTU_VERSION${__HELP_NORMAL}
    possible values:
    0             => no upgrade at all
    lts (default) => UPGRADE to latest ubuntu lts version
    dev           => UPGRADE to latest ubuntu dev version

EOF
}

installScript_listVariables() {
  echo "UPGRADE_UBUNTU_VERSION"
}

installScript_defaultVariables() {
  export UPGRADE_UBUNTU_VERSION="lts"
}

installScript_checkVariables() {
  if ! Assert::varExistsAndNotEmpty "UPGRADE_UBUNTU_VERSION"; then
    return 1
  elif ! Array::contains "${UPGRADE_UBUNTU_VERSION}" "lts" "dev"; then
    Log::displayError "UPGRADE_UBUNTU_VERSION values expects to be lts or dev"
    return 1
  fi
}

installScript_fortunes() {
  return 0
}

installScript_dependencies() {
  return 0
}

installScript_breakOnConfigFailure() {
  return 0
}

installScript_breakOnTestFailure() {
  return 0
}

installScript_install() {
  # Needed before do-release-upgrade because WSL doesn't support Systemd directly
  Linux::Apt::remove snapd || true
  mv /etc/apt/apt.conf.d/20snapd.conf{,.disabled} || true
  Linux::Apt::update
  Retry::default sudo apt-get upgrade -y
  Retry::default sudo apt-get dist-upgrade -y
  Retry::default sudo apt-get autoremove -y

  # add do-release-upgrade
  Linux::Apt::install ubuntu-release-upgrader-core

  # configure to upgrade to the latest LTS development release
  sudo sed -i -r 's/^Prompt=.*$/Prompt=lts/g' /etc/update-manager/release-upgrades
  if sudo do-release-upgrade -c; then
    if [[ "${UPGRADE_UBUNTU_VERSION}" = "lts" ]]; then
      Log::displayInfo "Upgrading to latest lts ubuntu - please be patient, it can take a long time"
      Retry::default sudo do-release-upgrade -f DistUpgradeViewNonInteractive --allow-third-party
      Log::displayHelp "Please restart wsl - 'wsl --shutdown'"
    else
      Log::displayHelp "An lts ubuntu upgrade is available, update UPGRADE_UBUNTU_VERSION=lts in .env file if you want to upgrade next time (use with caution)"
    fi
  fi

  # configure to upgrade to the latest non-LTS development release
  sudo sed -i -r 's/^Prompt=.*$/Prompt=normal/g' /etc/update-manager/release-upgrades
  if sudo do-release-upgrade -c; then
    if [[ "${UPGRADE_UBUNTU_VERSION}" = "dev" ]]; then
      Log::displayInfo "Upgrading to latest non-lts ubuntu - please be patient, it can take a long time"
      Retry::default sudo do-release-upgrade -f DistUpgradeViewNonInteractive --allow-third-party
      Log::displayHelp "Please restart wsl - 'wsl --shutdown'"
    else
      Log::displayHelp "A non-lts ubuntu upgrade is available, update UPGRADE_UBUNTU_VERSION=dev in .env file if you want to upgrade next time (use with caution)"
    fi
  fi

  # restore to lts development release
  sudo sed -i -r 's/^Prompt=.*$/Prompt=lts/g' /etc/update-manager/release-upgrades
}

installScript_configure() {
  return 0
}

installScript_test() {
  return 0
}
