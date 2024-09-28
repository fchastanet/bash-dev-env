#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/BashUtils/BashTools-conf" as conf_dir

bashToolsBeforeParseCallback() {
  Git::requireGitCommand
}

helpDescription() {
  echo "BashTools collection from François Chastanet"
}

helpLongDescription() {
  helpDescription
  echo "A collection of several bash tools:"
  echo "  - db import"
  echo "  - db query multiple database or apply script"
  echo "  - git tools"
  echo "  - docker containers easy cli"
  echo "  - and many more ..."
  echo
  echo "See https://github.com/fchastanet/bash-tools"
  echo
  echo "Using a bash framework allowing to easily:"
  echo "  - import bash script"
  echo "  - log"
  echo "  - display log messages"
  echo "  - database manipulation"
  echo "  - user interaction"
  echo "  - version comparison"
  echo "  - and many more ..."
  echo
  echo "See https://github.com/fchastanet/bash-tools-framework"
  echo
  echo "All these bash scripts are 'compiled' by using"
  echo "https://github.com/fchastanet/bash-compiler"
}

fortunes() {
  if [[ -d "${HOME}/fchastanet/bash-tools/bin" ]]; then
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}cli${__RESET_COLOR} -- tool to easily connect to your containers."
    echo "%"
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}dbImport${__RESET_COLOR} -- tool to import database from aws or remote mysql server."
    echo "%"
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}dbQueryAllDatabases${__RESET_COLOR} -- tool to execute a query on multiple databases."
    echo "%"
  else
    echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- Run ${__HELP_EXAMPLE}installAndConfigure BashTools${__RESET_COLOR} "
    echo -e "to initialize bash tools (${__HELP_EXAMPLE}cli${__RESET_COLOR}, ${__HELP_EXAMPLE}dbImport${__RESET_COLOR}, ${__HELP_EXAMPLE}dbQueryAllDatabases${__RESET_COLOR}, ...)"
    echo "%"
  fi
}

dependencies() {
  echo "installScripts/PreCommitDefaultConfig"
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
  Tools::installBashTools "${HOME}/fchastanet/bash-tools"
}

testInstall() {
  local -i failures=0
  Assert::dirExists "${HOME}/fchastanet/bash-tools/.git" || ((++failures))
  return "${failures}"
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"

  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-tools"
}

testConfigure() {
  local -i failures=0
  Assert::dirExists "${HOME}/.bash-tools" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/bash-tools-dev.sh" || ((++failures))
  Assert::fileExists "${HOME}/.bash-tools/cliProfiles/default.sh" || ((++failures))
  return "${failures}"
}
