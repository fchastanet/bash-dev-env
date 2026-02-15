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
  echo -e "  - ${__HELP_EXAMPLE}cargo-update${__RESET_COLOR}"
  echo -e "      A cargo subcommand for checking and applying updates to installed executables"
  echo -e "      https://crates.io/crates/cargo-update"
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

  # Install system dependencies for OpenSSL
  Log::displayInfo "Installing required system dependencies for OpenSSL"
  if ! Linux::Apt::installIfNecessary --no-install-recommends \
    pkg-config \
    libssl-dev; then
    Log::displayError "Failed to install OpenSSL development packages"
    return 1
  fi

  # install useful dependencies
  (
    set -o errexit -o nounset
    if [[ -f "${HOME}/.cargo/env" ]]; then
      # shellcheck source=/dev/null
      source "${HOME}/.cargo/env"
    else
      Log::displayError "Rust environment file not found: ${HOME}/.cargo/env"
      return 1
    fi
    # Install individual packages
    cargo install \
      cargo-cache \
      cargo-update \
      git-delta

    Log::displayInfo "Upgrading Rust dependencies"
    # Use cargo-update to update all installed packages
    cargo install-update -a
  )
}

testInstall() {
  local -i failures=0
  (
    # shellcheck source=/dev/null
    source "${HOME}/.bash-dev-env/profile.d/rust.sh" || return 1
    local -i failures=0
    Version::checkMinimal "delta" --version "0.18.2" || ((++failures))
    Version::checkMinimal "cargo-cache" --version "0.8.3" || ((++failures))
    # Check if cargo-update is installed
    if ! command -v cargo-install-update &>/dev/null; then
      Log::displayError "cargo-update is not installed"
      ((++failures))
    fi
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
