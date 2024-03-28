#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Anacron
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Anacron"
}

helpDescription() {
  echo "Anacron"
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
  Linux::Apt::update
  Linux::Apt::install \
    anacron
}

testInstall() {
  Assert::commandExists anacron
}

configure() {
  sudo groupadd anacron || true
  sudo adduser "${USERNAME}" anacron || true
  sudo chown root:anacron /var/spool/anacron/
  sudo chmod 755 /var/spool/anacron/
}

testConfigure() {
  local -i failures=0
  anacron -T || {
    Log::displayError "anacron format not valid"
    ((failures++))
  }
  
  # check if user is part of anacron group
  groups "${USERNAME}" | grep -E ' anacron' || {
    Log::displayError "${USERNAME} is not part of anacron group"
    ((failures++))
  }
  Assert::dirExists /var/spool/anacron/ "root" "anacron" || ((failures++))

  if ! sudo service anacron start; then
    Log::displayError "unable to execute anacron service with user ${USERNAME}"
    ((failures++))
  fi

  return "${failures}"
}
