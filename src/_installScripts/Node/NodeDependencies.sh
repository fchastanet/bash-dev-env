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
configure() { :; }
testConfigure() { :; }
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
      Log::displaySkipped "node package $1 already installed"
    else
      Log::displayInfo "install node package $1 globally"
      npm install -g "$1"
    fi
  }
  npmInstall npm-check-updates
  Log::displayInfo "check node packages update and upgrade"
  local updates
  updates=$(npm-check-updates -g -u | grep 'npm -g' || true)
  if [[ -n "${updates}" ]]; then
    eval "${updates}"
  fi

  # yarn install
  local -a nodePackages=(
    npm-check
    prettier
    sass-lint
    stylelint
    hjson
  )
  Log::displayInfo "install globally the following node packages ${nodePackages[*]}"
  yarn global add --non-interactive --latest "${nodePackages[@]}"


  Log::displayInfo "check if node packages updates are available and upgrade"
  npm-check -uy
}

testInstall() {
  local -i failures=0
  # shellcheck source=src/_installScripts/Node/NodeNpm-conf/.bash-dev-env/profile.d/n_path.sh
  source "${HOME}/.bash-dev-env/profile.d/n_path.sh"
  Version::checkMinimal "npm-check-updates" "--version" "17.1.12" || ((++failures))
  Version::checkMinimal "npm-check" "--version" "6.0.1" || ((++failures))
  Version::checkMinimal "prettier" "--version" "3.4.2" || ((++failures))
  Version::checkMinimal "sass-lint" "--version" "1.13.1" || ((++failures))
  Version::checkMinimal "stylelint" "--version" "16.12.0" || ((++failures))
  Version::checkMinimal "hjson" "--version" "3.2.1" || ((++failures))
  return "${failures}"
}

cleanBeforeExport() {
  rm -Rf "${HOME}/.npm/_cacache" || true
}

testCleanBeforeExport() {
  ((failures = 0)) || true
  Assert::dirNotExists "${HOME}/.npm/_cacache" || ((++failures))
  return "${failures}"
}
