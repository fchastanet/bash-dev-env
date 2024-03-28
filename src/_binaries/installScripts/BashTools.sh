#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/BashTools
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/conf/.bash-tools" as bash_tools_conf

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "BashTools"
}

helpDescription() {
  echo "BashTools"
}

fortunes() { 
  if [[ -d "${USER_HOME}/fchastanet/bash-tools/bin" ]]; then
    fortunes+=("BashTools - cli -- tool to easily connect to your containers")
    fortunes+=("BashTools - dbImport -- tool to import database from aws or Mizar")
    fortunes+=("BashTools - dbQueryAllDatabases -- tool to execute a query on multiple databases")
  else
    fortunes+=("installBashTools -- to initialize bash tools (cli, dbImport, dbQueryAllDatabases, ...)")
  fi
}

dependencies() {
  echo "PreCommitConfig"
}

helpVariables() { :; }
listVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }

install() {
  Tools::installBashTools
}

testInstall() {
  local -i failures=0
  Assert::dirExists "${USER_HOME}/fchastanet/bash-tools/.git" || ((++failures))
  return "${failures}"
}

configure() {
  local dirToInstall
  # shellcheck disable=SC2154
  dirToInstall="$(Conf::dynamicConfDir ".bash-tools" "${embed_dir_bash_tools_conf}")" || return 1
  OVERWRITE_CONFIG_FILES=1 Install::dir \
    "${dirToInstall}" "${USER_HOME}/.bash-tools" || return 1
}
testConfigure() {
  local -i failures=0
  Assert::dirExists "${USER_HOME}/.bash-tools" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-tools/cliProfiles/default.sh" || ((++failures))
  return "${failures}"
}
