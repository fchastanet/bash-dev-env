#!/usr/bin/env bash

helpDescription() {
  echo "A framework for managing and maintaining multi-language pre-commit hooks."
}

dependencies() {
  # pre-commit is a python package
  echo "installScripts/Python"
}

fortunes() {
  echo -e "${__INFO_COLOR}$(scriptName)${__RESET_COLOR} -- if ${__HELP_EXAMPLE}.pre-commit-config.yaml${__RESET_COLOR} file is present, "
  echo -e "${__HELP_EXAMPLE}pre-commit${__RESET_COLOR} will run automatically the tools specified before the commit."
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
# jscpd:ignore-end

install() {
  if [[ ! -f "${HOME}/.venvs/python3/bin/activate" ]]; then
    Log::displayError "VirtualEnv has not been installed correctly"
    return 1
  fi
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate"

  pip install pre-commit
  # update precommit repo
  export PATH="${PATH}:${HOME}/.local/bin"
  pre-commit gc
}

testInstall() {
  local -i failures=0
  # Load virtualenv
  # shellcheck source=/dev/null
  source "${HOME}/.venvs/python3/bin/activate" || ((++failures))
  Version::checkMinimal "pre-commit" "--version" "3.6.2" || ((++failures))
  return "${failures}"
}
