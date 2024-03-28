#!/usr/bin/env bash
# BIN_FILE=${BASH_DEV_ENV_ROOT_DIR}/installScripts/ConformanceTest
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# FACADE
# IMPLEMENT InstallScripts::interface

.INCLUDE "$(dynamicTemplateDir "_binaries/installScripts/_installScript.tpl")"

scriptName() {
  echo "ConformanceTest"
}

helpDescription() {
  echo "ConformanceTest checks that environnement prerequisites are set correctly"
  echo "It checks also validity of .env file content"
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
  Log::displayInfo "Linux version : $(lsb_release -a)"

  id1000Reason="it can cause you issues when using some docker applications as some group ids are already set to 1001 in these docker images."
  if [[ "$(id -u "${USERNAME}")" != "1000" ]]; then
    Log::fatal "User ${USERNAME} should have user id 1000, ${id1000Reason}"
  fi

  if [[ "$(id -g "${USERNAME}")" != "1000" ]]; then
    Log::fatal "User ${USERNAME} should have group id 1000, ${id1000Reason}"
  fi

  if ! getent passwd "${USERNAME}" &>/dev/null; then
    Log::fatal "User ${USERNAME} does not exist"
  fi

  if [[ "$(getent passwd "${USERNAME}" | cut -d: -f6)" != "${USER_HOME}" ]]; then
    Log::fatal "Specified User home '${USER_HOME}' of ${USERNAME} is incorrect."
  fi

  if Assert::wsl &&
    [[ "${DOCKER_INSIDE_WSL}" = "0" ]] &&
    Array::contains "Docker" "$@" &&
    ! command -v docker &>/dev/null; then
    Log::fatal "Please check that you installed docker for windows and you associated this wsl distribution with it"
  fi
}

configure() {
  install "$@"
}

testInstall() {
  install "$@"
}

testConfigure() {
  install "$@"
}
