#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Clean
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Clean"
}

helpDescription() {
  echo "Clean"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  # some cleaning
  Log::displayInfo "==> Clean up"
  sudo apt-get -y autoremove --purge
  sudo apt-get -y clean
  sudo apt-get -y autoclean
}

configure() { :; }
testInstall() { :; }
testConfigure() { :; }