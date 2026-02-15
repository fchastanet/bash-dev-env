#!/bin/bash

# @description install or update "${HOME}/.bash-dev-env" file
# @env WINDOWS_PROFILE_DIR
# @env BASH_DEV_ENV_ROOT_DIR
# @env HOME
Engine::Config::installBashDevEnv() {
  Log::displayInfo "Creating file '${HOME}/.bash-dev-env/profile.d/00_init.sh'"
  ${SUDO:-} rm -f "${HOME}/.bash-dev-env/profile.d/00_init.sh" || true
  if ! ${SUDO:-} test -d "${HOME}/.bash-dev-env/profile.d"; then
    ${SUDO:-} mkdir -p "${HOME}/.bash-dev-env/profile.d"
  fi
  (
    echo '#!/bin/bash'
    echo "export BASH_DEV_ENV_ROOT_DIR='${BASH_DEV_ENV_ROOT_DIR}'"
    echo "export WINDOWS_PROFILE_DIR='${WINDOWS_PROFILE_DIR}'"
    echo "export SSH_LOGIN='${SSH_LOGIN}'"
  ) | ${SUDO:-} tee "${HOME}/.bash-dev-env/profile.d/00_init.sh" >/dev/null
  ${SUDO:-} chmod +x "${HOME}/.bash-dev-env/profile.d/00_init.sh"
}
