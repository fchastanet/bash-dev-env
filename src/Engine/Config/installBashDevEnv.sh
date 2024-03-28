#!/bin/bash

# @description install or update "${USER_HOME}/.bash-dev-env" file
# @env WINDOWS_PROFILE_DIR
# @env BASH_DEV_ENV_ROOT_DIR
# @env USER_HOME
# EMBED "${BASH_DEV_ENV_ROOT_DIR}/home/.bash-dev-env" as bashDevEnv
Engine::Config::installBashDevEnv() {
  # shellcheck disable=SC2317
  bashDevEnvConfig() {
    sed -E -i \
      -e "s#BASH_DEV_ENV_ROOT_DIR=.*\$#BASH_DEV_ENV_ROOT_DIR=${BASH_DEV_ENV_ROOT_DIR}#g" \
      -e "s#WINDOWS_PROFILE_DIR=.*\$#WINDOWS_PROFILE_DIR=${WINDOWS_PROFILE_DIR}#g" \
      "${USER_HOME}/.bash-dev-env"
    sudo ln -sf "${USER_HOME}/.bash-dev-env" /root/.bash-dev-env
  }
  local fileToInstall
  # shellcheck disable=SC2154
  fileToInstall="$(Conf::dynamicConfFile "home/.bash-dev-env" "${embed_file_updateEnv}")" || return 1
  OVERWRITE_CONFIG_FILES=1 Install::file \
    "${fileToInstall}" "${USER_HOME}/.bash-dev-env" \
    "${USERNAME}" "${USERGROUP}" bashDevEnvConfig  
}
