#!/usr/bin/env zsh

# in zsh motd is not triggered automatically as in bash we have to manage it manually
# don't display Motd if .hushlogin exists or MOTD was shown recently
if [[ ! -e "${HOME}/.hushlogin" ]] &&
  ! find "$HOME/.motd_shown" -newermt 'today 0:00' 2>/dev/null | grep -q -m 1 '.'; then
  if [[ "$(id -u)" = "0" ]]; then
    update-motd
  else
    update-motd --show-only
  fi
  touch "$HOME/.motd_shown"
fi
