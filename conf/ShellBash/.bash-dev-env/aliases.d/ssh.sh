#!/bin/bash

sshKillAllTunnel() {
  if [[ "$(uname -o)" = "Msys" ]]; then
    # git bash: no way to get full process command, just kill all ssh processes
    # shellcheck disable=SC2009
    ps a | grep '/usr/bin/ssh' | grep -v 'grep ' | awk -F " " '{print $1}' | xargs -t --no-run-if-empty kill
  else
    pgrep -f 'ssh.*-L' | xargs -t --no-run-if-empty kill
  fi
}
alias ssh_kill_all_tunnel='sshKillAllTunnel'
