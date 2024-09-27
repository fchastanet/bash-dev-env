#!/usr/bin/env bash

helpDescription() {
  echo "Node dependencies mainly code checkers"
}

helpLongDescription() {
  helpDescription
  echo "$(scriptName) -- the following linters are available: "
  echo -e "  - ${__HELP_EXAMPLE}npm-check-updates${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}prettier${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}sass-lint${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}stylelint${__RESET_COLOR}"
  echo -e "  - ${__HELP_EXAMPLE}hjson${__RESET_COLOR}"
}

dependencies() {
  echo "installScripts/NodeNpm"
}

fortunes() {
  helpLongDescription
  echo "%"
}

# jscpd:ignore-start
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
isInstallImplemented() { :; }
isConfigureImplemented() { :; }
isTestConfigureImplemented() { :; }
isTestInstallImplemented() { :; }
# jscpd:ignore-end

install() {
  if [[ ! -d "${HOME}/n" ]]; then
    Log::displaySkipped "node dependencies skipped as node not installed"
    return 0
  fi
  # shellcheck source=src/_installScripts/Node/NodeNpm-conf/.bash-dev-env/profile.d/n_path.sh
  source "${HOME}/.bash-dev-env/profile.d/n_path.sh"

  # npm install
  npmInstall() {
    if npm -g list "$1" >/dev/null; then
      Log::displaySkipped "npm package $1 already installed"
    else
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
  # shellcheck source=src/_installScripts/Node/NodeNpm-conf/.bash-dev-env/profile.d/n_path.sh
  source "${HOME}/.bash-dev-env/profile.d/n_path.sh"
  Version::checkMinimal "npm-check-updates" "--version" "17.1.3" || ((++failures))
  Version::checkMinimal "prettier" "--version" "3.3.3" || ((++failures))
  Version::checkMinimal "sass-lint" "--version" "1.13.1" || ((++failures))
  Version::checkMinimal "stylelint" "--version" "16.9.0" || ((++failures))
  Version::checkMinimal "hjson" "--version" "3.2.1" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }