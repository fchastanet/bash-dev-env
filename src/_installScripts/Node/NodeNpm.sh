#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/Node/NodeNpm-conf" as conf_dir

helpDescription() {
  echo "$(scriptName) -- Installs node and npm using n tool"
}

helpLongDescription() {
  helpDescription
  echo -e "${__HELP_EXAMPLE}n${__RESET_COLOR} tool helps to easily switch from one ${__HELP_EXAMPLE}node${__RESET_COLOR} version to another."
}

fortunes() {
  helpLongDescription
  echo "%"
}

# jscpd:ignore-start
dependencies() { :; }
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
configure() { :; }
testConfigure() { :; }
# jscpd:ignore-end

install() {
  if [[ ! -d "${HOME}/n" ]]; then
    # -y avoid interactive
    # -n no automatic bash profile install
    Retry::default curl --fail -L https://git.io/n-install |
      N_PREFIX="${HOME}/n" bash -s -- -y -n latest
  else
    (
      # shellcheck disable=SC2030
      PATH="${PATH}":"${HOME}/n/bin"
      # update n
      N_PREFIX="${HOME}/n" n-update -y
      # update node
      N_PREFIX="${HOME}/n" "${HOME}/n/bin/n" latest
    ) || return 1
  fi

  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testInstall() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/profile.d/n_path.sh" || ((++failures))
  # shellcheck source=src/_installScripts/Node/NodeNpm-conf/.bash-dev-env/profile.d/n_path.sh
  source "${HOME}/.bash-dev-env/profile.d/n_path.sh" || ((++failures))
  Version::checkMinimal "n" "--version" "10.0.0" || ((++failures))
  Version::checkMinimal "node" "-v" "22.9.0" || ((++failures))
  Version::checkMinimal "npm" "-v" "10.8.3" || ((++failures))
  return "${failures}"
}
