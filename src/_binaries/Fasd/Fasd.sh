#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/Fasd
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/Fasd/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

scriptName() {
  echo "Fasd"
}

helpDescription() {
  echo "Fasd"
}

# jscpd:ignore-start
dependencies() { :; }
helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

fortunes() {
  if command -v fasd &>/dev/null; then
    echo "Fasd -- z <directory> to easily change directory (see https://github.com/clvv/fasd)"
    echo "%"
    echo "Fasd -- v <file> to easily edit recently file with vi (see https://github.com/clvv/fasd)"
    echo "%"
  else
    echo "Fasd -- Think about installing fasd to easily switch directory - run 'install Fasd'"
    echo "%"
  fi
}

install() {
  Linux::Apt::addRepository ppa:aacebedo/fasd
  SKIP_APT_GET_UPDATE=1 Linux::Apt::installIfNecessary --no-install-recommends \
    fasd
  
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}

testInstall() {
  local -i failures=0
  Assert::commandExists fasd || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/interactive.d/fasd.sh" || ((++failures))
  return "${failures}"
}

configure() { :; }
testConfigure() { :; }