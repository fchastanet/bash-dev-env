#!/bin/bash

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

# shellcheck source=conf/bash_profile/.bashrc
source "${HOME}/.bashrc"
