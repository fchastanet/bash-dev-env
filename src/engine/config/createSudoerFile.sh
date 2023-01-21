#!/bin/bash

# set sudoer without password temporarily
engine::config::createSudoerFile() {
  local sudoerFile="/etc/sudoers.d/${USER_NAME}-bash-dev-env-no-password"

  # create /etc/sudoers.d/userName-bash-dev-env
  SUDOER_CHANGE="${USER_NAME} ALL=(ALL) NOPASSWD: ${ROOT_DIR}/install,/etc/cron.weekly/upgrade,/usr/sbin/service,${ROOT_DIR}/scripts/*/configure"
  if [[ "${SUDOER_CHANGE}" != "$(sudo cat "${sudoerFile}" 2>/dev/null || echo -n '')" ]]; then
    echo "${SUDOER_CHANGE}" | sudo tee "${sudoerFile}"
    sudo chmod 0440 "${sudoerFile}"

    echo "this file indicates that sudo has been configured to execute without password" |
      sudo tee "${USER_HOME}/.cron_activated" >/dev/null

    sudo visudo -c -s || {
      Log::displayError "Please check syntax of '${sudoerFile}' before closing this session - 'sudo visudo'"
      return 1
    }
  fi
}
