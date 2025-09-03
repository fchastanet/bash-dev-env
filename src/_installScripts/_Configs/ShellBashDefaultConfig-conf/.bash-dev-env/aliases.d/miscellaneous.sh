#!/bin/bash
###############################################################################
# DO NOT EDIT, THIS FILE CAN BE UPDATED WITHOUT NOTICE
###############################################################################

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ps aliases
alias ps_full_command='ps -efww'
alias top5='ps aux --sort=-pcpu | head -n 5'

function help() {
  curl "cht.sh/$1"
}
alias help='help'

if [[ "$(uname -o)" = "GNU/Linux" ]]; then
  export BROWSER="/mnt/c/Windows/explorer.exe"
  alias view='explorer.exe'
fi
