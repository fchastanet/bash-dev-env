#!/bin/bash
###############################################################################
# AVOID EDITING THIS FILE
# PREFER to add files in dedicated sections of ~/.bash-dev-env
# CHECK ~/.bash-dev-env/README.md
###############################################################################

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# ~/.profile (Gets evaluated only in graphical-session)
# For slow-evaluation environment variables and with no-bashism
# for your user-only and all graphical-session processes.
# It gets loaded upon login in your graphical UI.

# Gets evaluated in specific occasion only
# For slow-evaluation environment variable and code for your user-only and console-session processes.
# bashism are welcome. It gets loaded on:
# - console login (Ctrl-Alt F1),
# - ssh logins to this machine,
# - tmux new pane or windows (default settings), (not screen !)
# - explicit calls of bash -l,
# - any bash instance in a graphical console client
#   (terminator/gnome-terminal...) only if you tick option
#   "run command as login shell".

# load bash-tools variables
if [[ -f "${HOME}/.bash-tools/.env" ]]; then
  #shellcheck source=/dev/null
  source "${HOME}/.bash-tools/.env"
fi

# load bash-dev-env variables
if [[ -f "${HOME}/fchastanet/bash-dev-env/.env" ]]; then
  #shellcheck source=.env.template
  source "${HOME}/fchastanet/bash-dev-env/.env"
fi

loadConfigFiles() {
  local dir="$1"
  local script_shell
  script_shell="$(readlink /proc/$$/exe | sed "s/.*\///")" # bash or zsh
  local -a extensions=(sh "${script_shell}")
  local file
  while IFS= read -r file; do
    # shellcheck source=src/_installScripts/_Defaults/MandatorySoftwares-conf/.bash-dev-env/aliases.d/bash-dev-env.sh
    source "${file}"
  done < <(
    "${HOME}/.bash-dev-env/findConfigFiles" \
      "${dir}" "${extensions[@]}" || echo
  )
}
loadConfigFiles "${HOME}/.bash-dev-env/profile.d"

# include .bashrc if it exists and if running bash
if [[ -n "${BASH_VERSION}" && -f "${HOME}/.bashrc" ]]; then
  #shellcheck source=src/_installScripts/_Configs/ShellBashDefaultConfig-conf/home/.bashrc
  source "${HOME}/.bashrc"
fi
