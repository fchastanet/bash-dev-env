#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Motd
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Motd"
}

helpDescription() {
  echo "Motd"
}

dependencies() { :; }
fortunes() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  Linux::Apt::update
  PACKAGES=(
    # /usr/share/update-notifier/notify-updates-outdated needed by motd
    update-notifier-common
  )
  Linux::Apt::install "${PACKAGES[@]}"
}

testInstall() { :; }
configure() { :; } 
testConfigure() { :; }
