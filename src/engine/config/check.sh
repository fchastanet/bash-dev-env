#!/bin/bash

engine::config::check() {
  local envFile="$1"

  # check if ubuntu
  # load environment variables ID, VERSION_CODENAME
  engine::config::loadOsRelease
  if ! echo "${ID}" | grep -qEw 'debian|ubuntu'; then
    Log::fatal "This script is built to support only Debian or Ubuntu distributions. You are using ${ID}."
  fi

  ((errorCount = 0)) || true
  # shellcheck disable=SC2153
  if ! Assert::varExistsAndNotEmpty "USER_NAME"; then
    ((errorCount++))
  elif ! getent passwd "${USER_NAME}" 2>/dev/null >/dev/null; then
    Log::displayError "USER_NAME - user '${USER_NAME}' does not exist"
    ((errorCount++))
  fi

  # GIT_USER_NAME
  if ! Assert::varExistsAndNotEmpty "GIT_USER_NAME"; then
    ((errorCount++))
  elif ! Assert::firstNameLastName "${GIT_USER_NAME}"; then
    Log::displayError "GIT_USER_NAME - invalid format, expected : firstName lastName"
    ((errorCount++))
  fi

  # GIT_USER_MAIL
  if ! Assert::varExistsAndNotEmpty "GIT_USER_MAIL"; then
    ((errorCount++))
  elif ! Assert::emailAddress "${GIT_USER_MAIL}"; then
    Log::displayError "GIT_USER_MAIL: invalid email address"
    ((errorCount++))
  fi

  # PROJECTS_DIR
  if ! Assert::varExistsAndNotEmpty "PROJECTS_DIR"; then
    ((errorCount++))
  elif [[ ! -d "${PROJECTS_DIR}" ]]; then
    if ! mkdir -p "${PROJECTS_DIR}"; then
      Log::displayError "PROJECTS_DIR - impossible to create the directory '${PROJECTS_DIR}'"
      ((errorCount++))
    fi
  fi

  # CONF_DIR
  if ! Assert::varExistsAndNotEmpty "CONF_DIR"; then
    ((errorCount++))
  elif [[ ! -d "${CONF_DIR}" ]]; then
    Log::displayError "CONF_DIR - directory does not exist '${CONF_DIR}'"
    ((errorCount++))
  elif [[ ! -r "${CONF_DIR}" ]]; then
    Log::displayError "CONF_DIR - directory '${CONF_DIR}' is not accessible"
    ((errorCount++))
  fi

  # INSTALL_SCRIPTS_DIR
  if ! Assert::varExistsAndNotEmpty "INSTALL_SCRIPTS_DIR"; then
    ((errorCount++))
  elif [[ ! -d "${INSTALL_SCRIPTS_DIR}" ]]; then
    Log::displayError "INSTALL_SCRIPTS_DIR - directory does not exist '${INSTALL_SCRIPTS_DIR}'"
    ((errorCount++))
  elif [[ ! -r "${INSTALL_SCRIPTS_DIR}" ]]; then
    Log::displayError "INSTALL_SCRIPTS_DIR - directory '${INSTALL_SCRIPTS_DIR}' is not accessible"
    ((errorCount++))
  fi

  # BACKUP_DIR
  if ! Assert::varExistsAndNotEmpty "BACKUP_DIR"; then
    ((errorCount++))
  elif [[ ! -d "${BACKUP_DIR}" ]]; then
    mkdir -p "${BACKUP_DIR}" || Log::displayError "BACKUP_DIR - backup dir ${BACKUP_DIR} cannot be created"
    ((errorCount++))
  elif [[ ! -w "${BACKUP_DIR}" ]]; then
    Log::displayError "BACKUP_DIR - backup dir ${BACKUP_DIR} is not writable"
    ((errorCount++))
  fi

  if ((errorCount > 0)); then
    Log::displayError "one or more variables are invalid, check above logs and fix ${envFile} file accordingly"
    return 1
  fi
}
