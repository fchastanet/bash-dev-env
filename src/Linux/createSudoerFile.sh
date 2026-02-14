#!/usr/bin/env bash

# @description create sudoer file and add traps to remove it at the end
# @env SUDOER_FILE the sudoer file (default: /etc/sudoers.d/bash-dev-env-no-password)
# @env SUDO the sudo command (default: sudo)
# @env USERNAME the username to add as sudoer
# shellcheck disable=SC2317
Linux::createSudoerFile() {
  local sudoerFile="${SUDOER_FILE:-/etc/sudoers.d/bash-dev-env-no-password}"
  if [[ -f "${sudoerFile}" ]] || ${SUDO:-sudo} test -f "${sudoerFile}"; then
    # sudoerFile probably already managed by parent script
    true
  else
    # shellcheck disable=SC2329
    cleanSudoer() {
      local rc=$?
      if [[ -f "${sudoerFile}" ]]; then
        ${SUDO:-sudo} rm -f "${sudoerFile}" || true
      fi
      exit "${rc}"
    }
    trap cleanSudoer EXIT HUP QUIT ABRT TERM

    Log::displayInfo "Creating sudoer file"
    echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" |
      ${SUDO:-sudo} tee "${sudoerFile}" >/dev/null
    ${SUDO:-sudo} chmod 0440 "${sudoerFile}"
  fi
}
