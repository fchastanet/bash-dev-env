#!/bin/bash

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# ~/.profile (Gets evaluated only in graphical-session)
# For slow-evaluation environment variables and with no-bashism
# for your user-only and all graphical-session processes.
# It gets loaded upon login in your graphical UI.

# execute bash logout when bash window is closed
exitSession() {
  #shellcheck source=/conf/bash_profile/.bash_logout
  source "${HOME}/.bash_logout"
}
trap exitSession HUP

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    # sudo apt install bash-completion
    source /etc/bash_completion
  fi
fi

#shellcheck source=/conf/bash_profile/.bash_prompt
[[ -f "${HOME}/.bash_prompt" ]] && source "${HOME}/.bash_prompt"

#shellcheck source=/conf/bash_profile/.bash_completion
[[ -f "${HOME}/.bash_completion" ]] && source "${HOME}/.bash_completion"

#shellcheck source=/dev/null
[[ -f "${HOME}/.bin/tmuxinator.bash" ]] && source "${HOME}/.bin/tmuxinator.bash"

# kubeps1
if [[ -f /opt/kubeps1/kube-ps1.sh ]]; then
  #shellcheck source=/dev/null
  source /opt/kubeps1/kube-ps1.sh
  PS1='[\u@\h \W $(kube_ps1)]\$ '
fi

# if running bash
if [[ -n "${BASH_VERSION}" ]]; then
  # include .bashrc if it exists
  if [[ -f "${HOME}/.bashrc" ]]; then
    #shellcheck source=/dev/null
    source "${HOME}/.bashrc"
  fi
fi
