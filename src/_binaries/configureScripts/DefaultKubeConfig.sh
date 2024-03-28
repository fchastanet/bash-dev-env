#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/DefaultKubeConfig
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "DefaultKubeConfig"
}

helpDescription() {
  echo "DefaultKubeConfig"
}

dependencies() { 
  echo "Kubectx"
  echo "Kubeps1"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
install() { :; }
testInstall() { :; }

configure() {
  mkdir -p "${USER_HOME}/.bash_completion.d" || true
  chown "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d"

  ln -sf /opt/kubectx/completion/kubens.bash "${USER_HOME}/.bash_completion.d/kubens"
  chown -h "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d/kubens"
  ln -sf /opt/kubectx/completion/kubectx.bash "${USER_HOME}/.bash_completion.d/kubectx"
  chown -h "${USERNAME}":"${USERGROUP}" "${USER_HOME}/.bash_completion.d/kubectx"
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "${USER_HOME}/.bash_completion.d" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubens" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash_completion.d/kubectx" || ((++failures))
  return "${failures}"
}
