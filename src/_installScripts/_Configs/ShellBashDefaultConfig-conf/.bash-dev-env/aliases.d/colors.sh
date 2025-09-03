#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# enable color support of ls and also add handy aliases
if [[ -o login && -x /usr/bin/dircolors && -r "${HOME}/.dir_colors" ]]; then
  eval "$(dircolors -b "${HOME}/.dir_colors")"
  alias ls='ls -F --color=auto --show-control-chars'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi
