# @description create sudoer file and add traps to remove it at the end
# @arg $1 sudoerFile:String the file path to create
# @env USERNAME
# shellcheck disable=SC2317
local sudoerFile="${SUDOER_FILE_PREFIX}/etc/sudoers.d/bash-dev-env-no-password"
if [[ -f "${sudoerFile}" ]]; then
  # sudoerFile probably already managed by parent script
  true
else
  cleanSudoer() {
    if [[ -f "${sudoerFile}" ]]; then
      ${SUDO:-sudo} rm -f "${sudoerFile}" || true
    fi
  }
  trap cleanSudoer EXIT HUP QUIT ABRT TERM

  Log::displayInfo "Creating sudoer file"
  echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" |
    ${SUDO:-sudo} tee "${sudoerFile}" >/dev/null
  ${SUDO:-sudo} chmod 0440 "${sudoerFile}"
fi
