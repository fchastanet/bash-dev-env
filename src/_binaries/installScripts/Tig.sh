#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Tig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Tig"
}

helpDescription() {
  echo "Tig"
}

fortunes() { 
  fortunes+=("Tig - use 'tig' command to browse git repository's logs")
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  Linux::Apt::update
  Linux::Apt::install \
    tig
}

testInstall() {
  Assert::commandExists tig
}

configure() { :; }
testConfigure() { :; }
