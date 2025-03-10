#!/usr/bin/env bash
# @embed "${BASH_DEV_ENV_ROOT_DIR}/src/_installScripts/BashUtils/Fasd-conf" as conf_dir

helpDescription() {
  echo "$(scriptName) - configuration for bash shell only allowing to search files quickly"
}

helpLongDescription() {
  helpDescription
  echo "Following aliases are available:"
  echo "  - alias 'a' - search files/directories based on a pattern"
  echo "  - alias 'd' - search directories based on a pattern"
  echo "  - alias 'f' - search files based on a pattern"
  echo "  - alias 'si' - search most used files/directories in interactive mode(index)"
  echo "  - alias 'sid' - search most used directories in interactive mode(index)"
  echo "  - alias 'sif' - search most used files in interactive mode(index)"
  echo "  - alias 'z' - allows to switch to the directory matching the most the given pattern"
  echo "  - alias 'zz' - allows to select interactively one of the most used directory by index"
}

isBash() {
  [[ "${USER_SHELL}" = "/bin/bash" || "${USER_SHELL}" = "/usr/bin/bash" ]]
}

fortunes() {
  if isBash; then
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

# jscpd:ignore-start
dependencies() { :; }
listVariables() { :; }
helpVariables() { :; }
defaultVariables() { :; }
checkVariables() { :; }
breakOnConfigFailure() { :; }
breakOnTestFailure() { :; }
# jscpd:ignore-end

install() {
  if ! Version::isUbuntuMinimum "24.04"; then
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
    "$(fullScriptOverrideDir)" \
    ".bash-dev-env"
}

testConfigure() {
  local -i failures=0
  Assert::fileExists "${HOME}/.bash-dev-env/aliases.d/fasd.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/completions.d/fasd.bash" || ((++failures))
  Assert::fileExists "${HOME}/.bash-dev-env/interactive.d/fasd.bash" || ((++failures))
  return "${failures}"
}
