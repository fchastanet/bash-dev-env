#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/BashTools
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/src/_binaries/BashTools/conf" as conf_dir

.INCLUDE "$(dynamicTemplateDir "_includes/_installScript.tpl")"

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
    fortunes+=("Run 'installAndConfigure BashTools' -- to initialize bash tools (cli, dbImport, dbQueryAllDatabases, ...)")
  fi
}

dependencies() {
  echo "PreCommitDefaultConfig"
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
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
  
  OVERWRITE_CONFIG_FILES=1 Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-tools"
}
testConfigure() {
  local -i failures=0
  Assert::dirExists "${USER_HOME}/.bash-tools" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-dev-env/aliases.d/bash-tools-dev.sh" || ((++failures))
  Assert::fileExists "${USER_HOME}/.bash-tools/cliProfiles/default.sh" || ((++failures))
  return "${failures}"
}