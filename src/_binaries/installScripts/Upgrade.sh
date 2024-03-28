#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Upgrade
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Upgrade"
}

helpDescription() {
  echo "Upgrade ubuntu apt softwares"
}

dependencies() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

helpVariables() {
  # shellcheck disable=SC2317
  cat <<EOF
  ${__HELP_EXAMPLE}UPGRADE_UBUNTU_VERSION${__HELP_NORMAL}
    possible values:
    0             => no upgrade at all
    lts (default) => UPGRADE to latest ubuntu lts version
    dev           => UPGRADE to latest ubuntu dev version

EOF
}

listVariables() {
  echo "UPGRADE_UBUNTU_VERSION"
}

defaultVariables() {
  export UPGRADE_UBUNTU_VERSION="lts"
}

checkVariables() {
  if ! Assert::varExistsAndNotEmpty "UPGRADE_UBUNTU_VERSION"; then
    return 1
  elif ! Array::contains "${UPGRADE_UBUNTU_VERSION}" "lts" "dev"; then
    Log::displayError "UPGRADE_UBUNTU_VERSION values expects to be lts or dev"
    return 1
  fi
}

removeSystemdService() {
  local service="$?"
  if systemctl list-units --full -all | grep -Fq "${service}"; then
    sudo systemctl disable "${service}"
  fi
}
install() {
  # remove unneeded systemd service
  # sshd is not needed and cause port 22 usage conflict
  removeSystemdService ssh.service
  sudo systemctl daemon-reload
  sudo systemctl reset-failed

  Linux::Apt::remove \
    openssh-server

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
  sudo sed -i -E 's/^Prompt=.*$/Prompt=lts/g' /etc/update-manager/release-upgrades
}

testInstall() { :; }
configure() { :; }
testConfigure() { :; }
