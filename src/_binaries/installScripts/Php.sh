#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Php
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Php"
}

helpDescription() {
  echo "Php"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  PACKAGES=(
    php
    php-curl
    # needed by php code sniffer: php-mbstring
    php-mbstring
    # needed by composer : php-xml
    php-xml
  )
  Linux::Apt::update
  Linux::Apt::install "${PACKAGES[@]}"
}

checkPhpModuleExists() {
  if ! php -m | grep -q "$1"; then
    Log::displayError "Php module $1 not found"
    return 1
  fi
  Log::displayInfo "Php module $1 is installed"
}
testInstall() {
  local -i failures=0
  Version::checkMinimal "php" --version "7.4.3" || ((++failures))
  checkPhpModuleExists curl || ((++failures))
  checkPhpModuleExists mbstring || ((++failures))
  checkPhpModuleExists xml || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
