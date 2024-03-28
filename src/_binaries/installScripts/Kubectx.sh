#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Kubectx
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "Kubectx"
}

helpDescription() {
  echo "Kubectx"
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
  SUDO=sudo Git::cloneOrPullIfNoChanges \
    "/opt/kubectx" \
    "https://github.com/ahmetb/kubectx"

  sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
}


testInstall() {
  local -i failures=0
  Assert::commandExists kubectx || ((++failures))
  Assert::commandExists kubens || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
