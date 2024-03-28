#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/NodeDependencies
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "NodeDependencies"
}

helpDescription() {
  echo "NodeDependencies"
}

dependencies() { 
  echo "NodeNpm"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  if [[ ! -d "${USER_HOME}/n" ]]; then
    Log::displaySkipped "node dependencies skipped as node not installed"
    return 0
  fi
  # shellcheck source=conf/NodeNpm/etc/profile.d/n_path.sh
  HOME="${USER_HOME}" source /etc/profile.d/n_path.sh

  # npm install
  npmInstall() {
    if ! npm -g list "$1" >/dev/null; then
      Log::displayInfo "install npm package $1 globally"
      npm install -g "$1"
    fi
  }

  npmInstall npm-check-updates
  npmInstall prettier
  npmInstall sass-lint
  npmInstall stylelint
  npmInstall hjson

  Log::displayInfo "check npm packages update and upgrade"
  local updates
  updates=$(npm-check-updates -g -u | grep 'npm -g' || true)
  if [[ -n "${updates}" ]]; then
    eval "${updates}"
  fi
}

testInstall() {
  local -i failures=0
  # shellcheck source=conf/NodeNpm/etc/profile.d/n_path.sh
  HOME="${USER_HOME}" source /etc/profile.d/n_path.sh
  Version::checkMinimal "npm-check-updates" "--version" "11.5.13" || ((++failures))
  Version::checkMinimal "prettier" "--version" "2.3.0" || ((++failures))
  Version::checkMinimal "sass-lint" "--version" "1.13.1" || ((++failures))
  Version::checkMinimal "stylelint" "--version" "13.13.1" || ((++failures))
  Version::checkMinimal "hjson" "--version" "3.2.1" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
