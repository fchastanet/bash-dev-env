#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/NodeNpm
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/NodeNpm/etc/profile.d/n_path.sh" as n_path

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "NodeNpm"
}

helpDescription() {
  echo "NodeNpm"
}

dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
fortunes() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  if [[ ! -d "${USER_HOME}/n" ]]; then
    # -y avoid interactive
    # -n no automatic bash profile install
    Retry::default curl --fail -L https://git.io/n-install | 
      N_PREFIX="${USER_HOME}/n" bash -s -- -y -n latest
  else
    # update node
    N_PREFIX="${USER_HOME}/n" "${USER_HOME}/n/bin/n" latest
  fi
  Log::displayInfo "Install /etc/profile.d/n_path.sh"
  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "etc/profile.d/n_path.sh" "${embed_file_n_path}")" || return 1
  SUDO=sudo OVERWRITE_CONFIG_FILES=1 BACKUP_BEFORE_INSTALL=0 Install::file \
    "${fileToInstall}" "/etc/profile.d/n_path.sh" \
    "root" "root" \
    Install::setRootExecutableCallback || return 1
}

testInstall() {
  local -i failures=0
  Assert::fileExists "/etc/profile.d/n_path.sh" root root || return 1
  # shellcheck source=/conf/NodeNpm/etc/profile.d/n_path.sh
  HOME="${USER_HOME}" source /etc/profile.d/n_path.sh
  Version::checkMinimal "node" "-v" "20.6.1" || ((++failures))
  Version::checkMinimal "npm" "-v" "10.3.0" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }
