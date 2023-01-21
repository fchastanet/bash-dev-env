#!/bin/bash

engine::config::loadConfig() {
  local envFile="$1"

  # shellcheck source=/.env.template
  source "${envFile}"

  export USER_NAME
  export GIT_USER_NAME
  export GIT_USER_MAIL
  export CONF_DIR
  export CONF_OVERRIDE_DIR
  export PROJECTS_DIR
  export BACKUP_DIR
  export LOGS_DIR
  export SCRIPTS_DIR
  export UPGRADE_UBUNTU_VERSION
  export AWS_AUTHENTICATOR
  export PREFERRED_SHELL
  export SHOW_FORTUNES
  export SHOW_MOTD
  export DOCKER_INSIDE_WSL
  export OVERWRITE_CONFIG_FILES
  export CHANGE_WINDOWS_FILES
  export CAN_TALK_DURING_INSTALLATION
  export NON_INTERACTIVE
  export WSLCONFIG_MAX_MEMORY
  export WSLCONFIG_SWAP
  export POWERSHELL_BIN

  engine::config::loadUserVariables
}
