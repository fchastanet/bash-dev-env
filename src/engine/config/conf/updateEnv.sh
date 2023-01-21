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

# ensure /mnt/c/WINDOWS/system32 is available for root user
if command -v wslpath &>/dev/null; then
  PATH="${PATH}:${BASE_MNT_C}/WINDOWS/system32"
fi

export ROOT_DIR="@DEV_ENV_ROOT_DIR@"
if [[ -f "${ROOT_DIR}/.env" ]]; then
  set -o allexport
  # shellcheck source=/.env.template
  source "${ROOT_DIR}/.env"
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

if [[ "$(id -u)" = "0" ]]; then
  return 0
fi

###############################################################################"
# USER Config
###############################################################################"
# PATH config
###############################################################################"

if command -v wslpath &>/dev/null; then
  # backup visual studio code path
  if command -v code &>/dev/null; then
    codePathBackup="$(dirname "$(command -v code)")"
  fi
  # optimize PATH to remove all windows PATH not needed to optimize completion
  C_DRIVE="/mnt/c"
  if [[ -d "${C_DRIVE}" ]]; then
    PATH=$(echo "${PATH}" |
      awk -v RS=: -v ORS=: "/^${C_DRIVE//\//\\/}/ {next} {print}" | sed 's/:*$//')
  fi
  # Add C:\Windows back so you can do `explorer.exe .` to open an explorer at current directory
  WINDOWS_PROFILE_DIR="@@@WINDOWS_PROFILE_DIR@@@"
  export WINDOWS_PROFILE_DIR
  PATH="${PATH}:${C_DRIVE}/Windows"
  PATH="${PATH}:${WINDOWS_PROFILE_DIR}/AppData/Local/Microsoft/WindowsApps"
  # Add powershell path back
  PATH="${PATH}:${C_DRIVE}/WINDOWS/System32/WindowsPowerShell/v1.0/"
  # Add visual studio code path back
  PATH="${PATH}:${codePathBackup}"
  unset codePathBackup
fi

addPath() {
  if [[ -d "$1" && ":${PATH}:" != *":$1:"* ]]; then
    if [[ "$2" = "after" ]]; then
      PATH="${PATH}:$1"
    else
      PATH="$1:${PATH}"
    fi
  fi
}

# set PATH so it includes user's private bin if it exists
addPath "${HOME}/projects/bash-tools/bin"
addPath "${HOME}/.local/bin"
addPath "${HOME}/.bin"

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
