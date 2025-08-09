#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Rust/Rust-conf" as conf_dir

helpDescription() {
  echo "Rust"
}

helpLongDescription() {
  echo "Rust"
}

# jscpd:ignore-start
fortunes() { :; }
dependencies() { :; }
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
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "$(fullScriptOverrideDir)" \
    ".bash-dev-env"

  mkdir -p "${HOME}/.cargo/bin"
  if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  if [[ -f "${HOME}/.cargo/env" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.cargo/env"
    rustup update
  else
    Log::displayError "Rust environment file not found: ${HOME}/.cargo/env"
    return 1
  fi
}

testInstall() {
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/rust.sh" || return 1
  # shellcheck source=/dev/null
  source "${HOME}/.bash-dev-env/profile.d/rust.sh" || return 2

  local -i failures=0
  Assert::commandExists "rustc" || ((++failures))
  Assert::commandExists "rustup" || ((++failures))

  return "${failures}"
}
