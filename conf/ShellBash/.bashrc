#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# Gets evaluated in all occasion
# For fast-evaluation environment variable and code for your user-only
# and bash-only command-line usage (aliases for instance). bashism are welcome.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

if [[ "${ETC_PROFILE_D_UPDATE_ENV_LOADED-0}" != "1" ]]; then
  source ${HOME}/.bash-dev-env
fi

# If running interactively
if [[ "$-" =~ .*i.* ]]; then
  # make less more friendly for non-text input files, see lesspipe(1)
  [[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

  # set variable identifying the chroot you work in (used in the prompt below)
  if [[ -z "${debian_chroot:-}" && -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
  fi

  # set a fancy prompt (non-color, unless we know we "want" color)
  if [[ "${TERM}" =~ xterm-color|*-256color ]]; then
    color_prompt=yes
  fi

  # uncomment for a colored prompt, if the terminal has the capability; turned
  # off by default to not distract the user: the focus in a terminal window
  # should be on the output of commands, not on the prompt
  force_color_prompt=yes

  if [[ -n "${force_color_prompt}" ]]; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
      # We have color support; assume it's compliant with Ecma-48
      # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
      # a case would tend to support setf rather than setaf.)
      color_prompt=yes
    else
      color_prompt=
    fi
  fi

  if [[ "${color_prompt}" = yes ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
  fi
  unset color_prompt force_color_prompt

  # If this is an xterm set the title to user@host:dir
  if [[ "${TERM}" =~ xterm*|rxvt* ]]; then
    PS1="\[\e]0;${debian_chroot:+(${debian_chroot})}\u@\h: \w\a\]${PS1}"
  fi

  # fasd
  if command -v fasd &>/dev/null; then
    fasd_cache="${HOME}/.fasd-init-bash"
    if [[ "$(command -v fasd)" -nt "${fasd_cache}" || ! -s "${fasd_cache}" ]]; then
      fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >|"${fasd_cache}"
    fi
    # shellcheck source=/dev/null
    source "${fasd_cache}"
    unset fasd_cache
  fi

  # kubeps1
  if [[ -f /opt/kubeps1/kube-ps1.sh ]]; then
    source /opt/kubeps1/kube-ps1.sh
    PS1='[\u@\h \W $(kube_ps1)]\$ '
  fi

  # shellcheck source=conf/bash_profile/.aliases
  [[ -f "${HOME}/.aliases" ]] && source "${HOME}/.aliases"

  # load bash_completion
  # shellcheck source=conf/bash_profile/.bash_completion
  [[ -f "${HOME}/.bash_completion" ]] && source "${HOME}/.bash_completion"

  # awsume
  if command -v awsume &>/dev/null; then
    #AWSume alias to source the AWSume script
    alias awsume="source awsume"

    #Auto-Complete function for AWSume
    _awsume() {
      local cur opts
      COMPREPLY=()
      cur="${COMP_WORDS[COMP_CWORD]}"
      opts=$(awsume-autocomplete)
      # shellcheck disable=SC2086,SC2207
      COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
      return 0
    }
    complete -F _awsume awsume
  fi

  # start cron service
  if [[ -f "${HOME}/.cron_activated" ]]; then
    service anacron start
  fi

  if [[ -f "${HOME}/.bash_prompt" ]]; then
    # shellcheck source=conf/bash_profile/.bash_prompt
    source "${HOME}/.bash_prompt"
  fi
  # shellcheck source=conf/bash_profile/.bash_navigation
  [[ -f "${HOME}/.bash_navigation" ]] && source "${HOME}/.bash_navigation"

  # deactivate motd if needed
  if [[ "${SHOW_MOTD}" = "1" ]]; then
    if [[ -f "${HOME}/.hushlogin" ]]; then
      rm -f "${HOME}/.hushlogin" &>/dev/null || true
      echo "You just activated Motd, Motd will be shown next time"
    fi
  else
    if [[ ! -f "${HOME}/.hushlogin" ]]; then
      echo "You just deactivated Motd, Motd will be hidden next time"
    fi
    touch "${HOME}/.hushlogin"
  fi

  # display fortune
  if [[ -f /etc/fortune-help-commands.dat && "${SHOW_FORTUNES}" = "1" ]]; then
    randomAnimal="$(find /usr/share/cowsay/cows -type f | shuf -n 1 | sed -E -e 's#^.+/([^/.]+)\.cow$#\1#')"
    fortune /etc/fortune-help-commands | cowsay -f "${randomAnimal}" | lolcat -s 600
  fi

  # fzf
  if [[ -f /opt/fzf/shell/key-bindings.bash ]]; then
    source /opt/fzf/shell/key-bindings.bash
  fi
  if [[ -f /opt/fzf/shell/completion.bash ]]; then
    source /opt/fzf/shell/completion.bash
  fi

fi

###############################################################################"
# Env variables PATH & NODE & ...
###############################################################################"
# check ${HOME}/.bash-dev-env

# be sure it ends without any error code
true
