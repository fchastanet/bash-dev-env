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
  if [[ "${USER_SHELL}" = "/bin/bash" || "${USER_SHELL}" = "/usr/bin/bash" ]]; then
    echo "$(scriptName) -  configuration for bash shell only allows to search files quickly"
    echo "Following aliases are available:"
    echo "  - alias 'a' - search files/directories based on a pattern"
    echo "  - alias 'd' - search directories based on a pattern"
    echo "  - alias 'f' - search files based on a pattern"
    echo "  - alias 'si' - search most used files/directories in interactive mode(index)"
    echo "  - alias 'sid' - search most used directories in interactive mode(index)"
    echo "  - alias 'sif' - search most used files in interactive mode(index)"
    echo "  - alias 'z' - allows to switch to the directory matching the most the given pattern"
    echo "  - alias 'zz' - allows to select interactively one of the most used directory by index"
    echo '%'
  fi
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
  if [[ "${USER_SHELL}" = "/usr/bin/bash" ]]; then
    if command -v fasd &>/dev/null; then
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}z <directory>${__RESET_COLOR} to easily change directory -- see ${__HELP_EXAMPLE}<https://github.com/clvv/fasd>${__RESET_COLOR}."
      echo "%"
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- ${__HELP_EXAMPLE}v <file>${__RESET_COLOR} to easily edit recently file with vi -- see ${__HELP_EXAMPLE}<https://github.com/clvv/fasd>${__RESET_COLOR}."
      echo "%"
    else
      echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- Think about installing ${__HELP_EXAMPLE}fasd${__RESET_COLOR} to easily switch directory - run ${__HELP_EXAMPLE}installAndConfigure Fasd${__RESET_COLOR}."
      echo "%"
    fi
  fi
}

isUbuntuMinimum24() {
  Version::compare "${VERSION_ID}" "24.04"
}

install() {
  if ! isUbuntuMinimum24; then
    Linux::Apt::addRepository ppa:aacebedo/fasd
  fi
  SKIP_APT_GET_UPDATE=1 Linux::Apt::installIfNecessary --no-install-recommends \
    fasd
}

testInstall() {
  local -i failures=0
  Assert::commandExists fasd || ((++failures))
  return "${failures}"
}

configure() {
  # shellcheck disable=SC2154
  Conf::copyStructure \
    "${embed_dir_conf_dir}" \
    "${CONF_OVERRIDE_DIR}/$(scriptName)" \
    ".bash-dev-env"
}
testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/fasd.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/completions.d/fasd.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fasd.bash" || ((++failures))
  return "${failures}"
}
