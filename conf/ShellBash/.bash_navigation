#!/bin/bash

# source https://dev.to/blikoor/customize-git-bash-shell-498l

# Ignore lines which begin with a <space> and match previous entries.
# Erase duplicate entries in history file.
HISTCONTROL=ignoreboth:erasedups:ignorespace

# removes all duplicates and yet preserves chronology within each terminal!
hFix() {
  history -a &&
    history | sort -k2 -k1nr | uniq -f1 | sort -n | cut -c8- >~/.tmp-history$$ &&
    history -c &&
    history -r ~/.tmp-history$$ &&
    rm ~/.tmp-history$$
}

# Ignore saving short- and other listed commands to the history file.
HISTIGNORE="?:??:history:cd_*"

# Set Bash to save each command to history, right after it has been executed.
# in case bash_profile is reloaded do not add again hFix
if [[ ! ${PROMPT_COMMAND} =~ .*hFix.* ]]; then
  # add a ; if needed
  PROMPT_COMMAND="$(echo "${PROMPT_COMMAND:-true}" | sed -r "s/[\t ]*;{0,1}[\t ]*$/;/") hFix;"
fi

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# max number of commands stored in history during a session
HISTSIZE=1000
# max number of commands stored in the history file (for all sessions)
HISTFILESIZE=2000

# Append commands to the history file, instead of overwriting it.
# History substitution are not immediately passed to the shell parser.
shopt -s histappend histverify

# Save multi-line commands in one history entry.
shopt -s cmdhist

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Bash shell settings
# Typing a directory name just by itself will automatically change into that directory.
shopt -s autocd

# Automatically fix directory name typos when changing directory.
shopt -s cdspell

# Automatically expand directory globs and fix directory name typos whilst completing.
# Note, this works in conjunction with the cdspell option listed above.
shopt -s direxpand dirspell

# Enable the ** globstar recursive pattern in file and directory expansions.
# For example, ls **/*.txt will list all text files in the current directory hierarchy.
shopt -s globstar
