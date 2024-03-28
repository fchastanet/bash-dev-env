#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fasd
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Fasd"
}

helpDescription() {
  echo "Fasd"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

fortunes() {
  if command -v fasd &>/dev/null; then
    fortunes+=("Fasd -- z <directory> to easily change directory (see https://github.com/clvv/fasd)")
    fortunes+=("Fasd -- v <file> to easily edit recently file with vi (see https://github.com/clvv/fasd)")
  else
    fortunes+=("Fasd -- Think about installing fasd to easily switch directory - run 'install Fasd'")
  fi
}

install() {
  Linux::Apt::addRepository ppa:aacebedo/fasd
  Linux::Apt::install \
    fasd
}

testInstall() {
  Assert::commandExists fasd || return 1
}

configure() { :; }
testConfigure() { :; }
