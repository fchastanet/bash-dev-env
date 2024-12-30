#!/usr/bin/env zsh

# zsh history
export HISTFILE="${HOME}/.zhistory" # History filepath
export HISTSIZE=15000
export SAVEHIST=10000
export HISTDUP=erase
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS # do not put duplicated command into history list
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS  # do not save duplicated command
setopt EXTENDED_HISTORY   # record command start time
setopt HIST_REDUCE_BLANKS # remove unnecessary blanks
setopt APPEND_HISTORY     # Immediately append history instead of overwriting

if typeset -f zinit >/dev/null; then
  __zinit_plugin_loaded_callback() {
    bindkey "\ek" history-substring-search-up
    bindkey "\ej" history-substring-search-down
  }
  zinit lucid depth=1 load light-mode for \
    atload='__zinit_plugin_loaded_callback' zsh-users/zsh-history-substring-search
fi
