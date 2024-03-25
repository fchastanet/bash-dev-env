#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Kubeps1
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Kubeps1"
}

helpDescription() {
  echo "Kubeps1"
}

helpVariables() {
  true
}

listVariables() {
  true
}

defaultVariables() {
  true
}

checkVariables() {
  true
}

fortunes() {
  return 0
}

dependencies() {
  return 0
}

breakOnConfigFailure() {
  echo breakOnConfigFailure
}

breakOnTestFailure() {
  echo breakOnTestFailure
}

install() {
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/kubeps1" \
    "https://github.com/jonmosco/kube-ps1.git"
}

configure() {
  :
}

testInstall() {
  local -i failures=0
  Assert::fileExists /opt/kubeps1/kube-ps1.sh root root || ((++failures))
  return "${failures}"
}

testConfigure() {
  :
}
