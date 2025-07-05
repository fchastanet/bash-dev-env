#!/usr/bin/env bash

helpDescription() {
  echo "Rust dependencies - development tools"
}

helpLongDescription() {
  helpDescription
  echo "$(scriptName) -- the following rust tools are available:"
  echo -e "  - ${__HELP_EXAMPLE}git-delta${__RESET_COLOR}"
  echo -e "      A syntax-highlighting pager for git"
  echo -e "      https://crates.io/crates/git-delta"
  echo -e "  - ${__HELP_EXAMPLE}cargo-cache${__RESET_COLOR}"
  echo -e "      Allows to manage the cargo cache"
}

dependencies() {
  echo "installScripts/Rust"
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
testCleanBeforeExport() { :; }
# jscpd:ignore-end

install() {
  Log::displayInfo "Installing Rust dependencies"
  # install useful dependencies
  (
    set -o errexit -o nounset
    cargo install git-delta
    cargo install cargo-cache

    Log::displayInfo "Upgrading Rust dependencies"
    cargo update
  )
}

testInstall() {
  local -i failures=0
  (
    # shellcheck source=/dev/null
    source "${HOME}/.bash-dev-env/profile.d/rust.sh" || return 1
    local -i failures=0
    Version::checkMinimal "delta" --version "0.18.2" || ((++failures))
    exit "${failures}"
  ) || failures="$?"
  return "${failures}"
}

cleanBeforeExport() {
  # shellcheck source=/dev/null
  source "${HOME}/.bash-dev-env/profile.d/rust.sh" || exit 1
  Log::displayInfo "Cleaning cargo cache"
  cargo cache -e --gc
}
