#!/bin/bash

###############################################################################
# !!!!!!!!!!!!!!!!! PLEASE DO NOT MODIFY THIS FILE MANUALLY !!!!!!!!!!!!!!!!!!!
###############################################################################
# ROOT & USER VARIABLES
###############################################################################

# will instruct user .bashrc to load that file if this variable is not set
export ETC_PROFILE_D_UPDATE_ENV_LOADED=1

# shellcheck disable=SC1003
BASE_MNT_C="$(mount | grep 'path=C:\\' | awk -F ' ' '{print $3}')"

export BASH_DEV_ENV_ROOT_DIR="@@@BASH_DEV_ENV_ROOT_DIR@@@"
if [[ -f "${BASH_DEV_ENV_ROOT_DIR}/.env" ]]; then
  set -o allexport
  # shellcheck source=/.env.template
  source "${BASH_DEV_ENV_ROOT_DIR}/.env"
  set +o allexport
fi

# Set Qt5 applications to use the Gtk+ 2 style
export QT_QPA_PLATFORMTHEME=gtk2

# used by docker-sync
export DOCKER_HOST="unix:///var/run/docker.sock"

export EDITOR='vim'
export LC_TIME=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export IBUS_ENABLE_SYNC_MODE=1
export PATH

addPath() {
  if [[ -d "$1" && ":${PATH}:" != *":$1:"* ]]; then
    if [[ "$2" = "after" ]]; then
      PATH="${PATH}:$1"
    else
      PATH="$1:${PATH}"
    fi
  fi
}
# ensure /mnt/c/WINDOWS/system32 is available for root user
addPath "${BASE_MNT_C}/WINDOWS/System32" "after"

if [[ "$(id -u)" = "0" ]]; then
  return 0
fi

###############################################################################"
# USER Config
###############################################################################"
# PATH config
###############################################################################"

# backup visual studio code path
if command -v code &>/dev/null; then
  codePathBackup="$(dirname "$(command -v code)")"
fi
# optimize PATH to remove all windows PATH not needed to optimize completion
if [[ -d "${BASE_MNT_C}" ]]; then
  PATH=$(echo "${PATH}" |
    awk -v RS=: -v ORS=: "/^${BASE_MNT_C//\//\\/}/ {next} {print}" | sed 's/:*$//')
fi
# Add C:\Windows back so you can do `explorer.exe .` to open an explorer at current directory
WINDOWS_PROFILE_DIR="@@@WINDOWS_PROFILE_DIR@@@"
export WINDOWS_PROFILE_DIR
addPath "${BASE_MNT_C}/WINDOWS/System32" "after"
addPath "${BASE_MNT_C}/Windows" "after"
addPath "${WINDOWS_PROFILE_DIR}/AppData/Local/Microsoft/WindowsApps" "after"
# Add powershell path back
addPath "${BASE_MNT_C}/WINDOWS/System32/WindowsPowerShell/v1.0/" "after"
# Add visual studio code path back
addPath "${codePathBackup}" "after"
unset codePathBackup

# set PATH so it includes user's private bin if it exists
addPath "${HOME}/projects/bash-tools/bin" "after"
addPath "${HOME}/.local/bin" "after"
addPath "${HOME}/.bin" "after"

# Add composer bin path
addPath "/usr/local/.composer/vendor/bin" "after"

# Add Go bin PATH
addPath "${HOME}/go/bin" "after"

addPath "/usr/games" "after"
addPath "/usr/local/games" "after"

# node installed using n
# Added by n-install (see http://git.io/n-install-repo).
if [[ -d "${HOME}/n" ]]; then
  export N_PREFIX="${HOME}/n"
  addPath "${N_PREFIX}/bin" "after"
fi
addPath "${HOME}/.npm-global/bin" "after"

# activate python 3.9 virtualenv
export PIP_REQUIRE_VIRTUALENV=true
export WORKON_HOME="${HOME}/.virtualenv"
export PIP_DOWNLOAD_CACHE="${HOME}/.pip/cache"
if [[ -f "${HOME}/.virtualenv/python3.9/bin/activate" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.virtualenv/python3.9/bin/activate"
fi

# kubectx and kubens
addPath "/opt/kubectx" "after"

export PATH

###############################################################################"
# Env variables
###############################################################################"

# composer home
export COMPOSER_HOME=/usr/local/.composer

# disable beep in less
export LESS="${LESS} -R -Q"

# display docker build progress
export BUILDKIT_PROGRESS=plain

# disable docker build kit as unstable for now
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

# make global node packages available for node js scripts
if command -v npm >/dev/null 2>&1; then
  NODE_PATH=$(npm root --quiet -g)
  export NODE_PATH
fi