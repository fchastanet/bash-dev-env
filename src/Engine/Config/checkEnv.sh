#!/bin/bash

# @description check validity of .env variables
# @env CHECK_ENV int 0 to avoid checking environment
# @noargs
Engine::Config::checkEnv() {
  if [[ "${CHECK_ENV:-1}" = "0" ]]; then
    return 0
  fi
  local errorCount=0 || true
  checkNotEmpty() {
    local var="$1"
    if ! Assert::varExistsAndNotEmpty "${var}"; then
      ((++errorCount))
      return 1
    fi
  }
  checkVarAndDir() {
    local var="$1"
    local mode="${2:-}"
    local status=0
    if checkNotEmpty "${var}"; then
      if ! mkdir -p "${!var}"; then
        Log::displayError "variable ${var} - impossible to create the directory '${!var}'"
        ((errorCount++))
        return 1
      fi
      if [[ "${mode}" =~ w && ! -w "${!var}" ]]; then
        Log::displayError "variable ${var} - directory '${!var}' is not writable"
        ((status++))
        ((errorCount++))
      fi
      if [[ "${mode}" =~ r && ! -r "${!var}" ]]; then
        Log::displayError "variable ${var} - directory '${!var}' is not accessible"
        ((status++))
        ((errorCount++))
      fi
    fi

    return "${status}"
  }
  checkValidValues() {
    local var="$1"
    shift || true
    local -a validValues=("$@")
    if ! Array::contains "${!var}" "${validValues[@]}"; then
      Log::displayError "variable ${var} - value ${!var} is not part of the following values ${validValues[*]}"
      ((++errorCount))
    fi
  }

  if ! echo "${ID}" | grep -qEw 'debian|ubuntu'; then
    Log::fatal "This script is built to support only Debian or Ubuntu distributions. You are using ${ID}."
  fi

  if checkNotEmpty USERNAME && ! getent passwd "${USERNAME}" 2>/dev/null >/dev/null; then
    Log::displayError "USERNAME - user '${USERNAME}' does not exist"
    ((errorCount++))
  fi

  if [[ -n "${SSH_LOGIN:-}" ]] && ! Assert::ldapLogin "${SSH_LOGIN}"; then
    Log::displayError "SSH_LOGIN - invalid ldap login (format expected firstNameLastName) in ${BASH_DEV_ENV_ROOT_DIR}/.env file"
    ((errorCount++))
  fi

  if checkNotEmpty "GIT_USERNAME" && ! Assert::firstNameLastName "${GIT_USERNAME}"; then
    Log::displayError "GIT_USERNAME - invalid format, expected : firstName lastName"
    ((errorCount++))
  fi

  if checkNotEmpty "GIT_USER_MAIL" && ! Assert::emailAddress "${GIT_USER_MAIL}"; then
    Log::displayError "GIT_USER_MAIL - invalid email address"
    ((errorCount++))
  fi

  if checkNotEmpty "AWS_USER_MAIL" && ! Assert::emailAddress "${AWS_USER_MAIL}"; then
    Log::displayError "AWS_USER_MAIL - invalid email address"
    ((errorCount++))
  fi

  checkVarAndDir CONF_DIR r || true
  checkVarAndDir CONF_OVERRIDE_DIR r || true
  checkVarAndDir PROJECTS_DIR r || true
  checkVarAndDir BACKUP_DIR rw || true
  checkVarAndDir LOGS_DIR rw || true
  checkVarAndDir INSTALL_SCRIPTS_DIR r || true
  checkVarAndDir USER_HOME rw || true

  checkValidValues UPGRADE_UBUNTU_VERSION 0 lts dev
  checkValidValues AWS_AUTHENTICATOR Saml2Aws Awsume
  checkValidValues PREFERRED_SHELL ShellBash ShellZsh

  checkValidValues SHOW_FORTUNES 0 1
  checkValidValues SHOW_MOTD 0 1
  checkValidValues DOCKER_INSIDE_WSL 0 1
  checkValidValues OVERWRITE_CONFIG_FILES 0 1
  checkValidValues CHANGE_WINDOWS_FILES 0 1
  checkValidValues CAN_TALK_DURING_INSTALLATION 0 1
  checkValidValues INSTALL_INTERACTIVE 0 1

  checkNotEmpty WSLCONFIG_MAX_MEMORY
  checkValidValues WSLCONFIG_SWAP 0 1

  return "${errorCount}"
}
