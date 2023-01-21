#!/bin/bash

engine::config::initGlobalEnv() {
  # initialize environment variables globally
  if [[ "${INSTALL_UPDATE_ENV:-1}" = "1" ]]; then
    # INSTALL_UPDATE_ENV avoids infinite loop, use a light loadConfig without installUpdateEnv
    installUpdateEnv "${CONF_DIR}" "${LDAP_LOGIN}" "${WINDOWS_PROFILE_DIR}"
  fi
}
