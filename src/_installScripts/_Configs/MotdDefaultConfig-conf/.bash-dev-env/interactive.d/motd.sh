#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# deactivate motd if needed
if [[ -o login ]]; then
  if [[ "${SHOW_MOTD}" = "1" ]]; then
    if [[ -f "${HOME}/.hushlogin" ]]; then
      rm -f "${HOME}/.hushlogin" &>/dev/null || true
      echo "You just activated Motd, Motd will be shown next time"
    fi
  elif [[ ! -f "${HOME}/.hushlogin" ]]; then
    echo "You just deactivated Motd, Motd will be hidden next time"
    touch "${HOME}/.hushlogin"
  fi
fi
